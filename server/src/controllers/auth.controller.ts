import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { pool } from '../config/db';
import { AuthRequest } from '../middleware/auth';

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_romantic_heart_key';

export const register = async (req: Request, res: Response) => {
  const { email, password, name, nickname } = req.body;

  if (!email || !password || !name) {
    return res.status(400).json({ error: 'Nombre, email y contraseña son obligatorios.' });
  }

  try {
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Ya existe una cuenta con este correo electrónico.' });
    }

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    const result = await pool.query(
      `INSERT INTO users (email, password_hash, name, nickname)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, name, nickname, avatar_url, mood_status, mood_icon, couple_id, created_at`,
      [email, password_hash, name, nickname || name]
    );

    const user = result.rows[0];
    const token = jwt.sign({ id: user.id, email: user.email, couple_id: user.couple_id }, JWT_SECRET, { expiresIn: '90d' });

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
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email y contraseña requeridos.' });
  }

  try {
    const result = await pool.query(
      `SELECT id, email, password_hash, name, nickname, avatar_url, mood_status, mood_icon, couple_id, partner_id
       FROM users WHERE email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Credenciales inválidas.' });
    }

    const user = result.rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Credenciales inválidas.' });
    }

    delete user.password_hash;
    const token = jwt.sign({ id: user.id, email: user.email, couple_id: user.couple_id }, JWT_SECRET, { expiresIn: '90d' });

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
