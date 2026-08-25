const { Pool } = require('pg');
const pool = new Pool({
  connectionString: 'postgresql://neondb_owner:npg_7eP0ZObQwGuq@ep-curly-rain-ayo1yuda-pooler.c-5.us-east-2.aws.neon.tech/neondb?sslmode=require'
});

async function run() {
  const client = await pool.connect();
  try {
    await client.query('ALTER TABLE couples ADD COLUMN IF NOT EXISTS love_song_url TEXT;');
    await client.query(`
      CREATE TABLE IF NOT EXISTS sticky_notes (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
        sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        content TEXT NOT NULL,
        color VARCHAR(30) DEFAULT 'pink',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_sticky_notes_couple ON sticky_notes(couple_id);
    `);
    await client.query(`
      CREATE TABLE IF NOT EXISTS couple_calendar (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        event_date DATE NOT NULL,
        emoji VARCHAR(20) DEFAULT '💖',
        event_type VARCHAR(50) DEFAULT 'date',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_couple_calendar_couple ON couple_calendar(couple_id);
    `);
    await client.query(`
      CREATE TABLE IF NOT EXISTS couple_places (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        couple_id UUID NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        city VARCHAR(255),
        category VARCHAR(50) DEFAULT 'restaurant',
        note TEXT,
        visit_date DATE NOT NULL DEFAULT CURRENT_DATE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_couple_places_couple ON couple_places(couple_id);
    `);
    console.log('MIGRATION_SUCCESS');
  } catch (err) {
    console.error('MIGRATION_ERROR', err);
  } finally {
    client.release();
    await pool.end();
  }
}
run();
