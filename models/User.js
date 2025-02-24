const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

// Define an enum for Role
const roles = ['ADMIN', 'USER', 'GUEST','DOCTOR'];

// User Schema
const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  password: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    unique: true,
    sparse: true, // Allow for null values in unique index
  },
  phoneNumber: {
    type: String,
    unique: true,
    sparse: true, // Allow for null values in unique index
  },
  dateOfBirth: {
    type: Date,
  },
  height: {
    type: Number, // Float in JavaScript is represented as Number
    required: true,
  },
  weight: {
    type: Number, // Float in JavaScript is represented as Number
    required: true,
  },
  chronic: {
    type: String, // Describes chronic illness/condition
    required: false,
    trim: true,
  },
  profilePic: {
    type: String, // Optional profile picture URL
    required: false,
  },
  role: {
    type: String,
    enum: roles,
    default: 'USER',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Hash the password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Export the model
module.exports = mongoose.model('User', userSchema);
