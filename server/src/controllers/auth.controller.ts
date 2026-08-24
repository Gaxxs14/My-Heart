import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_romantic_heart_key';

export const register = async (req: Request, res: Response) => {
  const { username, email, password, name, nickname } = req.body;

  const rawUsername = (username || email?.split('@')[0] || name || '').toString().trim();
  const cleanUsername = rawUsername.toLowerCase().replace(/[^a-z0-9_.-]/g, '');

  if (!cleanUsername || cleanUsername.length < 3) {
    return res.status(400).json({ error: 'El nombre de usuario debe tener al menos 3 caracteres (letras o números).' });
  }

  if (!password || password.length < 6) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres.' });
  }

  const cleanName = (name || nickname || cleanUsername).toString().trim();
  const cleanNickname = (nickname || cleanName).toString().trim();
  const cleanEmail = email ? email.toString().toLowerCase().trim() : `${cleanUsername}@myheart.app`;

  try {
    const existing = await pool.query(
      'SELECT id FROM users WHERE LOWER(username) = LOWER($1) OR LOWER(email) = LOWER($2)',
      [cleanUsername, cleanEmail]
    );
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Este nombre de usuario ya está en uso. Por favor elige otro.' });
    }

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    const result = await pool.query(
      `INSERT INTO users (username, email, password_hash, name, nickname)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, username, email, name, nickname, avatar_url, mood_status, mood_icon, couple_id, created_at`,
      [cleanUsername, cleanEmail, password_hash, cleanName, cleanNickname]
    );

    const user = result.rows[0];
    const token = jwt.sign({ id: user.id, username: user.username, email: user.email, couple_id: user.couple_id }, JWT_SECRET, { expiresIn: '90d' });

    return res.status(201).json({
      message: '¡Bienvenido a My Heart! Cuenta creada con éxito.',
      user,
      token,
    });
  } catch (error: any) {
    console.error('Error al registrar usuario:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const login = async (req: Request, res: Response) => {
  const { username, email, identifier, password } = req.body;
  const loginInput = (username || identifier || email || '').toString().trim();

  if (!loginInput || !password) {
    return res.status(400).json({ error: 'Usuario y contraseña requeridos.' });
  }

  try {
    const result = await pool.query(
      `SELECT id, username, email, password_hash, name, nickname, avatar_url, mood_status, mood_icon, couple_id, partner_id
       FROM users 
       WHERE LOWER(username) = LOWER($1) OR LOWER(email) = LOWER($1) OR LOWER(name) = LOWER($1)`,
      [loginInput]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'No existe una cuenta con este usuario. ¿Deseas crear tu cuenta?' });
    }

    const user = result.rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Contraseña incorrecta. Inténtalo de nuevo.' });
    }

    delete user.password_hash;
    const token = jwt.sign({ id: user.id, username: user.username, email: user.email, couple_id: user.couple_id }, JWT_SECRET, { expiresIn: '90d' });

    return res.json({
      message: 'Inicio de sesión exitoso.',
      user,
      token,
    });
  } catch (error) {
    console.error('Error al iniciar sesión:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

// Quick Start: Enter with just Name and Nickname (Frictionless)
export const quickStart = async (req: Request, res: Response) => {
  const { name, nickname, pin } = req.body;

  if (!name || !name.trim()) {
    return res.status(400).json({ error: 'Ingresa tu nombre para continuar.' });
  }

  try {
    const uniqueId = uuidv4().substring(0, 8);
    const autoEmail = `${name.toLowerCase().replace(/[^a-z0-9]/g, '')}_${uniqueId}@myheart.app`;
    const password = pin || uuidv4();
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    const result = await pool.query(
      `INSERT INTO users (email, password_hash, name, nickname)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, name, nickname, avatar_url, mood_status, mood_icon, couple_id, created_at`,
      [autoEmail, password_hash, name.trim(), (nickname || name).trim()]
    );

    const user = result.rows[0];
    const token = jwt.sign({ id: user.id, email: user.email, couple_id: user.couple_id }, JWT_SECRET, { expiresIn: '90d' });

    return res.status(201).json({
      message: '¡Bienvenido a My Heart! Sesión iniciada.',
      user,
      token,
    });
  } catch (error) {
    console.error('Error en quickStart:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

// Quick Link: Enter with Name + Partner's Pairing Code directly in 1 step!
export const quickLink = async (req: Request, res: Response) => {
  const { name, nickname, pairing_code, anniversary_date } = req.body;

  if (!name || !pairing_code) {
    return res.status(400).json({ error: 'Nombre y código de pareja son requeridos.' });
  }

  const formattedCode = pairing_code.trim().toUpperCase();

  try {
    // Check if pairing code exists
    const coupleRes = await pool.query(
      'SELECT id, user1_id, user2_id, status FROM couples WHERE pairing_code = $1',
      [formattedCode]
    );

    if (coupleRes.rows.length === 0) {
      return res.status(404).json({ error: 'El código de pareja no existe o es incorrecto.' });
    }

    const couple = coupleRes.rows[0];
    if (couple.status === 'active' || couple.user2_id) {
      return res.status(400).json({ error: 'Este código ya ha sido utilizado.' });
    }

    const partnerId = couple.user1_id;

    // Create user
    const uniqueId = uuidv4().substring(0, 8);
    const autoEmail = `${name.toLowerCase().replace(/[^a-z0-9]/g, '')}_${uniqueId}@myheart.app`;
    const password = uuidv4();
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    const userRes = await pool.query(
      `INSERT INTO users (email, password_hash, name, nickname, couple_id, partner_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, email, name, nickname, avatar_url, mood_status, mood_icon, couple_id, partner_id, created_at`,
      [autoEmail, password_hash, name.trim(), (nickname || name).trim(), couple.id, partnerId]
    );

    const user = userRes.rows[0];

    // Update couple with user2 and active status
    await pool.query(
      `UPDATE couples
       SET user2_id = $1,
           status = 'active',
           anniversary_date = COALESCE($2, CURRENT_DATE),
           relationship_time_start = COALESCE($2, CURRENT_TIMESTAMP),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $3`,
      [user.id, anniversary_date || null, couple.id]
    );

    // Update user1 with partner_id and couple_id
    await pool.query('UPDATE users SET couple_id = $1, partner_id = $2 WHERE id = $3', [couple.id, user.id, partnerId]);

    const token = jwt.sign({ id: user.id, email: user.email, couple_id: couple.id }, JWT_SECRET, { expiresIn: '90d' });

    return res.status(201).json({
      message: '¡Conexión mágica exitosa! 💖',
      user,
      token,
    });
  } catch (error) {
    console.error('Error en quickLink:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const getProfile = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.id;
    const result = await pool.query(
      `SELECT u.id, u.email, u.name, u.nickname, u.avatar_url, u.mood_status, u.mood_icon, u.couple_id, u.partner_id,
              p.id as partner_user_id, p.name as partner_name, p.nickname as partner_nickname, 
              p.avatar_url as partner_avatar_url, p.mood_status as partner_mood_status, p.mood_icon as partner_mood_icon, p.is_online as partner_is_online
       FROM users u
       LEFT JOIN users p ON u.partner_id = p.id
       WHERE u.id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    return res.json({ profile: result.rows[0] });
  } catch (error) {
    console.error('Error al obtener perfil:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const updateProfile = async (req: AuthRequest, res: Response) => {
  const { name, nickname, avatar_url } = req.body;
  const userId = req.user?.id;

  try {
    const result = await pool.query(
      `UPDATE users
       SET name = COALESCE($1, name),
           nickname = COALESCE($2, nickname),
           avatar_url = COALESCE($3, avatar_url),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $4
       RETURNING id, username, email, name, nickname, avatar_url, mood_status, mood_icon, couple_id, partner_id`,
      [name, nickname, avatar_url, userId]
    );

    return res.json({
      message: 'Perfil actualizado con éxito.',
      user: result.rows[0],
    });
  } catch (error) {
    console.error('Error al actualizar perfil:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const updateMood = async (req: AuthRequest, res: Response) => {
  const { mood_status, mood_icon } = req.body;
  const userId = req.user?.id;

  try {
    const result = await pool.query(
      `UPDATE users
       SET mood_status = COALESCE($1, mood_status),
           mood_icon = COALESCE($2, mood_icon),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $3
       RETURNING id, mood_status, mood_icon`,
      [mood_status, mood_icon, userId]
    );

    return res.json({
      message: 'Estado de ánimo actualizado.',
      user: result.rows[0],
    });
  } catch (error) {
    console.error('Error al actualizar estado:', error);
    return res.status(500).json({ error: 'Error interno del servidor.' });
  }
};

export const deleteAccount = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id;
  if (!userId) {
    return res.status(401).json({ error: 'No autorizado.' });
  }

  try {
    // 1. Get user couple_id
    const userRes = await pool.query('SELECT couple_id, partner_id FROM users WHERE id = $1', [userId]);
    if (userRes.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado.' });
    }

    const { couple_id, partner_id } = userRes.rows[0];

    // 2. Unlink partner if any
    if (partner_id) {
      await pool.query('UPDATE users SET partner_id = NULL, couple_id = NULL WHERE id = $1', [partner_id]);
    }

    // 3. Delete couple data and dependent records if couple exists
    if (couple_id) {
      await pool.query('DELETE FROM memories WHERE couple_id = $1', [couple_id]);
      await pool.query('DELETE FROM bucket_list_items WHERE couple_id = $1', [couple_id]);
      await pool.query('DELETE FROM letters WHERE couple_id = $1', [couple_id]);
      await pool.query('DELETE FROM daily_answers WHERE couple_id = $1', [couple_id]);
      await pool.query('DELETE FROM couples WHERE id = $1', [couple_id]);
    }

    // 4. Delete user record completely
    await pool.query('DELETE FROM users WHERE id = $1', [userId]);

    return res.json({ message: 'Cuenta y todos los registros asociados eliminados permanentemente.' });
  } catch (error) {
    console.error('Error al eliminar cuenta:', error);
    return res.status(500).json({ error: 'Error interno al eliminar la cuenta.' });
  }
};

