import Event from '../models/Event.js';

// Get events by month and year
export const getEvents = async (req, res) => {
  try {
    const { month, year } = req.query;
    
    let query = {};
    
    // Filter by month and year if provided
    if (month && year) {
      const startDate = new Date(year, month - 1, 1);
      const endDate = new Date(year, month, 0); // Last day of the month
      query.date = { $gte: startDate, $lte: endDate };
    }
    
    const events = await Event.find(query).sort({ date: 1 });
    
    res.status(200).json(events);
  } catch (error) {
    console.error('Get events error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get events for a specific date
export const getEventsByDate = async (req, res) => {
  try {
    const { date } = req.params; // Format: YYYY-MM-DD
    
    const [year, month, day] = date.split('-').map(Number);
    
    const startDate = new Date(year, month - 1, day);
    const endDate = new Date(year, month - 1, day, 23, 59, 59);
    
    const events = await Event.find({
      date: { $gte: startDate, $lte: endDate }
    }).sort({ date: 1 });
    
    res.status(200).json(events);
  } catch (error) {
    console.error('Get events by date error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};