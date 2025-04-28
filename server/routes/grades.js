import express from 'express';
import { getGrades, getGradeDetails } from '../controllers/gradesController.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// GET /api/grades
router.get('/', auth, getGrades);

// GET /api/grades/:courseId
router.get('/:courseId', auth, getGradeDetails);

export default router;