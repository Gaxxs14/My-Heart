import { Response } from 'express';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

export const createPlace = async (req: AuthRequest, res: Response) => {
  const { name, city, category, note, visit_date } = req.body;
  const userId = req.user?.id;

  if (!name || !name.trim()) {
    return res.status(400).json({ error: 'El nombre del lugar es requerido.' });
  }

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes pertenecer a una pareja.' });
    }

    const result = await pool.query(
      `INSERT INTO couple_places (couple_id, user_id, name, city, category, note, visit_date)
       VALUES ($1, $2, $3, $4, $5, $6, COALESCE($7, CURRENT_DATE))
       RETURNING *`,
      [coupleId, userId, name.trim(), city || null, category || 'restaurant', note || null, visit_date || null]
    );

    await pool.query('UPDATE couples SET pet_xp = pet_xp + 25 WHERE id = $1', [coupleId]);

    return res.status(201).json({
      message: '¡Lugar romántico guardado! 📍 (+25 XP)',
      place: result.rows[0],
    });
  } catch (error) {
    console.error('Error al crear lugar romántico:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const getPlaces = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes pertenecer a una pareja.' });
    }

    const result = await pool.query(
      `SELECT *
       FROM couple_places
       WHERE couple_id = $1
       ORDER BY created_at DESC`,
      [coupleId]
    );

    return res.json({ places: result.rows });
  } catch (error) {
    console.error('Error al obtener lugares románticos:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

