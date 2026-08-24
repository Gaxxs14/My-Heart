import { Response } from 'express';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

// Helper to generate a cute pairing code like "HEART-7942"
const generatePairingCode = (): string => {
  const num = Math.floor(1000 + Math.random() * 9000);
  return `HEART-${num}`;
};

export const getPairingStatus = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    // Check if user already in a couple
    const userRes = await pool.query('SELECT couple_id, partner_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      // Find if an active pending code was created by this user
      const pendingCouple = await pool.query(
        'SELECT id, pairing_code, status, created_at FROM couples WHERE user1_id = $1 AND status = $2',
        [userId, 'pending']
      );

      if (pendingCouple.rows.length > 0) {
        return res.json({
          is_paired: false,
          has_code: true,
          pairing_code: pendingCouple.rows[0].pairing_code,
        });
      }

      return res.json({
        is_paired: false,
        has_code: false,
      });
    }

    // Is paired! Fetch couple data + partner data
    const coupleRes = await pool.query(
      `SELECT c.*,
              u1.name as user1_name, u1.avatar_url as user1_avatar, u1.mood_status as user1_mood, u1.mood_icon as user1_mood_icon,
              u2.name as user2_name, u2.avatar_url as user2_avatar, u2.mood_status as user2_mood, u2.mood_icon as user2_mood_icon
       FROM couples c
       LEFT JOIN users u1 ON c.user1_id = u1.id
       LEFT JOIN users u2 ON c.user2_id = u2.id
       WHERE c.id = $1`,
      [coupleId]
    );

    return res.json({
      is_paired: true,
      couple: coupleRes.rows[0],
    });
  } catch (error) {
    console.error('Error al obtener estado de pareja:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const createPairingCode = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;

  try {
    // If user already in a couple
    const userCheck = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    if (userCheck.rows[0]?.couple_id) {
      return res.status(400).json({ error: 'Ya estás vinculado/a en una pareja.' });
    }

    // Delete previous pending codes by this user
    await pool.query('DELETE FROM couples WHERE user1_id = $1 AND status = $2', [userId, 'pending']);

    let pairingCode = generatePairingCode();
    // Ensure uniqueness
    let isUnique = false;
    while (!isUnique) {
      const codeCheck = await pool.query('SELECT id FROM couples WHERE pairing_code = $1', [pairingCode]);
      if (codeCheck.rows.length === 0) {
        isUnique = true;
      } else {
        pairingCode = generatePairingCode();
      }
    }

    const result = await pool.query(
      `INSERT INTO couples (pairing_code, user1_id, status)
       VALUES ($1, $2, 'pending')
       RETURNING id, pairing_code, status, created_at`,
      [pairingCode, userId]
    );

    return res.status(201).json({
      message: 'Código de vinculación generado con éxito.',
      pairing_code: result.rows[0].pairing_code,
      couple_id: result.rows[0].id,
    });
  } catch (error) {
    console.error('Error al crear código:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const linkPartnerByCode = async (req: AuthRequest, res: Response) => {
  const { code, anniversary_date } = req.body;
  const userId = req.user?.id;

  if (!code) {
    return res.status(400).json({ error: 'El código de vinculación es requerido.' });
  }

  const formattedCode = code.trim().toUpperCase();

  try {
    const coupleRes = await pool.query(
      'SELECT id, user1_id, user2_id, status FROM couples WHERE pairing_code = $1',
      [formattedCode]
    );

    if (coupleRes.rows.length === 0) {
      return res.status(404).json({ error: 'Código inválido o no encontrado.' });
    }

    const couple = coupleRes.rows[0];

    if (couple.user1_id === userId) {
      return res.status(400).json({ error: 'No puedes vincularte con tu propio código.' });
    }

    if (couple.status === 'active' || couple.user2_id) {
      return res.status(400).json({ error: 'Este código ya ha sido utilizado por otra pareja.' });
    }

    const partnerId = couple.user1_id;

    // Update couple
    const updatedCouple = await pool.query(
      `UPDATE couples
       SET user2_id = $1,
           status = 'active',
           anniversary_date = COALESCE($2, CURRENT_DATE),
           relationship_time_start = COALESCE($2, CURRENT_TIMESTAMP),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $3
       RETURNING *`,
      [userId, anniversary_date || null, couple.id]
    );

    // Update both users with couple_id and partner_id
    await pool.query('UPDATE users SET couple_id = $1, partner_id = $2 WHERE id = $3', [couple.id, partnerId, userId]);
    await pool.query('UPDATE users SET couple_id = $1, partner_id = $2 WHERE id = $3', [couple.id, userId, partnerId]);

    return res.json({
      message: '¡Felicitaciones! Se han vinculado exitosamente 💖',
      couple: updatedCouple.rows[0],
    });
  } catch (error) {
    console.error('Error al vincular con código:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const updateCoupleSettings = async (req: AuthRequest, res: Response) => {
  const { anniversary_date, pet_name, love_song_title, love_song_artist, theme_palette } = req.body;
  const userId = req.user?.id;

  try {
    const userRes = await pool.query('SELECT couple_id FROM users WHERE id = $1', [userId]);
    const coupleId = userRes.rows[0]?.couple_id;

    if (!coupleId) {
      return res.status(400).json({ error: 'No perteneces a una pareja vinculada.' });
    }

    const result = await pool.query(
      `UPDATE couples
       SET anniversary_date = COALESCE($1, anniversary_date),
           pet_name = COALESCE($2, pet_name),
           love_song_title = COALESCE($3, love_song_title),
           love_song_artist = COALESCE($4, love_song_artist),
           theme_palette = COALESCE($5, theme_palette),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $6
       RETURNING *`,
      [anniversary_date, pet_name, love_song_title, love_song_artist, theme_palette, coupleId]
    );

    return res.json({
      message: 'Ajustes de pareja actualizados.',
      couple: result.rows[0],
    });
  } catch (error) {
    console.error('Error al actualizar ajustes de pareja:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};
