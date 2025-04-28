import mongoose from 'mongoose';

const gradeSchema = new mongoose.Schema({
  course: {
    type: String,
    required: true
  },
  teacher: {
    type: String,
    required: true
  },
  grade: {
    type: String,
    required: true
  },
  letterGrade: {
    type: String,
    required: true
  },
  isFailing: {
    type: Boolean,
    default: false
  },
  student: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  categories: [{
    name: String,
    percentage: Number,
    score: String
  }],
  assignments: [{
    name: String,
    category: String,
    dueDate: Date,
    score: String
  }]
}, {
  timestamps: true
});

const Grade = mongoose.model('Grade', gradeSchema);

export default Grade;