# Vaccine Management System - Backend API

A comprehensive Node.js/Express backend API for managing child vaccination schedules, clinics, doctors, patients, and vaccine inventory.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm
- MongoDB (local or via Docker)
- Git

### Installation & Setup

1. **Install Dependencies**
```bash
   npm install
   ```

2. **Configure Environment Variables**
   ```bash
   # Copy the example config file
   cp config.env.example config.env
   
   # Edit config.env with your settings:
   # - MONGODB_URI: MongoDB connection string
   # - PORT: Server port (default: 3000)
   # - JWT_SECRET: Secret key for JWT tokens
   ```

3. **Start MongoDB** (if running locally)
```bash
   # Using Docker:
   docker run -d -p 27017:27017 --name mongodb mongo:latest
   
   # Or use your existing MongoDB instance
   ```

4. **Run the Server**
   ```bash
   # Development mode (with auto-reload):
   npm run dev
   
   # Production mode:
   npm start
   ```

5. **Access the API**
   - API Base URL: `http://localhost:3000`
   - Health Check: `http://localhost:3000/api/health`
   - API Documentation: `http://localhost:3000/api-docs`

## 📁 Project Structure

```
backend/
├── src/
│   ├── app.js                 # Main application entry point
│   ├── config/
│   │   ├── database.js        # MongoDB connection
│   │   └── swagger.js         # API documentation config
│   ├── models/                # Mongoose data models
│   │   ├── Brand.js
│   │   ├── Clinic.js
│   │   ├── Doctor.js
│   │   ├── DoctorSchedule.js  # Doctor vaccination schedules
│   │   ├── Dose.js
│   │   ├── Patient.js
│   │   └── Vaccine.js
│   └── routes/                 # API route handlers
│       ├── authRoutes.js
│       ├── brandRoutes.js
│       ├── clinicRoutes.js
│       ├── doctorRoutes.js
│       ├── doctorScheduleRoutes.js
│       ├── doseRoutes.js
│       ├── patientRoutes.js
│       └── vaccineRoutes.js
├── config.env                  # Environment variables (not in git)
├── config.env.example          # Example config file
├── package.json
├── Dockerfile
└── README.md
```

## 🔌 API Endpoints

### Health & Info
- `GET /api/health` - Health check
- `GET /` - API information

### Authentication
- `POST /api/auth/login` - Doctor login
- `POST /api/auth/verify` - Verify JWT token

### Vaccines
- `GET /api/vaccines` - List all vaccines
- `POST /api/vaccines` - Create vaccine
- `GET /api/vaccines/:id` - Get vaccine by ID
- `PUT /api/vaccines/:id` - Update vaccine
- `DELETE /api/vaccines/:id` - Delete vaccine

### Doses
- `GET /api/doses` - List all doses
- `POST /api/doses` - Create dose
- `GET /api/doses/:id` - Get dose by ID
- `PUT /api/doses/:id` - Update dose
- `DELETE /api/doses/:id` - Delete dose

### Brands
- `GET /api/brands` - List all brands
- `POST /api/brands` - Create brand
- `GET /api/brands/:id` - Get brand by ID
- `PUT /api/brands/:id` - Update brand
- `DELETE /api/brands/:id` - Delete brand

### Doctors
- `GET /api/doctors` - List all doctors
- `POST /api/doctors` - Create doctor
- `GET /api/doctors/:id` - Get doctor by ID
- `PUT /api/doctors/:id` - Update doctor
- `DELETE /api/doctors/:id` - Delete doctor

### Clinics
- `GET /api/clinics` - List clinics (with doctorId filter)
- `POST /api/clinics` - Create clinic
- `GET /api/clinics/:id` - Get clinic by ID
- `PUT /api/clinics/:id` - Update clinic
- `DELETE /api/clinics/:id` - Delete clinic

### Patients
- `GET /api/patients` - List patients (with clinicId filter)
- `POST /api/patients` - Create patient
- `GET /api/patients/:id` - Get patient by ID
- `PUT /api/patients/:id` - Update patient
- `DELETE /api/patients/:id` - Delete patient

### Doctor Schedules
- `GET /api/doctor-schedules?doctorId=X` - Get schedules for doctor
- `POST /api/doctor-schedules` - Create schedule(s)
- `GET /api/doctor-schedules/:scheduleId` - Get schedule by ID
- `PUT /api/doctor-schedules/:scheduleId` - Update schedule (planDate)
- `DELETE /api/doctor-schedules/:scheduleId` - Delete schedule

## 🔐 Environment Variables

Create a `config.env` file in the backend root:

```env
# MongoDB Connection
MONGODB_URI=mongodb://localhost:27017/vaccine_management

# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Secret (change in production!)
JWT_SECRET=your-super-secret-jwt-key-change-in-production
```

## 🐳 Docker Setup

### Using Docker Compose (Recommended)

From the project root:
```bash
docker-compose up -d --build
```

This will start:
- MongoDB container
- Backend API container
- All Flutter web apps

### Standalone Docker

```bash
# Build
docker build -t vaccine-backend .

# Run
docker run -p 3000:3000 --env-file config.env --link mongodb:mongo vaccine-backend
```

## 📚 API Documentation

Swagger documentation is available at:
- URL: `http://localhost:3000/api-docs`
- Interactive API explorer with request/response examples

## 🧪 Testing

```bash
# Health check
curl http://localhost:3000/api/health

# Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"doctor@example.com","password":"password123"}'
```

## 🔧 Development

### Code Structure
- **Models**: Mongoose schemas with auto-increment IDs
- **Routes**: Express route handlers with error handling
- **Config**: Database and Swagger configuration
- **App**: Main Express application setup

### Key Features
- ✅ MongoDB with Mongoose ODM
- ✅ JWT Authentication
- ✅ RESTful API design
- ✅ Swagger API documentation
- ✅ CORS enabled
- ✅ Error handling middleware
- ✅ Auto-increment IDs for custom ID fields

## 📝 Notes

- All custom ID fields (doctorId, scheduleId, etc.) use auto-increment
- MongoDB connection is required at startup
- JWT tokens expire after 1 hour
- All dates use ISO 8601 format

## 🐛 Troubleshooting

**MongoDB Connection Error:**
- Ensure MongoDB is running
- Check MONGODB_URI in config.env
- Verify network connectivity

**Port Already in Use:**
- Change PORT in config.env
- Or stop the process using port 3000

**Missing Dependencies:**
- Run `npm install` again
- Delete node_modules and package-lock.json, then reinstall

---

**Version:** 1.0.0  
**License:** ISC
