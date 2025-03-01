const mongoose = require('mongoose');

const DoctorSchema = new mongoose.Schema({
    _id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    firstName: {

        type: String,
        required: [true, 'Name is required'],
        trim: true,
        minlength: [2, 'Name must be at least 2 characters long'],
        match: [/^[a-zA-Z\s]*$/, 'Name can only contain letters and spaces'],
        unique: true
    },

    specialization: {
        type: String,
        enum: {
            values: [
                'General', 'Lungs Specialist', 'Dentist', 'Psychiatrist',
                'Covid-19', 'Surgeon', 'Cardiologist', 'Pediatrician',
                'Dermatologist', 'Neurologist', 'Orthopedist', 'Gynecologist',
                'Urologist', 'Ophthalmologist', 'Endocrinologist', 'Radiologist'
            ],
            message: '{VALUE} is not a valid specialization'
        },
        required: [true, 'Specialization is required']
    },
    rating: {
        type: Number,
        default: 0,
        min: [0, 'Rating cannot be less than 0'],
        max: [5, 'Rating cannot be more than 5'],
        set: (value) => parseFloat(value.toFixed(1)) // Ensure rating is stored with 1 decimal place
    },
    distance: {
        type: Number,
        default: 0,
        min: [0, 'Distance cannot be negative']
    },
    lastName: {
        type: String,
        required: [true, 'Last name is required'],
        trim: true,
        minlength: [2, 'Last name must be at least 2 characters long'],
        match: [/^[a-zA-Z\s]*$/, 'Last name can only contain letters and spaces']
    },
    profilePicture: {

        type: String,
        default: ''
    },
    email: {
        type: String,
        required: [true, 'Email is required'],
        unique: true,
        match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, 'Please fill a valid email address']
    },

    availability: {
        type: Boolean,
        default: true
    },
    location: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: {
            type: [Number],
            required: [true, 'Coordinates are required'],
            validate: {
                validator: (value) => {
                    return value.length === 2 && 
                           value[0] >= -180 && value[0] <= 180 && // Longitude range
                           value[1] >= -90 && value[1] <= 90;     // Latitude range
                },
                message: 'Invalid coordinates. Longitude must be between -180 and 180, and latitude between -90 and 90.'
            }
        }
    },

    reviews: [
        {
            userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
            rating: {
                type: Number,
                min: [0, 'Rating cannot be less than 0'],
                max: [5, 'Rating cannot be more than 5']
            },
            comment: {
                type: String,
                trim: true,
                minlength: [10, 'Comment must be at least 10 characters long']
            }
        }
    ]
}, { timestamps: true });

// Index for geolocation queries
DoctorSchema.index({ location: '2dsphere' });

// Virtual field to calculate average rating
DoctorSchema.virtual('averageRating').get(function () {
    if (this.reviews.length === 0) return 0;
    const total = this.reviews.reduce((sum, review) => sum + review.rating, 0);
    return parseFloat((total / this.reviews.length).toFixed(1));
});

const Doctor = mongoose.model('Doctor', DoctorSchema);
module.exports = { Doctor };
