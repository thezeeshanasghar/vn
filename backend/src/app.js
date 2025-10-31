const path = require('path');
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const swaggerUi = require('swagger-ui-express');
const swaggerSpecs = require('./config/swagger');
const connectDB = require('./config/database');

// Import routes
const vaccineRoutes = require('./routes/vaccineRoutes');
const doseRoutes = require('./routes/doseRoutes');
const brandRoutes = require('./routes/brandRoutes');
const doctorRoutes = require('./routes/doctorRoutes');
const authRoutes = require('./routes/authRoutes');
const clinicRoutes = require('./routes/clinicRoutes');
const patientRoutes = require('./routes/patientRoutes');
const doctorScheduleRoutes = require('./routes/doctorScheduleRoutes');

// Load environment variables
require('dotenv').config({ path: path.join(__dirname, '..', 'config.env') });

// Connect to database
connectDB();

// Fix legacy indexes and ensure expected ones exist
// We run this after connection is initiated; operations will await driver readiness
(async () => {
  try {
    const Patient = require('./models/Patient');
    // Drop legacy unique index on mobileNumber if it exists
    try {
      const exists = await Patient.collection.indexExists('mobileNumber_1');
      if (exists) {
        await Patient.collection.dropIndex('mobileNumber_1');
        console.log('🧹 Dropped legacy index: mobileNumber_1');
      }
    } catch (_) {
      // ignore
    }
    // Ensure CNIC unique per clinic index exists (defined in schema, but ensure once)
    try {
      await Patient.collection.createIndex({ clinicId: 1, cnic: 1 }, { unique: true, sparse: true, name: 'clinicId_1_cnic_1_unique' });
      console.log('✅ Ensured index: clinicId_1_cnic_1_unique');
    } catch (_) {
      // ignore
    }
  } catch (e) {
    console.log('Index initialization skipped:', e.message);
  }
})();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Swagger Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpecs, {
  explorer: true,
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Vaccine Management API Documentation'
}));

// Routes
app.use('/api/vaccines', vaccineRoutes);
app.use('/api/doses', doseRoutes);
app.use('/api/brands', brandRoutes);
app.use('/api/doctors', doctorRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/clinics', clinicRoutes);
app.use('/api/patients', patientRoutes);
app.use('/api/doctor-schedules', doctorScheduleRoutes);

/**
 * @swagger
 * /api/health:
 *   get:
 *     summary: Health check endpoint
 *     tags: [System]
 *     responses:
 *       200:
 *         description: API is running successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: Vaccine Management API is running
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *                   example: 2025-10-22T08:19:49.171Z
 */
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Vaccine Management API is running',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Welcome to Vaccine Management System API',
    endpoints: {
      health: '/api/health',
      vaccines: '/api/vaccines',
      doses: '/api/doses',
      brands: '/api/brands',
      doctors: '/api/doctors',
      auth: '/api/auth',
      clinics: '/api/clinics',
      patients: '/api/patients',
      doctorSchedules: '/api/doctor-schedules'
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Something went wrong!',
    error: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
  console.log(`📚 API Documentation: http://localhost:${PORT}/api-docs`);
  console.log(`💉 Vaccines API: http://localhost:${PORT}/api/vaccines`);
  console.log(`💊 Doses API: http://localhost:${PORT}/api/doses`);
  console.log(`🏷️ Brands API: http://localhost:${PORT}/api/brands`);
  console.log(`👨‍⚕️ Doctors API: http://localhost:${PORT}/api/doctors`);
  console.log(`🔐 Auth API: http://localhost:${PORT}/api/auth`);
  console.log(`🏥 Clinics API: http://localhost:${PORT}/api/clinics`);
  console.log(`🧑‍🤝‍🧑 Patients API: http://localhost:${PORT}/api/patients`);
  console.log(`📅 Doctor Schedules API: http://localhost:${PORT}/api/doctor-schedules`);
});
