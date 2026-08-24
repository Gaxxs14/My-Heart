import { Response } from 'express';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

export const createBucketItem = async (req: AuthRequest, res: Response) => {
  const { title, description, category } = req.body;
  const userId = req.user?.id;

  if (!title) {
    return res.status(400).json({ error: 'Título del deseo requerido.' });
  }

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes estar vinculado en una pareja.' });
    }

    const result = await pool.query(
      `INSERT INTO bucket_list_items (couple_id, created_by_user_id, title, description, category)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [coupleId, userId, title, description || '', category || 'date_night']
    );

    return res.status(201).json({
      message: '¡Meta añadida a la Bucket List!',
      item: result.rows[0],
    });
  } catch (error) {
    console.error('Error al crear item de bucket list:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const getBucketList = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'Debes estar vinculado en una pareja.' });
    }

    const result = await pool.query(
      `SELECT b.*, u.name as creator_name
       FROM bucket_list_items b
       JOIN users u ON b.created_by_user_id = u.id
       WHERE b.couple_id = $1
       ORDER BY b.is_completed ASC, b.created_at DESC`,
      [coupleId]
    );

    return res.json({ items: result.rows });
  } catch (error) {
    console.error('Error al obtener bucket list:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const toggleBucketItem = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { is_completed, proof_photo_url } = req.body;
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    const result = await pool.query(
      `UPDATE bucket_list_items
       SET is_completed = $1,
           completed_date = CASE WHEN $1 = true THEN CURRENT_DATE ELSE NULL END,
           proof_photo_url = COALESCE($2, proof_photo_url)
       WHERE id = $3 AND couple_id = $4
       RETURNING *`,
      [is_completed, proof_photo_url || null, id, coupleId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Meta no encontrada.' });
    }

    if (is_completed) {
      // Award big XP for fulfilling a bucket list dream!
      await pool.query('UPDATE couples SET pet_xp = pet_xp + 50 WHERE id = $1', [coupleId]);
    }

    return res.json({
      message: is_completed ? '¡Meta completada juntos! (+50 XP) 🎉' : 'Meta actualizada.',
      item: result.rows[0],
    });
  } catch (error) {
    console.error('Error al alternar estado de bucket item:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};
