import Attendance from '../models/Attendance.js';

// Get attendance summary and tardies for a student
export const getAttendance = async (req, res) => {
  try {
    const userId = req.user.userId;
    
    // Get attendance counts
    const present = await Attendance.countDocuments({ student: userId, status: 'present' });
    const tardy = await Attendance.countDocuments({ student: userId, status: 'tardy' });
    const absent = await Attendance.countDocuments({ student: userId, status: 'absent' });
    
    // Get tardy records
    const tardies = await Attendance.find({ 
      student: userId, 
      status: 'tardy' 
    }).sort({ date: -1 });
    
    res.status(200).json({
      summary: { present, tardy, absent },
      tardies: tardies.map(t => ({
        id: t._id,
        course: t.course,
        teacher: t.teacher,
        date: t.date.toLocaleDateString('en-US', { month: 'long', day: 'numeric' })
      }))
    });
  } catch (error) {
    console.error('Get attendance error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get details for a specific tardy record
export const getTardyDetails = async (req, res) => {
  try {
    const { tardyId } = req.params;
    const userId = req.user.userId;
    
    const tardy = await Attendance.findOne({
      _id: tardyId,
      student: userId,
      status: 'tardy'
    });
    
    if (!tardy) {
      return res.status(404).json({ message: 'Tardy record not found' });
    }
    
    res.status(200).json({
      id: tardy._id,
      course: tardy.course,
      teacher: tardy.teacher,
      date: tardy.date.toLocaleDateString('en-US', { month: 'long', day: 'numeric' }),
      time: tardy.time,
      details: tardy.details,
      excused: tardy.excused
    });
  } catch (error) {
    console.error('Get tardy details error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};