import express from 'express';
import { login, logout, register } from '../controllers/authController.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// POST /api/auth/login
router.post('/login', login);

// POST /api/auth/logout
router.post('/logout', auth, logout);

// POST /api/auth/register (admin only)
router.post('/register', auth, register);

export default router;