import { Response } from 'express';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

export const getTodayQuestion = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id, partner_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes estar vinculado a una pareja para acceder a las preguntas.' });
    }

    const specificQuestionId = req.query.question_id as string | undefined;
    const isRandom = req.query.random === 'true';
    const coupleRes = await pool.query('SELECT current_question_id, created_at FROM couples WHERE id = $1', [coupleId]);
    const currentQuestionId = coupleRes.rows[0]?.current_question_id;

    let question;

    if (specificQuestionId) {
      const qRes = await pool.query('SELECT * FROM daily_questions WHERE id = $1', [specificQuestionId]);
      if (qRes.rows.length > 0) {
        question = qRes.rows[0];
        await pool.query('UPDATE couples SET current_question_id = $1 WHERE id = $2', [question.id, coupleId]);
      }
    } else if (isRandom) {
      const randomRes = await pool.query('SELECT * FROM daily_questions ORDER BY RANDOM() LIMIT 1');
      question = randomRes.rows[0];
      if (question) {
        await pool.query('UPDATE couples SET current_question_id = $1 WHERE id = $2', [question.id, coupleId]);
      }
    } else {
      // 1. First check if there is a pending question where partner answered but user hasn't
      const pendingRes = await pool.query(
        `SELECT q.*
         FROM daily_answers a
         JOIN daily_questions q ON a.question_id = q.id
         WHERE a.couple_id = $1 AND a.user_id != $2
           AND NOT EXISTS (
             SELECT 1 FROM daily_answers a2 WHERE a2.couple_id = $1 AND a2.question_id = q.id AND a2.user_id = $2
           )
         ORDER BY a.answered_at ASC
         LIMIT 1`,
        [coupleId, userId]
      );

      if (pendingRes.rows.length > 0) {
        question = pendingRes.rows[0];
        await pool.query('UPDATE couples SET current_question_id = $1 WHERE id = $2', [question.id, coupleId]);
      } else if (currentQuestionId) {
        const qRes = await pool.query('SELECT * FROM daily_questions WHERE id = $1', [currentQuestionId]);
        if (qRes.rows.length > 0) {
          question = qRes.rows[0];
        }
      }
    }

    if (!question) {
      // Pick a question based on day index from couple creation
      const countRes = await pool.query('SELECT COUNT(*) FROM daily_questions');
      const totalQuestions = parseInt(countRes.rows[0].count) || 1;

      const createdDate = new Date(coupleRes.rows[0]?.created_at || Date.now());
      const daysSince = Math.floor((Date.now() - createdDate.getTime()) / (1000 * 60 * 60 * 24));
      const questionOffset = daysSince % totalQuestions;

      const questionRes = await pool.query(
        'SELECT * FROM daily_questions ORDER BY id OFFSET $1 LIMIT 1',
        [questionOffset]
      );
      question = questionRes.rows[0];

      if (question) {
        await pool.query('UPDATE couples SET current_question_id = $1 WHERE id = $2', [question.id, coupleId]);
      }
    }

    // Check real answers for this couple and this exact question
    const answersRes = await pool.query(
      `SELECT a.user_id, a.answer_text, a.answered_at, COALESCE(u.nickname, u.name) as user_name
       FROM daily_answers a
       JOIN users u ON a.user_id = u.id
       WHERE a.couple_id = $1 AND a.question_id = $2`,
      [coupleId, question.id]
    );

    const userAnswer = answersRes.rows.find((a) => a.user_id === userId);
    const partnerAnswer = answersRes.rows.find((a) => a.user_id !== userId);

    // REVEAL LOCK: Partner answer is visible IF current user has also answered!
    const canSeePartnerAnswer = !!userAnswer;

    return res.json({
      question,
      user_answered: !!userAnswer,
      user_answer: userAnswer ? userAnswer.answer_text : null,
      partner_answered: !!partnerAnswer,
      partner_name: partnerAnswer ? partnerAnswer.user_name : 'Tu pareja',
      partner_answer: canSeePartnerAnswer && partnerAnswer ? partnerAnswer.answer_text : null,
      is_locked_for_user: !userAnswer && !!partnerAnswer,
      both_answered: !!userAnswer && !!partnerAnswer,
    });
  } catch (error) {
    console.error('Error al obtener pregunta del día:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const answerQuestion = async (req: AuthRequest, res: Response) => {
  const { question_id, answer_text } = req.body;
  const userId = req.user?.id;

  if (!question_id || !answer_text) {
    return res.status(400).json({ error: 'ID de pregunta y texto de respuesta requeridos.' });
  }

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes estar vinculado en una pareja.' });
    }

    // Insert or update answer
    await pool.query(
      `INSERT INTO daily_answers (couple_id, question_id, user_id, answer_text)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (couple_id, question_id, user_id)
       DO UPDATE SET answer_text = EXCLUDED.answer_text, answered_at = CURRENT_TIMESTAMP`,
      [coupleId, question_id, userId, answer_text.trim()]
    );

    // Award XP to couple's virtual pet for answering!
    await pool.query(
      `UPDATE couples
       SET pet_xp = pet_xp + 15,
           pet_level = FLOOR((pet_xp + 15) / 100) + 1
       WHERE id = $1`,
      [coupleId]
    );

    return res.json({
      message: '¡Respuesta guardada! Ganaron +15 XP para su Corazoncito 🐾',
    });
  } catch (error) {
    console.error('Error al responder pregunta:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const getAnswerHistory = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id, partner_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes estar vinculado a una pareja.' });
    }

    const result = await pool.query(
      `SELECT DISTINCT ON (q.id) q.id as question_id, q.question_text, q.category, q.emoji,
              (SELECT answer_text FROM daily_answers WHERE couple_id = $1 AND question_id = q.id AND user_id = $2) as my_answer,
              (SELECT answered_at FROM daily_answers WHERE couple_id = $1 AND question_id = q.id AND user_id = $2) as my_answered_at,
              CASE
                WHEN (SELECT answer_text FROM daily_answers WHERE couple_id = $1 AND question_id = q.id AND user_id = $2) IS NULL THEN NULL
                ELSE (SELECT answer_text FROM daily_answers WHERE couple_id = $1 AND question_id = q.id AND user_id != $2)
              END as partner_answer,
              ((SELECT answer_text FROM daily_answers WHERE couple_id = $1 AND question_id = q.id AND user_id != $2) IS NOT NULL) as partner_has_answered,
              (SELECT answered_at FROM daily_answers WHERE couple_id = $1 AND question_id = q.id AND user_id != $2) as partner_answered_at
       FROM daily_answers a
       JOIN daily_questions q ON a.question_id = q.id
       WHERE a.couple_id = $1
       ORDER BY q.id, a.answered_at DESC`,
      [coupleId, userId]
    );

    return res.json({ history: result.rows });
  } catch (error) {
    console.error('Error al obtener historial de respuestas:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

