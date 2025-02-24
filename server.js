const express = require('express');
const dotenv = require('dotenv');
const morgan = require('morgan');
const cors = require('cors');
const connectDB = require('./config/db');
const userRoutes = require('./routes/userRoutes');
const http = require('http');
const bonjour = require('bonjour')();
const locationRoutes = require('./routes/locationRoutes');
const doctorRoutes = require('./routes/DoctorRoutes');



// Load environment variables from .env file
dotenv.config();

if (!process.env.MONGO_URI) {
    console.error("Error: MONGO_URI is not defined in the .env file.");
    process.exit(1);
}
process.env.JWT_SECRET = process.env.JWT_SECRET || 'your_default_secret_key';


const app = express();
const server = http.createServer(app);

// Middleware setup
app.use(express.json({ limit: '10mb' })); // Increase body size limit to 10MB
app.use(express.urlencoded({ limit: '10mb', extended: true })); // For handling form-encoded data
app.use(morgan('dev'));
app.use(cors({ origin: '*' })); // Adjust the origin to restrict access if necessary

// Connect to database
connectDB();

// Use routes
app.use('/api/users', userRoutes);
app.use('/api/locations', locationRoutes);
app.use('/api/doctors', doctorRoutes);


// Define a simple route
app.get('/', (req, res) => res.send('API is running...'));

const PORT = process.env.PORT || 2000;
server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    // Advertise the service via Bonjour (optional, used for network discovery)
    bonjour.publish({ name: 'ElderyCare Server', type: 'http', port: PORT });
});
