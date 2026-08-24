import { Response } from 'express';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

export const createMemory = async (req: AuthRequest, res: Response) => {
  const { title, description, photo_urls, memory_date, location_name, latitude, longitude } = req.body;
  const userId = req.user?.id;

  if (!title || !memory_date) {
    return res.status(400).json({ error: 'Título y fecha del recuerdo son obligatorios.' });
  }

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes estar vinculado en una pareja.' });
    }

    const result = await pool.query(
      `INSERT INTO timeline_memories (couple_id, user_id, title, description, photo_urls, memory_date, location_name, latitude, longitude)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [
        coupleId,
        userId,
        title,
        description || '',
        JSON.stringify(photo_urls || []),
        memory_date,
        location_name || null,
        latitude || null,
        longitude || null,
      ]
    );

    // Give pet XP
    await pool.query('UPDATE couples SET pet_xp = pet_xp + 20 WHERE id = $1', [coupleId]);

    return res.status(201).json({
      message: '¡Recuerdo añadido a su línea de tiempo! (+20 XP)',
      memory: result.rows[0],
    });
  } catch (error) {
    console.error('Error al crear recuerdo:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const getMemories = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes estar vinculado en una pareja.' });
    }

    const result = await pool.query(
      `SELECT m.*, u.name as author_name, u.avatar_url as author_avatar
       FROM timeline_memories m
       JOIN users u ON m.user_id = u.id
       WHERE m.couple_id = $1
       ORDER BY m.memory_date DESC, m.created_at DESC`,
      [coupleId]
    );

    return res.json({ memories: result.rows });
  } catch (error) {
    console.error('Error al obtener recuerdos:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};
