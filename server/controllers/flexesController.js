import Flex from '../models/Flex.js';
import mongoose from 'mongoose';

// Get all available flexes
export const getFlexes = async (req, res) => {
  try {
    const flexes = await Flex.find().select('name status');
    res.status(200).json(flexes);
  } catch (error) {
    console.error('Get flexes error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get flex options for a specific flex period
export const getFlexOptions = async (req, res) => {
  try {
    const { flexId } = req.params;
    
    const flex = await Flex.findById(flexId);
    
    if (!flex) {
      return res.status(404).json({ 
        name: `Flex ${flexId.slice(-1)}`, 
        options: [], 
        status: 'upcoming' 
      });
    }
    
    res.status(200).json({
      name: flex.name,
      options: flex.options,
      status: flex.status
    });
  } catch (error) {
    console.error('Get flex options error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Register for a flex option
export const registerForFlex = async (req, res) => {
  try {
    const { flexId, optionId } = req.params;
    const userId = req.user.userId;
    
    const flex = await Flex.findById(flexId);
    
    if (!flex) {
      return res.status(404).json({ message: 'Flex period not found' });
    }
    
    if (flex.status !== 'available') {
      return res.status(400).json({ message: 'Registration not available for this flex period' });
    }
    
    const option = flex.options.id(optionId);
    
    if (!option) {
      return res.status(404).json({ message: 'Flex option not found' });
    }
    
    // Check if slot is full
    if (option.enrolled.length >= option.capacity) {
      return res.status(400).json({ message: 'Registration failed: Slot is full.' });
    }
    
    // Check if user is already registered for this flex
    const alreadyRegistered = flex.options.some(opt => 
      opt.enrolled.some(id => id.toString() === userId)
    );
    
    if (alreadyRegistered) {
      // Unregister from other options first
      flex.options.forEach(opt => {
        opt.enrolled = opt.enrolled.filter(id => id.toString() !== userId);
      });
    }
    
    // Register for the selected option
    option.enrolled.push(mongoose.Types.ObjectId(userId));
    
    await flex.save();
    
    res.status(200).json({ success: true, message: 'Successfully registered.' });
  } catch (error) {
    console.error('Register for flex error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};