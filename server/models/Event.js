import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  time: {
    type: String
  },
  location: {
    type: String
  },
  description: {
    type: String
  }
}, {
  timestamps: true
});

const Event = mongoose.model('Event', eventSchema);

export default Event;