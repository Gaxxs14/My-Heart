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
      `INSERT INTO timeline_memories (couple_id, user_id, title, description, photo_urls, memory_date, location_name, latitude, longitude, reactions)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, '[]'::jsonb)
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
      `SELECT m.*, COALESCE(m.reactions, '[]'::jsonb) as reactions,
              COALESCE(u.nickname, u.name) as author_name, u.avatar_url as author_avatar
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

export const reactToMemory = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { emoji } = req.body;
  const userId = req.user?.id;

  if (!emoji) {
    return res.status(400).json({ error: 'Emoji de reacción es requerido.' });
  }

  try {
    const userRes = await pool.query('SELECT couple_id, name, nickname FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;
    const userName = userRes.rows[0]?.nickname || userRes.rows[0]?.name || 'Mi Amor';

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes pertenecer a una pareja.' });
    }

    const memoryRes = await pool.query('SELECT id, reactions FROM timeline_memories WHERE id = $1 AND couple_id = $2', [id, coupleId]);
    if (memoryRes.rows.length === 0) {
      return res.status(404).json({ error: 'Recuerdo no encontrado.' });
    }

    let reactions: any[] = memoryRes.rows[0].reactions || [];
    if (!Array.isArray(reactions)) {
      try {
        reactions = typeof reactions === 'string' ? JSON.parse(reactions) : [];
      } catch (_) {
        reactions = [];
      }
    }

    // Check if user already reacted with this emoji
    const existingIndex = reactions.findIndex((r) => r.user_id === userId);
    if (existingIndex >= 0) {
      if (reactions[existingIndex].emoji === emoji) {
        // Toggle off
        reactions.splice(existingIndex, 1);
      } else {
        // Change reaction
        reactions[existingIndex] = {
          user_id: userId,
          user_name: userName,
          emoji,
          updated_at: new Date().toISOString(),
        };
      }
    } else {
      // Add new reaction
      reactions.push({
        user_id: userId,
        user_name: userName,
        emoji,
        updated_at: new Date().toISOString(),
      });
    }

    await pool.query('UPDATE timeline_memories SET reactions = $1 WHERE id = $2', [JSON.stringify(reactions), id]);

    return res.json({
      message: 'Reacción actualizada con éxito 💕',
      reactions,
    });
  } catch (error) {
    console.error('Error al reaccionar a recuerdo:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};
