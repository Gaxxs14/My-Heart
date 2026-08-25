import { Server, Socket } from 'socket.io';
import { pool } from '../config/db';

export const setupSocketHandlers = (io: Server) => {
  io.on('connection', (socket: Socket) => {
    console.log(`🔌 Nuevo cliente conectado: ${socket.id}`);

    // Join user and couple rooms
    socket.on('join_couple', async (data: { userId: string; coupleId: string }) => {
      const { userId, coupleId } = data;
      if (coupleId) {
        socket.join(`couple:${coupleId}`);
        console.log(`👫 Usuario ${userId} unido a la sala couple:${coupleId}`);

        // Update online status
        await pool.query('UPDATE users SET is_online = true, last_seen_at = CURRENT_TIMESTAMP WHERE id = $1', [userId]);

        // Notify partner that user is online
        socket.to(`couple:${coupleId}`).emit('partner_presence', {
          userId,
          is_online: true,
        });
      }
    });

    // Handle instant heartbeats (Touch / Ping)
    socket.on('send_heartbeat', async (data: { coupleId: string; senderId: string; senderName: string; pattern?: string }) => {
      const { coupleId, senderId, senderName, pattern } = data;

      try {
        // Save heartbeat record in DB
        await pool.query(
          'INSERT INTO heartbeats (couple_id, sender_id, vibration_pattern) VALUES ($1, $2, $3)',
          [coupleId, senderId, pattern || 'double_pulse']
        );

        // Give small XP boost
        await pool.query('UPDATE couples SET pet_xp = pet_xp + 2 WHERE id = $1', [coupleId]);

        // Broadcast to partner in room
        socket.to(`couple:${coupleId}`).emit('heartbeat_received', {
          senderId,
          senderName,
          pattern: pattern || 'double_pulse',
          timestamp: new Date().toISOString(),
        });

        console.log(`💓 Latido enviado por ${senderName} en sala couple:${coupleId}`);
      } catch (err) {
        console.error('Error al procesar latido:', err);
      }
    });

    // Handle mood updates in real time
    socket.on('mood_changed', (data: { coupleId: string; userId: string; moodStatus: string; moodIcon: string }) => {
      const { coupleId, userId, moodStatus, moodIcon } = data;
      socket.to(`couple:${coupleId}`).emit('partner_mood_updated', {
        userId,
        moodStatus,
        moodIcon,
      });
    });

    // Handle real-time couple data changes (memories, bucket, sticky notes, calendar, places, letters, pet, song, etc.)
    socket.on('couple_data_changed', (data: { coupleId: string; type: string; senderId?: string }) => {
      const { coupleId, type, senderId } = data;
      if (coupleId) {
        socket.to(`couple:${coupleId}`).emit('partner_refresh', {
          type,
          senderId,
          timestamp: new Date().toISOString(),
        });
        console.log(`🔄 Sincronización en tiempo real (${type}) enviada a couple:${coupleId}`);
      }
    });

    // Handle disconnect
    socket.on('disconnect', () => {
      console.log(`❌ Cliente desconectado: ${socket.id}`);
    });
  });
};
