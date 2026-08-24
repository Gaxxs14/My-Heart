import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const connectionString = process.env.DATABASE_URL;

export const pool = new Pool({
  connectionString,
  ssl: process.env.NODE_ENV === 'production' || (connectionString && connectionString.includes('neon.tech'))
    ? { rejectUnauthorized: false }
    : false,
});

pool.on('connect', () => {
  console.log('✨ Conectado exitosamente a la base de datos Neon PostgreSQL');
});

pool.on('error', (err) => {
  console.error('❌ Error en el pool de PostgreSQL:', err);
});
