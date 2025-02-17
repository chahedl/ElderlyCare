const jwt = require("jsonwebtoken");
const User = require("../models/User");
require("dotenv").config();

/**
 * Generate JWT token
 * @param {string} userId - The user's ID from the database
 * @returns {string} token - A signed JWT token
 */
async function generateToken(userId) {
  try {
    const token = await jwt.sign({ userId }, process.env.JWT_SECRET, {
      expiresIn: "7d", // Token validity duration
    });
    return token;
  } catch (error) {
    console.error("Error generating token:", error.message);
    throw new Error("Failed to generate token");
  }
}

/**
 * Middleware to verify JWT token
 * Ensures that the user is authenticated before accessing protected routes.
 */
async function verifyToken(req, res, next) {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1]; // Extract the token from the header

  if (!token) {
    return res.status(401).json({ message: "Access denied. No token provided." });
  }

  try {
    // Verify the token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId; // Add user ID to the request object for future use

    // Check if the user exists in the database
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    req.user = user; // Attach the user to the request object
    next(); // Move to the next middleware or route handler
  } catch (error) {
    console.error("Error verifying token:", error.message);
    res.status(403).json({ message: "Invalid or expired token" });
  }
}

module.exports = {
  generateToken,
  verifyToken,
};
