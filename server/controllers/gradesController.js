import Grade from '../models/Grade.js';

// Get all grades for a student
export const getGrades = async (req, res) => {
  try {
    const { filter } = req.query;
    const userId = req.user.userId;
    
    let grades = await Grade.find({ student: userId });
    
    // Apply filter if needed
    if (filter === 'currentTerm') {
      // For demo purposes, just return first 4 grades
      grades = grades.slice(0, 4);
    }
    
    res.status(200).json(grades);
  } catch (error) {
    console.error('Get grades error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get grade details for a course
export const getGradeDetails = async (req, res) => {
  try {
    const { courseId } = req.params;
    const userId = req.user.userId;
    
    const grade = await Grade.findOne({
      _id: courseId,
      student: userId
    });
    
    if (!grade) {
      return res.status(404).json({ message: 'Grade details not found for this course.' });
    }
    
    res.status(200).json(grade);
  } catch (error) {
    console.error('Get grade details error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};