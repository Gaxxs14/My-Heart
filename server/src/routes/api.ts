import { Router } from 'express';
import { register, login, quickStart, quickLink, getProfile, updateProfile, updateMood, deleteAccount, updateFcmToken } from '../controllers/auth.controller';
import { getPairingStatus, createPairingCode, linkPartnerByCode, updateCoupleSettings } from '../controllers/couple.controller';
import { getTodayQuestion, answerQuestion, getAnswerHistory } from '../controllers/questions.controller';
import { createMemory, getMemories } from '../controllers/memories.controller';
import { createBucketItem, getBucketList, toggleBucketItem } from '../controllers/bucket.controller';
import { createSecretLetter, getLetters } from '../controllers/letters.controller';
import { createStickyNote, getStickyNotes, deleteStickyNote } from '../controllers/sticky_notes.controller';
import { createCalendarEvent, getCalendarEvents, deleteCalendarEvent } from '../controllers/calendar.controller';
import { createPlace, getPlaces } from '../controllers/places.controller';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Health Check
router.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'My Heart API', time: new Date().toISOString() });
});

// Auth Routes (Public)
router.post('/auth/register', register);
router.post('/auth/login', login);
router.post('/auth/quick-start', quickStart);
router.post('/auth/quick-link', quickLink);

// Protected Routes (Require JWT)
router.use(authenticateToken);

// User & Mood
router.get('/auth/profile', getProfile);
router.patch('/auth/profile', updateProfile);
router.patch('/auth/mood', updateMood);
router.patch('/auth/fcm-token', updateFcmToken);
router.delete('/auth/delete-account', deleteAccount);

// Couple & Pairing
router.get('/couple/status', getPairingStatus);
router.post('/couple/create-code', createPairingCode);
router.post('/couple/link-code', linkPartnerByCode);
router.patch('/couple/settings', updateCoupleSettings);

// Daily Sparks (Questions)
router.get('/questions/today', getTodayQuestion);
router.post('/questions/answer', answerQuestion);
router.get('/questions/history', getAnswerHistory);

// Timeline & Memories
router.post('/memories', createMemory);
router.get('/memories', getMemories);

// Bucket List
router.post('/bucket', createBucketItem);
router.get('/bucket', getBucketList);
router.patch('/bucket/:id', toggleBucketItem);

// Secret Letters & Time Capsule
router.post('/letters', createSecretLetter);
router.get('/letters', getLetters);

// Sticky Notes (Post-its)
router.get('/sticky-notes', getStickyNotes);
router.post('/sticky-notes', createStickyNote);
router.delete('/sticky-notes/:id', deleteStickyNote);

// Couple Calendar
router.get('/calendar', getCalendarEvents);
router.post('/calendar', createCalendarEvent);
router.delete('/calendar/:id', deleteCalendarEvent);

// Romantic Places
router.get('/places', getPlaces);
router.post('/places', createPlace);

export default router;
