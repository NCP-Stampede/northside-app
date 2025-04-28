import express from 'express';
import { getFlexes, getFlexOptions, registerForFlex } from '../controllers/flexesController.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// GET /api/flexes
router.get('/', auth, getFlexes);

// GET /api/flexes/:flexId
router.get('/:flexId', auth, getFlexOptions);

// POST /api/flexes/:flexId/:optionId
router.post('/:flexId/:optionId', auth, registerForFlex);

export default router;