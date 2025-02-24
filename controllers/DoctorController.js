const { Doctor } = require('../models/Doctor');
const mongoose = require('mongoose');

const { validationResult } = require('express-validator');

// Create a new doctor
const createDoctor = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        // Verify user has DOCTOR role
        if (req.user.role !== 'DOCTOR') {
            return res.status(403).json({ 
                message: 'Only users with DOCTOR role can create doctor profiles' 
            });
        }

        // Check if doctor profile already exists
        const existingDoctor = await Doctor.findById(req.user._id);
        if (existingDoctor) {
            return res.status(400).json({ 
                message: 'Doctor profile already exists for this user' 
            });
        }

        // Create doctor profile using user ID as _id
        const doctorData = {
            _id: req.user._id,
            name: req.user.username, // Default to username
            email: req.user.email, // Use user's email
            ...req.body
        };

        
        // Create and save doctor profile
        const doctor = new Doctor(doctorData);


        await doctor.save();
        
        // Return combined user and doctor information
        const doctorProfile = {
            ...doctor.toObject(),
            user: {
                username: req.user.username,
                email: req.user.email,
                role: req.user.role
            }
        };
        
        res.status(201).json({
            message: 'Doctor profile created successfully',
            doctor: doctorProfile
        });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// Get all doctors with optional filtering
const getDoctors = async (req, res) => {
    try {
        const { specialization, available } = req.query;
        const filter = {};
        
        if (specialization) {
            filter.specialization = specialization;
        }
        if (available) {
            filter.availability = available === 'true';
        }

        const doctors = await Doctor.find(filter);
        res.json(doctors);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get a single doctor by ID
const getDoctorById = async (req, res) => {
    try {
        const { id } = req.params;
        
        // Validate ID format
        if (!mongoose.Types.ObjectId.isValid(id)) {
            return res.status(400).json({ 
                message: 'Invalid doctor ID format',
                receivedId: id
            });
        }

        // Find doctor by ID and populate user data
        const doctor = await Doctor.findById(id)
            .populate('_id', 'username email role');

        if (!doctor) {
            return res.status(404).json({ 
                message: 'Doctor not found',
                searchedId: id
            });
        }
        
        res.json(doctor);
    } catch (error) {
        console.error('Error fetching doctor:', error);
        res.status(500).json({ 
            error: error.message,
            stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
        });
    }
};

// Update a doctor
const updateDoctor = async (req, res) => {
    try {
        const doctor = await Doctor.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );
        if (!doctor) {
            return res.status(404).json({ message: 'Doctor not found' });
        }
        res.json(doctor);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

// Delete a doctor
const deleteDoctor = async (req, res) => {
    try {
        const doctor = await Doctor.findByIdAndDelete(req.params.id);
        if (!doctor) {
            return res.status(404).json({ message: 'Doctor not found' });
        }
        res.json({ message: 'Doctor deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get nearby doctors within a specified radius
const getNearbyDoctors = async (req, res) => {
    try {
        const { longitude, latitude, maxDistance } = req.query;
        
        if (!longitude || !latitude || !maxDistance) {
            return res.status(400).json({ 
                message: 'Longitude, latitude and maxDistance are required' 
            });
        }

        const doctors = await Doctor.find({
            location: {
                $near: {
                    $geometry: {
                        type: "Point",
                        coordinates: [parseFloat(longitude), parseFloat(latitude)]
                    },
                    $maxDistance: parseFloat(maxDistance)
                }
            }
        });

        res.json(doctors);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    createDoctor,
    getDoctors,
    getDoctorById,
    updateDoctor,
    deleteDoctor,
    getNearbyDoctors
};
