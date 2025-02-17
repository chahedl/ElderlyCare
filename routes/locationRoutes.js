const express = require('express');
const router = express.Router();
const {
    createLocation,
    getLocations,
    getLocationById,
    updateLocation,
    deleteLocation
} = require('../controllers/LocationController');

// Create a new location
router.post('/create', createLocation);

// Get all locations
router.get('/get', getLocations);

// Get a single location by ID
router.get('/:id', getLocationById);

// Update a location
router.put('/:id', updateLocation);

// Delete a location
router.delete('/:id', deleteLocation);

module.exports = router;
