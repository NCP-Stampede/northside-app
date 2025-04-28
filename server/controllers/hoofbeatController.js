import Article from '../models/Article.js';

// Get main hoofbeat content (headline, trending, news)
export const getHoofbeat = async (req, res) => {
  try {
    // Get headline article
    const headline = await Article.findOne({ tag: 'HEADLINE' }).sort({ date: -1 });
    
    // Get trending articles
    const trending = await Article.find({ tag: 'TRENDING' }).sort({ date: -1 }).limit(3);
    
    // Get news articles
    const news = await Article.find({ tag: 'NEWS' }).sort({ date: -1 }).limit(3);
    
    res.status(200).json({
      headline,
      trending,
      news
    });
  } catch (error) {
    console.error('Get hoofbeat error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get article details by slug
export const getArticleBySlug = async (req, res) => {
  try {
    const { slug } = req.params;
    
    const article = await Article.findOne({ slug });
    
    if (!article) {
      return res.status(404).json({ message: 'Article not found' });
    }
    
    res.status(200).json(article);
  } catch (error) {
    console.error('Get article details error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};