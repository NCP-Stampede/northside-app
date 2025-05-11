import express from 'express';

const router = express.Router();

// Placeholder route for athletics
router.get('/', (req, res) => {
  res.send('Athletics API is working');
});

export default router;
