const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        // Ensure you're using the MONGO_URI from the .env file
        const mongoURI = process.env.MONGO_URI;

        if (!mongoURI) {
            console.error("MONGO_URI is not set in the .env file");
            process.exit(1);
        }

        await mongoose.connect(mongoURI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });

        console.log('MongoDB connected');
    } catch (error) {
        console.error('Error connecting to MongoDB:', error.message);
        process.exit(1);
    }
};

module.exports = connectDB;
