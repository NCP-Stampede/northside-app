import express from 'express';
import { getProfileData, getStudentInfo, getSchedule } from '../controllers/profileController.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// GET /api/profile
router.get('/', auth, getProfileData);

// GET /api/profile/studentInfo
router.get('/studentInfo', auth, getStudentInfo);

// GET /api/profile/schedule
router.get('/schedule', auth, getSchedule);

export default router;