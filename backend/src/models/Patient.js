const mongoose = require('mongoose');

const EmergencyContactSchema = new mongoose.Schema(
  {
    name: { type: String, trim: true },
    relation: { type: String, trim: true },
    phone: { type: String, trim: true },
  },
  { _id: false }
);

const PatientSchema = new mongoose.Schema(
  {
    patientId: { type: Number, unique: true, index: true },
    name: { type: String, required: true, trim: true },
    fatherName: { type: String, trim: true },
    gender: { type: String, enum: ['Male', 'Female', 'Other'], required: true },
    dateOfBirth: { type: Date, required: true },
    email: { type: String, trim: true },
    cnic: { type: String, trim: true },
    mobileNumber: { type: String, trim: true },
    city: { type: String, trim: true },
    address: { type: String, trim: true, default: '' },
    emergencyContact: { type: EmergencyContactSchema, default: {} },
    medicalHistory: { type: String, trim: true, default: '' },
    allergies: { type: String, trim: true, default: '' },
    bloodGroup: { type: String, trim: true },
    clinicId: { type: Number, required: true, index: true },
    doctorId: { type: Number, required: true, index: true },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

// Auto-increment patientId
PatientSchema.pre('save', async function setIncrement(next) {
  if (this.patientId) return next();
  try {
    const latest = await mongoose
      .model('Patient')
      .findOne({}, { patientId: 1 })
      .sort({ patientId: -1 })
      .lean();
    this.patientId = latest && latest.patientId ? latest.patientId + 1 : 1;
    next();
  } catch (err) {
    next(err);
  }
});

module.exports = mongoose.model('Patient', PatientSchema);


