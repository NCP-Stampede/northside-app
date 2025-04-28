import User from '../models/User.js';
import jwt from 'jsonwebtoken';

// Login user
export const login = async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // Find user by username
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }
    
    // Check password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }
    
    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    res.status(200).json({
      success: true,
      token,
      user: {
        name: user.name,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Logout user
export const logout = async (req, res) => {
  // Since JWT is stateless, actual logout happens on client
  // This endpoint is mostly for future expansion
  res.status(200).json({ success: true });
};

// Register user (admin only)
export const register = async (req, res) => {
  try {
    // Check if admin
    if (req.user?.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized' });
    }
    
    const { username, password, name, role, studentInfo } = req.body;
    
    // Check if username already exists
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: 'Username already exists' });
    }
    
    // Create new user
    const user = new User({
      username,
      password,
      name,
      role,
      studentInfo
    });
    
    await user.save();
    
    res.status(201).json({
      success: true,
      message: 'User created successfully'
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};