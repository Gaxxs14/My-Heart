import { Response } from 'express';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

export const createSecretLetter = async (req: AuthRequest, res: Response) => {
  const { title, content, unlock_type, unlock_date, unlock_mood } = req.body;
  const userId = req.user?.id;

  if (!title || !content) {
    return res.status(400).json({ error: 'Título y contenido de la carta son requeridos.' });
  }

  try {
    const userRes = await pool.query('SELECT couple_id, partner_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;
    const partnerId = userRes.rows[0]?.partner_id;

    if (!coupleId || !partnerId) {
      return res.status(400).json({ error: 'Debes estar vinculado a tu pareja para enviar una carta secreta.' });
    }

    const result = await pool.query(
      `INSERT INTO secret_letters (couple_id, sender_id, receiver_id, title, content, unlock_type, unlock_date, unlock_mood)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [coupleId, userId, partnerId, title, content, unlock_type || 'date', unlock_date || null, unlock_mood || null]
    );

    return res.status(201).json({
      message: '¡Carta secreta sellada y guardada en la cápsula del tiempo! 💌',
      letter: result.rows[0],
    });
  } catch (error) {
    console.error('Error al crear carta secreta:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const getLetters = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes estar vinculado a una pareja.' });
    }

    const result = await pool.query(
      `SELECT l.id, l.couple_id, l.sender_id, l.receiver_id, l.title, l.unlock_type, l.unlock_date, l.unlock_mood, l.is_opened, l.created_at,
              u.name as sender_name,
              CASE
                WHEN l.receiver_id = $1 AND l.unlock_type = 'date' AND l.unlock_date > CURRENT_TIMESTAMP AND l.is_opened = false THEN '[Bloqueada hasta ' || TO_CHAR(l.unlock_date, 'YYYY-MM-DD HH24:MI') || ']'
                ELSE l.content
              END as content,
              CASE
                WHEN l.receiver_id = $1 AND l.unlock_type = 'date' AND l.unlock_date > CURRENT_TIMESTAMP AND l.is_opened = false THEN false
                ELSE true
              END as is_unlocked
       FROM secret_letters l
       JOIN users u ON l.sender_id = u.id
       WHERE l.couple_id = $1
       ORDER BY l.created_at DESC`,
      [userId, coupleId]
    );

    return res.json({ letters: result.rows });
  } catch (error) {
    console.error('Error al obtener cartas:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};
