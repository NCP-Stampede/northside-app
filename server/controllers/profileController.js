import User from '../models/User.js';

// Get profile data for a student
export const getProfileData = async (req, res) => {
  try {
    const userId = req.user.userId;
    
    const user = await User.findById(userId);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.status(200).json({
      name: user.name,
      gradeLevel: user.studentInfo?.grade,
      school: user.studentInfo?.school,
      profilePicUrl: user.studentInfo?.profilePicUrl
    });
  } catch (error) {
    console.error('Get profile data error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get detailed student information
export const getStudentInfo = async (req, res) => {
  try {
    const userId = req.user.userId;
    
    const user = await User.findById(userId);
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.status(200).json({
      firstName: user.studentInfo?.firstName,
      lastName: user.studentInfo?.lastName,
      middleInitial: user.studentInfo?.middleInitial,
      studentId: user.studentInfo?.studentId,
      grade: user.studentInfo?.grade,
      dob: user.studentInfo?.dob
    });
  } catch (error) {
    console.error('Get student info error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get student schedule
export const getSchedule = async (req, res) => {
  try {
    const userId = req.user.userId;
    
    // This would typically come from a Schedule model
    // For demo purposes, we're returning static data
    const today = new Date();
    
    res.status(200).json({
      date: today.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' }),
      blocks: [
        { id: "b1", number: "1", course: "HS1 Algebra 1", courseId: "alg1" },
        { id: "b2", number: "2", course: "HS1 US History", courseId: "ush" },
        { id: "bC", number: "C", course: "HS1 AP Lang", courseId: "aplang" },
        { id: "bD", number: "D", course: "Student Meal", courseId: null },
        { id: "b4", number: "4", course: "HS1 Physics", courseId: "phys" }
      ]
    });
  } catch (error) {
    console.error('Get schedule error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};