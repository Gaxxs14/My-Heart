import { Response } from 'express';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

export const createStickyNote = async (req: AuthRequest, res: Response) => {
  const { content, color } = req.body;
  const userId = req.user?.id;

  if (!content || !content.trim()) {
    return res.status(400).json({ error: 'El contenido de la nota es requerido.' });
  }

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes pertenecer a una pareja para dejar una notita.' });
    }

    const result = await pool.query(
      `INSERT INTO sticky_notes (couple_id, sender_id, content, color)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [coupleId, userId, content.trim(), color || 'pink']
    );

    await pool.query('UPDATE couples SET pet_xp = pet_xp + 10 WHERE id = $1', [coupleId]);

    const noteRes = await pool.query(
      `SELECT n.*, COALESCE(u.nickname, u.name) as author_name
       FROM sticky_notes n
       JOIN users u ON n.sender_id = u.id
       WHERE n.id = $1`,
      [result.rows[0].id]
    );

    return res.status(201).json({
      message: '¡Notita pegada con éxito! 💌 (+10 XP)',
      note: noteRes.rows[0],
    });
  } catch (error) {
    console.error('Error al crear notita adhesiva:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const getStickyNotes = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes pertenecer a una pareja.' });
    }

    const result = await pool.query(
      `SELECT n.*, COALESCE(u.nickname, u.name) as author_name
       FROM sticky_notes n
       JOIN users u ON n.sender_id = u.id
       WHERE n.couple_id = $1
       ORDER BY n.created_at DESC`,
      [coupleId]
    );

    return res.json({ notes: result.rows });
  } catch (error) {
    console.error('Error al obtener notitas adhesivas:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const deleteStickyNote = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes pertenecer a una pareja.' });
    }

    await pool.query('DELETE FROM sticky_notes WHERE id = $1 AND couple_id = $2', [id, coupleId]);

    return res.json({ message: 'Notita eliminada exitosamente.' });
  } catch (error) {
    console.error('Error al eliminar notita:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

