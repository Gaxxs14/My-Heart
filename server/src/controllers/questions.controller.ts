import { Response } from 'express';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

export const getTodayQuestion = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id, partner_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;
    const partnerId = userRes.rows[0]?.partner_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes estar vinculado a una pareja para acceder a las preguntas.' });
    }

    // Pick a question based on day index
    const countRes = await pool.query('SELECT COUNT(*) FROM daily_questions');
    const totalQuestions = parseInt(countRes.rows[0].count) || 1;

    // Calculate day offset from couple creation date
    const coupleRes = await pool.query('SELECT created_at FROM couples WHERE id = $1', [coupleId]);
    const createdDate = new Date(coupleRes.rows[0]?.created_at || Date.now());
    const daysSince = Math.floor((Date.now() - createdDate.getTime()) / (1000 * 60 * 60 * 24));
    const questionOffset = daysSince % totalQuestions;

    const questionRes = await pool.query(
      'SELECT * FROM daily_questions ORDER BY id OFFSET $1 LIMIT 1',
      [questionOffset]
    );

    const question = questionRes.rows[0];

    // Check answers for this couple
    const answersRes = await pool.query(
      'SELECT user_id, answer_text, answered_at FROM daily_answers WHERE couple_id = $1 AND question_id = $2',
      [coupleId, question.id]
    );

    const userAnswer = answersRes.rows.find((a) => a.user_id === userId);
    const partnerAnswer = answersRes.rows.find((a) => a.user_id === partnerId);

    // REVEAL LOCK: Partner answer is only visible IF current user has also answered!
    const canSeePartnerAnswer = !!userAnswer;

    return res.json({
      question,
      user_answered: !!userAnswer,
      user_answer: userAnswer ? userAnswer.answer_text : null,
      partner_answered: !!partnerAnswer,
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
      `SELECT q.id as question_id, q.question_text, q.category, q.emoji,
              a1.answer_text as my_answer, a1.answered_at as my_answered_at,
              a2.answer_text as partner_answer, a2.answered_at as partner_answered_at
       FROM daily_answers a1
       JOIN daily_questions q ON a1.question_id = q.id
       LEFT JOIN daily_answers a2 ON a2.couple_id = a1.couple_id AND a2.question_id = a1.question_id AND a2.user_id != a1.user_id
       WHERE a1.couple_id = $1 AND a1.user_id = $2
       ORDER BY a1.answered_at DESC`,
      [coupleId, userId]
    );

    return res.json({ history: result.rows });
  } catch (error) {
    console.error('Error al obtener historial de respuestas:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};
