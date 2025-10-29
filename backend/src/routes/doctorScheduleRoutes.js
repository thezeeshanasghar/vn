const express = require('express');
const router = express.Router();
const DoctorSchedule = require('../models/DoctorSchedule');
const Dose = require('../models/Dose');

// GET /api/doctor-schedules - Get schedules for a doctor
router.get('/', async (req, res) => {
  try {
    const { doctorId } = req.query;
    if (!doctorId) {
      return res.status(400).json({ success: false, message: 'Doctor ID is required' });
    }

    const schedules = await DoctorSchedule.find({ doctorId: Number(doctorId) }).sort({ createdAt: -1 });
    
    // Populate dose information
    const schedulesWithDoses = await Promise.all(
      schedules.map(async (schedule) => {
        const dose = await Dose.findOne({ doseId: schedule.doseId });
        return {
          ...schedule.toObject(),
          dose: dose ? {
            doseId: dose.doseId,
            name: dose.name,
            minAge: dose.minAge,
            maxAge: dose.maxAge,
            minGap: dose.minGap,
            vaccineID: dose.vaccineID,
          } : null,
        };
      })
    );

    res.status(200).json({ success: true, count: schedulesWithDoses.length, data: schedulesWithDoses });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/doctor-schedules - Create multiple schedules for a doctor
router.post('/', async (req, res) => {
  try {
    const { doctorId, doseIds } = req.body;
    
    if (!doctorId || !doseIds || !Array.isArray(doseIds) || doseIds.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Doctor ID and array of dose IDs are required' 
      });
    }

    const doctorIdNum = Number(doctorId);
    
    // Check which doses already exist for THIS SPECIFIC doctor only
    const existingSchedules = await DoctorSchedule.find({ 
      doctorId: doctorIdNum, 
      doseId: { $in: doseIds.map(id => Number(id)) }
    });
    
    const existingDoseIds = existingSchedules.map(s => s.doseId);
    const newDoseIds = doseIds.filter(id => !existingDoseIds.includes(Number(id)));

    if (newDoseIds.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'All selected doses are already in your schedule' 
      });
    }

    // Create new schedules one by one to handle duplicates gracefully
    const createdSchedules = [];
    for (const doseId of newDoseIds) {
      try {
        const schedule = await DoctorSchedule.create({
          doctorId: doctorIdNum,
          doseId: Number(doseId),
          planDate: null,
          isActive: true,
        });
        createdSchedules.push(schedule);
      } catch (createErr) {
        // If duplicate key error, skip this dose (already exists for this doctor)
        if (createErr.code !== 11000) {
          throw createErr;
        }
      }
    }

    if (createdSchedules.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'All selected doses are already in your schedule' 
      });
    }

    res.status(201).json({ 
      success: true, 
      message: `${createdSchedules.length} dose${createdSchedules.length > 1 ? 's' : ''} added to schedule successfully`,
      count: createdSchedules.length,
      data: createdSchedules 
    });
  } catch (err) {
    console.error('Error creating schedules:', err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/doctor-schedules/:scheduleId
router.get('/:scheduleId', async (req, res) => {
  try {
    const schedule = await DoctorSchedule.findOne({ scheduleId: Number(req.params.scheduleId) });
    if (!schedule) {
      return res.status(404).json({ success: false, message: 'Schedule not found' });
    }
    res.status(200).json({ success: true, data: schedule });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// PUT /api/doctor-schedules/:scheduleId - Update schedule (mainly planDate)
router.put('/:scheduleId', async (req, res) => {
  try {
    const updateData = { ...req.body };
    
    // If planDate is provided, ensure it's stored as date-only string (YYYY-MM-DD format)
    if (updateData.planDate) {
      // If it's a Date object, convert to YYYY-MM-DD
      if (updateData.planDate instanceof Date) {
        const date = new Date(updateData.planDate);
        updateData.planDate = date.toISOString().split('T')[0];
      } else if (typeof updateData.planDate === 'string') {
        // Validate and normalize date string to YYYY-MM-DD
        const dateMatch = updateData.planDate.match(/^(\d{4}-\d{2}-\d{2})/);
        if (dateMatch) {
          updateData.planDate = dateMatch[1];
        }
      }
    }
    
    const updated = await DoctorSchedule.findOneAndUpdate(
      { scheduleId: Number(req.params.scheduleId) },
      updateData,
      { new: true }
    );
    if (!updated) {
      return res.status(404).json({ success: false, message: 'Schedule not found' });
    }
    res.status(200).json({ success: true, data: updated });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// DELETE /api/doctor-schedules/:scheduleId
router.delete('/:scheduleId', async (req, res) => {
  try {
    const deleted = await DoctorSchedule.findOneAndDelete({ scheduleId: Number(req.params.scheduleId) });
    if (!deleted) {
      return res.status(404).json({ success: false, message: 'Schedule not found' });
    }
    res.status(200).json({ success: true, message: 'Schedule deleted successfully' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
