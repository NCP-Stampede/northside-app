import express from 'express';
import { getHoofbeat, getArticleBySlug } from '../controllers/hoofbeatController.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// GET /api/hoofbeat
router.get('/', auth, getHoofbeat);

// GET /api/hoofbeat/:slug
router.get('/:slug', auth, getArticleBySlug);

export default router;