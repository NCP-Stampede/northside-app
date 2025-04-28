import mongoose from 'mongoose';

const articleSchema = new mongoose.Schema({
  slug: {
    type: String,
    required: true,
    unique: true
  },
  title: {
    type: String,
    required: true
  },
  author: {
    type: String,
    required: true
  },
  date: {
    type: Date,
    default: Date.now
  },
  image: {
    type: String
  },
  content: {
    type: String,
    required: true
  },
  tag: {
    type: String,
    enum: ['HEADLINE', 'TRENDING', 'NEWS', null],
    default: null
  }
}, {
  timestamps: true
});

const Article = mongoose.model('Article', articleSchema);

export default Article;