import fs from 'fs';
import path from 'path';
import { pool } from '../config/db';

async function initDatabase() {
  console.log('🚀 Iniciando configuración de base de datos en Neon PostgreSQL...');

  const schemaPath = path.resolve(__dirname, '../../../database/schema.sql');
  if (!fs.existsSync(schemaPath)) {
    console.error(`❌ No se encontró el archivo de esquema en: ${schemaPath}`);
    process.exit(1);
  }

  const sql = fs.readFileSync(schemaPath, 'utf8');

  try {
    const client = await pool.connect();
    console.log('🔌 Ejecutando scripts de creación de tablas...');
    await client.query(sql);
    client.release();
    console.log('✅ Base de datos inicializada y tablas creadas exitosamente en Neon.');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error al inicializar base de datos:', error);
    process.exit(1);
  }
}

initDatabase();
