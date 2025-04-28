import mongoose from 'mongoose';

const flexSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['available', 'upcoming', 'closed'],
    default: 'upcoming'
  },
  options: [{
    title: {
      type: String,
      required: true
    },
    room: String,
    teacher: String,
    capacity: {
      type: Number,
      default: 30
    },
    enrolled: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }]
  }]
}, {
  timestamps: true
});

const Flex = mongoose.model('Flex', flexSchema);

export default Flex;