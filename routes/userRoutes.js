const express = require('express');
const {
  registerUser,
  loginUser,
  getUserProfile,
  updateUserProfile
} = require('../controllers/userController');
const { verifyToken } = require('../middleware/authMiddleware');

const router = express.Router();

// User Registration
router.post('/register', registerUser);

// User Login
router.post('/login', loginUser);

// Get User Profile (Protected Route)
router.get('/profile-details', verifyToken, getUserProfile);

// Update User Profile (Protected Route)
router.put('/profile-update', verifyToken, updateUserProfile);

module.exports = router;
