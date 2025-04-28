import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.js';
import gradesRoutes from './routes/grades.js';
import eventsRoutes from './routes/events.js';
import athleticsRoutes from './routes/athletics.js';
import hoofbeatRoutes from './routes/hoofbeat.js';
import flexesRoutes from './routes/flexes.js';
import profileRoutes from './routes/profile.js';
import attendanceRoutes from './routes/attendance.js';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB connection error:', err));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/grades', gradesRoutes);
app.use('/api/events', eventsRoutes);
app.use('/api/athletics', athleticsRoutes);
app.use('/api/hoofbeat', hoofbeatRoutes);
app.use('/api/flexes', flexesRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/attendance', attendanceRoutes);

// Basic route
app.get('/', (req, res) => {
  res.send('Northside App API is running');
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});