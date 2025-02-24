const express = require('express');
const router = express.Router();
const doctorController = require('../controllers/DoctorController');
const { check } = require('express-validator');
const { verifyToken } = require('../middleware/authMiddleware');


// Validation rules for doctor creation
const doctorValidation = [
    check('name').notEmpty().withMessage('Name is required'),
    check('specialization').isIn([
        'General', 'Lungs Specialist', 'Dentist', 'Psychiatrist',
        'Covid-19', 'Surgeon', 'Cardiologist', 'Pediatrician',
        'Dermatologist', 'Neurologist', 'Orthopedist', 'Gynecologist',
        'Urologist', 'Ophthalmologist', 'Endocrinologist', 'Radiologist'
    ]).withMessage('Invalid specialization'),
    check('location.coordinates')
        .isArray({ min: 2, max: 2 })
        .withMessage('Coordinates must be an array of 2 numbers'),
    check('location.coordinates.*')
        .isFloat()
        .withMessage('Coordinates must be numbers'),
    check('userId').isMongoId().withMessage('Invalid user ID')
];

// Doctor routes
router.post('/createD', verifyToken, doctorValidation, doctorController.createDoctor);

router.get('/getD', verifyToken, doctorController.getDoctors);

router.get('/nearby', verifyToken, doctorController.getNearbyDoctors);

router.get('/:id', verifyToken, doctorController.getDoctorById);

router.put('/:id', verifyToken, doctorController.updateDoctor);

router.delete('/:id', verifyToken, doctorController.deleteDoctor);


module.exports = router;
