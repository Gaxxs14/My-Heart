import { Router } from 'express';
import { register, login, getProfile, updateMood } from '../controllers/auth.controller';
import { getPairingStatus, createPairingCode, linkPartnerByCode, updateCoupleSettings } from '../controllers/couple.controller';
import { getTodayQuestion, answerQuestion, getAnswerHistory } from '../controllers/questions.controller';
import { createMemory, getMemories } from '../controllers/memories.controller';
import { createBucketItem, getBucketList, toggleBucketItem } from '../controllers/bucket.controller';
import { createSecretLetter, getLetters } from '../controllers/letters.controller';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Health Check
router.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'My Heart API', time: new Date().toISOString() });
});

// Auth Routes (Public)
router.post('/auth/register', register);
router.post('/auth/login', login);

// Protected Routes (Require JWT)
router.use(authenticateToken);

// User & Mood
router.get('/auth/profile', getProfile);
router.patch('/auth/mood', updateMood);

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

export default router;
