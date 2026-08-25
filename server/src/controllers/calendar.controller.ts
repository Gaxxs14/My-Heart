import { Response } from 'express';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

export const createCalendarEvent = async (req: AuthRequest, res: Response) => {
  const { title, event_date, emoji, event_type } = req.body;
  const userId = req.user?.id;

  if (!title || !event_date) {
    return res.status(400).json({ error: 'Título y fecha del evento son requeridos.' });
  }

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes pertenecer a una pareja.' });
    }

    const result = await pool.query(
      `INSERT INTO couple_calendar (couple_id, user_id, title, event_date, emoji, event_type)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [coupleId, userId, title.trim(), event_date, emoji || '💖', event_type || 'date']
    );

    return res.status(201).json({
      message: '¡Evento agregado al calendario de pareja! 📅',
      event: result.rows[0],
    });
  } catch (error) {
    console.error('Error al crear evento de calendario:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const getCalendarEvents = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes pertenecer a una pareja.' });
    }

    const result = await pool.query(
      `SELECT *
       FROM couple_calendar
       WHERE couple_id = $1
       ORDER BY event_date ASC`,
      [coupleId]
    );

    return res.json({ events: result.rows });
  } catch (error) {
    console.error('Error al obtener eventos de calendario:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const deleteCalendarEvent = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes pertenecer a una pareja.' });
    }

    await pool.query('DELETE FROM couple_calendar WHERE id = $1 AND couple_id = $2', [id, coupleId]);

    return res.json({ message: 'Evento eliminado exitosamente.' });
  } catch (error) {
    console.error('Error al eliminar evento:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

