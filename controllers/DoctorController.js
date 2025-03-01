const { Doctor } = require('../models/Doctor');
const upload = require('../config/multer');
const { validationResult } = require('express-validator');
const mongoose = require('mongoose');
const { uploadToCloudinary } = require('../utils/cloudinary');
const { response } = require('express');

// Create a new doctor
const createDoctor = async (req, res) => {
    try {
        /*console.log("Request body:", req.body);
        // Log the uploaded file
        console.log("Uploaded file details:", req.file);
        console.log("Response body:", response.body);*/

        // Validate input fields
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        // Extract and parse data
        let { firstName, lastName, email, specialization, availability, location, rating } = req.body;


        
        if (!firstName) return res.status(400).json({ error: "Name is required" });
        if (!specialization) return res.status(400).json({ error: "Invalid specialization" });
        // Remove the check for userId since the admin will create the doctor directly


        // Ensure location is properly formatted
        if (!location || location.type !== 'Point' || !Array.isArray(location.coordinates) || location.coordinates.length !== 2) {
            return res.status(400).json({ error: "Invalid location format. Must be { type: 'Point', coordinates: [longitude, latitude] }" });
        }

        // Handle image upload
        let profilePictureUrl;
        if (req.file) {
            profilePictureUrl = req.file.path; // This is the URL from Cloudinary
            console.log("Profile picture URL:", profilePictureUrl);
        }


        // Create doctor entry
        const doctor = new Doctor({
            firstName,
            lastName,

            email,
            specialization,
            availability: availability === "true",
            location,
            _id: new mongoose.Types.ObjectId(), // Generate a new ObjectId for the doctor

            // Removed userId since the admin will create the doctor directly

            profilePicture: profilePictureUrl,

            rating: parseFloat(rating)
        });

        await doctor.save();

        res.status(201).json({
            message: 'Doctor profile created successfully',
            doctor
        });

    } catch (error) {
        console.error('Error in createDoctor:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// Get all doctors
const getDoctors = async (req, res) => {
    try {
        const doctors = await Doctor.find();
        res.json(doctors);

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get a doctor by ID
const getDoctorById = async (req, res) => {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
        return res.status(400).json({ message: 'Invalid doctor ID format' });
    }
    try {
        const doctor = await Doctor.findById(id);
        if (!doctor) {
            return res.status(404).json({ message: 'Doctor not found' });
        }
        res.json(doctor);
        console.log("Profile picture URL:", doctor.profilePictureUrl);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Update a doctor
const updateDoctor = async (req, res) => {
    const { id } = req.params;
    try {
        const doctor = await Doctor.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });
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
    const { id } = req.params;
    try {
        const doctor = await Doctor.findByIdAndDelete(id);
        if (!doctor) {
            return res.status(404).json({ message: 'Doctor not found' });
        }
        res.json({ message: 'Doctor deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get nearby doctors
const getNearbyDoctors = async (req, res) => {
    const { longitude, latitude, maxDistance } = req.query;
    try {
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
