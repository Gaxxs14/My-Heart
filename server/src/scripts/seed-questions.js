const { Pool } = require('pg');

const pool = new Pool({
  connectionString: 'postgresql://neondb_owner:npg_7eP0ZObQwGuq@ep-curly-rain-ayo1yuda-pooler.c-5.us-east-2.aws.neon.tech/neondb?sslmode=require',
});

const questions = [
  { text: '¿Cuál fue el momento exacto en que te diste cuenta de que te gustaba?', cat: 'deep', emoji: '✨', day: 1 },
  { text: 'Si tuviéramos 24 horas libres en cualquier lugar del mundo sin preocuparnos por el dinero, ¿a dónde iríamos?', cat: 'future', emoji: '✈️', day: 2 },
  { text: '¿Qué pequeña manía o detalle mío te parece secretamente adorable?', cat: 'fun', emoji: '🥰', day: 3 },
  { text: '¿Cuál ha sido la cita o momento juntos en el que más te has reído hasta llorar?', cat: 'memories', emoji: '😂', day: 4 },
  { text: '¿Qué canción te recuerda automáticamente a nosotros dos y por qué?', cat: 'memories', emoji: '🎵', day: 5 },
  { text: 'Si nos quedáramos atrapados en una cabaña en medio de la nieve por una semana, ¿qué haríamos?', cat: 'spicy', emoji: '🔥', day: 6 },
  { text: '¿Cuál es un sueño o meta grande que te gustaría que logremos juntos en los próximos 3 años?', cat: 'future', emoji: '🌟', day: 7 },
  { text: '¿Qué es lo que más valoras de la forma en que nos comunicamos o resolvemos las cosas?', cat: 'deep', emoji: '💬', day: 8 },
  { text: 'Si pudieras revivir un día entero de nuestra relación como si fuera una película, ¿cuál elegirías?', cat: 'memories', emoji: '🎬', day: 9 },
  { text: '¿Cuál es tu forma favorita de recibir cariño o afecto de mi parte?', cat: 'deep', emoji: '💖', day: 10 },
  { text: '¿Cuál fue tu primera impresión de mí el primer día que nos conocimos o hablamos?', cat: 'memories', emoji: '👀', day: 11 },
  { text: '¿Qué comida o postre sientes que representa nuestra relación y por qué?', cat: 'fun', emoji: '🍕', day: 12 },
  { text: '¿Cuál es tu recuerdo favorito de un beso o abrazo nuestro?', cat: 'spicy', emoji: '💋', day: 13 },
  { text: 'Si inventáramos un día festivo solo para nosotros dos, ¿cómo se llamaría y qué haríamos?', cat: 'fun', emoji: '🎉', day: 14 },
  { text: '¿Qué es algo nuevo que te gustaría que probemos o aprendamos juntos este mes?', cat: 'future', emoji: '🎯', day: 15 },
  { text: '¿Qué cualidad mía te hace sentir más seguro/a y en paz a mi lado?', cat: 'deep', emoji: '🕊️', day: 16 },
  { text: 'Si tuvieras que describirme usando solo 3 palabras, ¿cuáles serían?', cat: 'deep', emoji: '💌', day: 17 },
  { text: '¿Cuál ha sido el detalle o sorpresa que más te ha tocado el corazón?', cat: 'memories', emoji: '🎁', day: 18 },
  { text: '¿Qué apodo o frase nuestra es tu favorito indiscutible?', cat: 'fun', emoji: '🤫', day: 19 },
  { text: 'Si hoy fuera nuestra última noche en la Tierra, ¿cómo la pasaríamos juntos?', cat: 'spicy', emoji: '🌙', day: 20 },
  { text: '¿Qué película o serie sientes que se parece más a nosotros dos?', cat: 'fun', emoji: '🍿', day: 21 },
  { text: '¿En qué momento del día piensas más en mí?', cat: 'deep', emoji: '💭', day: 22 },
  { text: '¿Cuál es tu lugar favorito para abrazarnos y no hacer absolutamente nada?', cat: 'deep', emoji: '🛋️', day: 23 },
  { text: '¿Qué aventura extrema o viaje loco te atreverías a hacer solo si voy contigo?', cat: 'future', emoji: '🏔️', day: 24 },
  { text: '¿Qué aroma, perfume o olor te recuerda instantáneamente a mí?', cat: 'memories', emoji: '🌸', day: 25 },
  { text: 'Si tuviéramos una casa de campo soñada, ¿qué cosa divertida o loca no podría faltar?', cat: 'future', emoji: '🏡', day: 26 },
  { text: '¿Qué es lo más tierno o cursi que has pensado de mí últimamente?', cat: 'spicy', emoji: '🤭', day: 27 },
  { text: '¿Cuál es tu momento favorito del día cuando estamos juntos?', cat: 'deep', emoji: '☀️', day: 28 },
  { text: 'Si pudiéramos adoptar cualquier mascota exótica juntos, ¿cuál elegirías?', cat: 'fun', emoji: '🐾', day: 29 },
  { text: '¿Qué aprendizaje o cambio positivo sientes que ha traído nuestra relación a tu vida?', cat: 'deep', emoji: '🌱', day: 30 },
  { text: '¿Qué ropa o look mío te parece más irresistible?', cat: 'spicy', emoji: '👗', day: 31 },
  { text: '¿Cuál es la foto nuestra que más amas ver en tu galería?', cat: 'memories', emoji: '📸', day: 32 },
  { text: 'Si fuéramos una pareja de superhéroes, ¿cuáles serían nuestros superpoderes?', cat: 'fun', emoji: '🦸‍♂️', day: 33 },
  { text: '¿Qué es algo que te da vergüenza admitir pero que te encanta de nosotros?', cat: 'spicy', emoji: '🙈', day: 34 },
  { text: '¿Cuál es tu tradición favorita que hemos creado juntos?', cat: 'deep', emoji: '🕯️', day: 35 },
  { text: 'Si tuviéramos un restaurante juntos, ¿cómo se llamaría nuestro plato estrella?', cat: 'fun', emoji: '🍔', day: 36 },
  { text: '¿Qué es lo que más te emociona cuando sabes que nos vamos a ver hoy?', cat: 'deep', emoji: '💓', day: 37 },
  { text: '¿Cuál ha sido la conversación nocturna más bonita que hemos tenido?', cat: 'memories', emoji: '🌌', day: 38 },
  { text: 'Si tuviéramos un viaje por carretera con música a todo volumen, ¿cuál sería la primera canción?', cat: 'fun', emoji: '🚗', day: 39 },
  { text: '¿Qué te gustaría que hiciéramos en nuestro próximo aniversario?', cat: 'future', emoji: '🥂', day: 40 }
];

async function seed() {
  await pool.query('DELETE FROM daily_questions');
  for (const q of questions) {
    await pool.query(
      'INSERT INTO daily_questions (question_text, category, emoji, day_number) VALUES ($1, $2, $3, $4)',
      [q.text, q.cat, q.emoji, q.day]
    );
  }
  const res = await pool.query('SELECT COUNT(*) FROM daily_questions');
  console.log('✅ Base de datos poblada con éxito. Total preguntas:', res.rows[0].count);
  await pool.end();
}

seed().catch((err) => {
  console.error('Error al poblar preguntas:', err);
  pool.end();
});
