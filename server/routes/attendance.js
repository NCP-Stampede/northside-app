import express from 'express';
import { getAttendance, getTardyDetails } from '../controllers/attendanceController.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// GET /api/attendance
router.get('/', auth, getAttendance);

// GET /api/attendance/:tardyId
router.get('/:tardyId', auth, getTardyDetails);

export default router;