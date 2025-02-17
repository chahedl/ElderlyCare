
const Location = require('../models/location');

// Create a new location
const createLocation = async (req, res) => {
    try {
        const { latitude, longitude, address } = req.body;
        
        // Validate required fields
        if (!latitude || !longitude) {
            return res.status(400).json({ error: 'Latitude and longitude are required' });
        }

        const location = new Location({
            latitude,
            longitude,
            address
        });

        const savedLocation = await location.save();
        res.status(201).json(savedLocation);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get all locations
const getLocations = async (req, res) => {
    try {
        const locations = await Location.find();
        res.status(200).json(locations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get a single location by ID
const getLocationById = async (req, res) => {
    try {
        const location = await Location.findById(req.params.id);
        if (!location) {
            return res.status(404).json({ error: 'Location not found' });
        }
        res.status(200).json(location);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Update a location
const updateLocation = async (req, res) => {
    try {
        const { latitude, longitude, address } = req.body;
        
        const updatedLocation = await Location.findByIdAndUpdate(
            req.params.id,
            { latitude, longitude, address },
            { new: true }
        );

        if (!updatedLocation) {
            return res.status(404).json({ error: 'Location not found' });
        }

        res.status(200).json(updatedLocation);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Delete a location
const deleteLocation = async (req, res) => {
    try {
        const deletedLocation = await Location.findByIdAndDelete(req.params.id);
        if (!deletedLocation) {
            return res.status(404).json({ error: 'Location not found' });
        }
        res.status(200).json({ message: 'Location deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    createLocation,
    getLocations,
    getLocationById,
    updateLocation,
    deleteLocation
};