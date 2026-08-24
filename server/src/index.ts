import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import dotenv from 'dotenv';
import apiRouter from './routes/api';
import { setupSocketHandlers } from './sockets/heartbeat.socket';

dotenv.config();

const app = express();
const server = http.createServer(app);

// Enable CORS for mobile apps and web
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json({ limit: '10mb' }));

// Sockets configuration
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

setupSocketHandlers(io);

// Mount API routes
app.use('/api', apiRouter);

// Root greeting
app.get('/', (req, res) => {
  res.send('💖 My Heart API Server is running beautifully on Render with Neon PostgreSQL.');
});

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(`🚀 My Heart Server listo en el puerto ${PORT}`);
  console.log(`📡 WebSocket listo para conexiones en tiempo real`);
});
