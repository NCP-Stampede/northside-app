import mongoose from 'mongoose';

const attendanceSchema = new mongoose.Schema({
  student: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ['present', 'tardy', 'absent'],
    required: true
  },
  course: String,
  teacher: String,
  time: String,
  details: String,
  excused: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

const Attendance = mongoose.model('Attendance', attendanceSchema);

export default Attendance;