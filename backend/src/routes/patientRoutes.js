const express = require('express');
const router = express.Router();
const Patient = require('../models/Patient');
const DoctorSchedule = require('../models/DoctorSchedule');
const PatientSchedule = require('../models/PatientSchedule');

// GET /api/patients - list with optional filters: doctorId, clinicId, isActive, search
router.get('/', async (req, res) => {
  try {
    const { doctorId, clinicId, isActive, search } = req.query;
    const query = {};
    if (doctorId) query.doctorId = Number(doctorId);
    if (clinicId) query.clinicId = Number(clinicId);
    if (typeof isActive !== 'undefined') query.isActive = isActive === 'true';
    if (search) {
      const rx = new RegExp(search, 'i');
      query.$or = [{ name: rx }, { fatherName: rx }, { email: rx }, { cnic: rx }, { mobileNumber: rx }];
    }
    const patients = await Patient.find(query).sort({ createdAt: -1 });
    res.status(200).json({ success: true, count: patients.length, data: patients });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/patients/counts - get patient counts for clinics
router.get('/counts', async (req, res) => {
  try {
    const { doctorId } = req.query;
    if (!doctorId) {
      return res.status(400).json({ success: false, message: 'Doctor ID is required' });
    }
    
    const counts = await Patient.aggregate([
      { $match: { doctorId: Number(doctorId) } },
      { $group: { _id: '$clinicId', count: { $sum: 1 } } }
    ]);
    
    const result = {};
    counts.forEach(item => {
      result[item._id] = item.count;
    });
    
    res.status(200).json({ success: true, data: result });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/patients/:patientId
router.get('/:patientId', async (req, res) => {
  try {
    const item = await Patient.findOne({ patientId: Number(req.params.patientId) });
    if (!item) return res.status(404).json({ success: false, message: 'Patient not found' });
    res.status(200).json({ success: true, data: item });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/patients
router.post('/', async (req, res) => {
  try {
    const payload = req.body || {};
    
    // Create the patient (no validation checks)
    const created = await Patient.create(payload);
    
    // Get all active schedules for this doctor
    const doctorSchedules = await DoctorSchedule.find({ 
      doctorId: Number(payload.doctorId),
      isActive: true 
    });
    
    // Create PatientSchedule entries for each doctor schedule (including planDate)
    // Use create() instead of insertMany() to trigger pre('save') hooks for auto-increment
    if (doctorSchedules.length > 0 && created.patientId) {
      for (const doctorSchedule of doctorSchedules) {
        await PatientSchedule.create({
          childId: created.patientId,
          doseId: doctorSchedule.doseId,
          planDate: doctorSchedule.planDate || null, // Copy planDate from doctor's schedule
          givenDate: null,
          brandId: null,
        });
      }
    }
    
    res.status(201).json({ success: true, data: created });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message || 'Failed to create patient' });
  }
});

// PUT /api/patients/:patientId
router.put('/:patientId', async (req, res) => {
  try {
    const updated = await Patient.findOneAndUpdate(
      { patientId: Number(req.params.patientId) },
      req.body || {},
      { new: true, runValidators: false }
    );
    if (!updated) return res.status(404).json({ success: false, message: 'Patient not found' });
    res.status(200).json({ success: true, data: updated });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message || 'Failed to update patient' });
  }
});

// DELETE /api/patients/:patientId
router.delete('/:patientId', async (req, res) => {
  try {
    const deleted = await Patient.findOneAndDelete({ patientId: Number(req.params.patientId) });
    if (!deleted) return res.status(404).json({ success: false, message: 'Patient not found' });
    res.status(200).json({ success: true, message: 'Patient deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;


