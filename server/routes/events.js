import express from 'express';
import { getEvents, getEventsByDate } from '../controllers/eventsController.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// GET /api/events
router.get('/', auth, getEvents);

// GET /api/events/:date
router.get('/:date', auth, getEventsByDate);

export default router;