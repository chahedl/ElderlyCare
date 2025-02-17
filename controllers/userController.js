const bcrypt = require('bcrypt');
const User = require('../models/User');
const { generateToken } = require('../middleware/authMiddleware');

/**
 * User registration
 */
async function registerUser(req, res) {
  const { username, password, email, birthDate, chronicIllnesses, height, weight, profilePic, role } = req.body;

  try {
    // Check if the email already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email already in use" });
    }

    // Create a new user
    const user = new User({
      username,
      password,
      email,
      birthDate,
      chronicIllnesses,
      height,
      weight,
      profilePic,
      role: role ? role.toUpperCase() : "USER", // Convert role to uppercase

    });

    // Save the user to the database
    await user.save();

    // Generate JWT token
    const token = await generateToken(user._id);

    // Respond with the user data and token
    res.status(201).json({ message: "User registered successfully", token, user });
  } catch (error) {
    console.error("Error registering user:", error.message);
    res.status(500).json({ message: "Server error" });
  }
}

/**
 * User login
 */
async function loginUser(req, res) {
  const { email, password } = req.body;

  try {
    // Find the user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Check if the password matches
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid password" });
    }

    // Generate JWT token
    const token = await generateToken(user._id);

    // Respond with the user data and token
    res.json({ message: "Login successful", token, user });
  } catch (error) {
    console.error("Error logging in:", error.message);
    res.status(500).json({ message: "Server error" });
  }
}

/**
 * Get the authenticated user's profile data
 */
async function getUserProfile(req, res) {
  try {
    const user = await User.findById(req.userId); // User's ID is attached in `req.userId` after token verification
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({ user });
  } catch (error) {
    console.error("Error fetching user profile:", error.message);
    res.status(500).json({ message: "Server error" });
  }
}

/**
 * Update user profile (e.g., update phone number, address, etc.)
 */
async function updateUserProfile(req, res) {
  const { phoneNumber, height, weight, chronic, profilePic } = req.body;

  console.log("User ID:", req.userId); // Log user ID
  console.log("Incoming data:", req.body); // Log incoming data

  try {
    const user = await User.findById(req.userId); // Fetch user from DB
    if (!user) {
      console.log("User not found for ID:", req.userId); // Log if user not found
      return res.status(404).json({ message: "User not found" });
    }

    // Update the user's profile with the provided data
    if (phoneNumber) user.phoneNumber = phoneNumber;
    if (height) user.height = height;
    if (weight) user.weight = weight;
    if (chronic) user.chronic = chronic;
    if (profilePic) user.profilePic = profilePic; // Update profilePic if provided

    await user.save();

    res.json({ message: "User profile updated successfully", user });
  } catch (error) {
    console.error("Error updating user profile:", error.message);
    res.status(500).json({ message: "Server error" });
  }
}

module.exports = {
  registerUser,
  loginUser,
  getUserProfile,
  updateUserProfile,
};
