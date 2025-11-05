const express = require('express');
const router = express.Router();
const PatientSchedule = require('../models/PatientSchedule');
const Dose = require('../models/Dose');
const ClinicInventory = require('../models/ClinicInventory');
const Patient = require('../models/Patient');
const Brand = require('../models/Brand');

// GET /api/patient-schedules - Get schedules for a child/patient
router.get('/', async (req, res) => {
  try {
    const { childId } = req.query;
    if (!childId) {
      return res.status(400).json({ success: false, message: 'Child ID is required' });
    }

    const schedules = await PatientSchedule.find({ childId: Number(childId) }).sort({ createdAt: 1 });
    
    // Populate dose and brand information and normalize givenDate format
    const schedulesWithDoses = await Promise.all(
      schedules.map(async (schedule) => {
        const dose = await Dose.findOne({ doseId: schedule.doseId });
        const brand = schedule.brandId ? await Brand.findOne({ brandId: schedule.brandId }) : null;
        const scheduleObj = schedule.toObject();
        
        // Normalize givenDate to YYYY-MM-DD string format
        if (scheduleObj.givenDate) {
          if (scheduleObj.givenDate instanceof Date) {
            scheduleObj.givenDate = scheduleObj.givenDate.toISOString().split('T')[0];
          } else if (typeof scheduleObj.givenDate === 'string') {
            // If it's already a string, try to normalize to YYYY-MM-DD
            const dateMatch = scheduleObj.givenDate.match(/^(\d{4}-\d{2}-\d{2})/);
            if (dateMatch) {
              scheduleObj.givenDate = dateMatch[1];
            } else {
              // Try to parse and convert
              const date = new Date(scheduleObj.givenDate);
              if (!isNaN(date.getTime())) {
                scheduleObj.givenDate = date.toISOString().split('T')[0];
              } else {
                scheduleObj.givenDate = null;
              }
            }
          }
        }
        
        return {
          ...scheduleObj,
          dose: dose ? {
            doseId: dose.doseId,
            name: dose.name,
            minAge: dose.minAge,
            maxAge: dose.maxAge,
            minGap: dose.minGap,
            vaccineID: dose.vaccineID,
          } : null,
          brand: brand ? {
            brandId: brand.brandId,
            name: brand.name,
            amount: brand.amount,
          } : null,
        };
      })
    );

    res.status(200).json({ success: true, count: schedulesWithDoses.length, data: schedulesWithDoses });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/patient-schedules/:scheduleId - Get specific schedule
router.get('/:scheduleId', async (req, res) => {
  try {
    const schedule = await PatientSchedule.findOne({ scheduleId: Number(req.params.scheduleId) });
    if (!schedule) {
      return res.status(404).json({ success: false, message: 'Schedule not found' });
    }
    
    // Populate dose and brand information and normalize givenDate format
    const dose = await Dose.findOne({ doseId: schedule.doseId });
    const brand = schedule.brandId ? await Brand.findOne({ brandId: schedule.brandId }) : null;
    const scheduleObj = schedule.toObject();
    
    // Normalize givenDate to YYYY-MM-DD string format
    if (scheduleObj.givenDate) {
      if (scheduleObj.givenDate instanceof Date) {
        scheduleObj.givenDate = scheduleObj.givenDate.toISOString().split('T')[0];
      } else if (typeof scheduleObj.givenDate === 'string') {
        // If it's already a string, try to normalize to YYYY-MM-DD
        const dateMatch = scheduleObj.givenDate.match(/^(\d{4}-\d{2}-\d{2})/);
        if (dateMatch) {
          scheduleObj.givenDate = dateMatch[1];
        } else {
          // Try to parse and convert
          const date = new Date(scheduleObj.givenDate);
          if (!isNaN(date.getTime())) {
            scheduleObj.givenDate = date.toISOString().split('T')[0];
          } else {
            scheduleObj.givenDate = null;
          }
        }
      }
    }
    
    const scheduleWithDose = {
      ...scheduleObj,
      dose: dose ? {
        doseId: dose.doseId,
        name: dose.name,
        minAge: dose.minAge,
        maxAge: dose.maxAge,
        minGap: dose.minGap,
        vaccineID: dose.vaccineID,
      } : null,
      brand: brand ? {
        brandId: brand.brandId,
        name: brand.name,
        amount: brand.amount,
      } : null,
    };
    
    res.status(200).json({ success: true, data: scheduleWithDose });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/patient-schedules - Create a new patient schedule
router.post('/', async (req, res) => {
  try {
    const { childId, doseId, givenDate, brandId } = req.body;
    
    if (!childId || !doseId) {
      return res.status(400).json({ 
        success: false, 
        message: 'Child ID and Dose ID are required' 
      });
    }

    const schedule = await PatientSchedule.create({
      childId: Number(childId),
      doseId: Number(doseId),
      givenDate: givenDate ? new Date(givenDate) : null,
      brandId: brandId ? Number(brandId) : null,
    });

    res.status(201).json({ success: true, data: schedule });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// PUT /api/patient-schedules/:scheduleId - Update schedule (mainly givenDate, brandId, and planDate for rescheduling)
router.put('/:scheduleId', async (req, res) => {
  try {
    const updateData = { ...req.body };
    
    // Handle givenDate - can be a date string (YYYY-MM-DD) or Date object, or null
    if (updateData.givenDate !== undefined) {
      if (updateData.givenDate === null || updateData.givenDate === '') {
        updateData.givenDate = null;
      } else if (typeof updateData.givenDate === 'string') {
        // If it's already a YYYY-MM-DD format string, keep it as string
        // Otherwise convert Date string to YYYY-MM-DD
        const dateMatch = updateData.givenDate.match(/^(\d{4}-\d{2}-\d{2})/);
        if (dateMatch) {
          updateData.givenDate = dateMatch[1]; // Keep as YYYY-MM-DD string
        } else {
          // Try to parse and convert to YYYY-MM-DD
          const date = new Date(updateData.givenDate);
          if (!isNaN(date.getTime())) {
            updateData.givenDate = date.toISOString().split('T')[0];
          }
        }
      } else if (updateData.givenDate instanceof Date) {
        // Convert Date object to YYYY-MM-DD string
        updateData.givenDate = updateData.givenDate.toISOString().split('T')[0];
      }
    }
    
    // Handle planDate - normalize to YYYY-MM-DD format string for rescheduling
    if (updateData.planDate !== undefined) {
      let newPlanDate = null;
      
      if (updateData.planDate instanceof Date) {
        // If it's a Date object, convert to YYYY-MM-DD
        const date = new Date(updateData.planDate);
        newPlanDate = date.toISOString().split('T')[0];
      } else if (typeof updateData.planDate === 'string' && updateData.planDate.trim() !== '') {
        // Validate and normalize date string to YYYY-MM-DD
        const dateMatch = updateData.planDate.match(/^(\d{4}-\d{2}-\d{2})/);
        if (dateMatch) {
          newPlanDate = dateMatch[1];
        }
      } else if (updateData.planDate === null || updateData.planDate === '') {
        newPlanDate = null;
      }
      
      updateData.planDate = newPlanDate;
    }
    
    // Ensure numeric types
    if (updateData.brandId !== undefined) {
      updateData.brandId = updateData.brandId ? Number(updateData.brandId) : null;
    }
    if (updateData.doseId !== undefined) {
      updateData.doseId = Number(updateData.doseId);
    }
    if (updateData.childId !== undefined) {
      updateData.childId = Number(updateData.childId);
    }
    
    // Handle IsDone boolean field
    if (updateData.IsDone !== undefined) {
      updateData.IsDone = Boolean(updateData.IsDone);
    }
    
    // Get the current schedule to check if IsDone is changing
    const currentSchedule = await PatientSchedule.findOne({ scheduleId: Number(req.params.scheduleId) });
    if (!currentSchedule) {
      return res.status(404).json({ success: false, message: 'Schedule not found' });
    }
    
    const wasDone = currentSchedule.IsDone;
    const willBeDone = updateData.IsDone !== undefined ? updateData.IsDone : wasDone;
    const brandId = updateData.brandId !== undefined ? updateData.brandId : currentSchedule.brandId;
    
    // Update only the specific patient schedule (does NOT affect doctor's schedule)
    const updated = await PatientSchedule.findOneAndUpdate(
      { scheduleId: Number(req.params.scheduleId) },
      updateData,
      { new: true }
    );
    
    if (!updated) {
      return res.status(404).json({ success: false, message: 'Schedule not found' });
    }
    
    // Handle inventory updates when IsDone status changes
    if (wasDone !== willBeDone && brandId) {
      try {
        // Get patient to find clinicId
        const patient = await Patient.findOne({ patientId: updated.childId });
        if (patient && patient.clinicId) {
          // Find or create inventory record
          let inventory = await ClinicInventory.findOne({
            clinicId: Number(patient.clinicId),
            brandId: Number(brandId)
          });
          
          if (willBeDone) {
            // Marking as done - decrease inventory by 1
            if (inventory) {
              inventory.quantity = Math.max(0, inventory.quantity - 1);
              await inventory.save();
            } else {
              // Create new inventory record with 0 quantity (shouldn't happen but handle it)
              inventory = new ClinicInventory({
                clinicId: Number(patient.clinicId),
                brandId: Number(brandId),
                quantity: 0
              });
              await inventory.save();
            }
          } else {
            // Marking as undone - increase inventory by 1
            if (inventory) {
              inventory.quantity += 1;
              await inventory.save();
            } else {
              // Create new inventory record with quantity 1
              inventory = new ClinicInventory({
                clinicId: Number(patient.clinicId),
                brandId: Number(brandId),
                quantity: 1
              });
              await inventory.save();
            }
          }
        }
      } catch (inventoryError) {
        console.error('Failed to update clinic inventory:', inventoryError);
        // Don't fail the entire operation if inventory update fails
        // Log the error but continue
      }
    }
    
    res.status(200).json({ success: true, data: updated });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// DELETE /api/patient-schedules/:scheduleId
router.delete('/:scheduleId', async (req, res) => {
  try {
    const deleted = await PatientSchedule.findOneAndDelete({ scheduleId: Number(req.params.scheduleId) });
    if (!deleted) {
      return res.status(404).json({ success: false, message: 'Schedule not found' });
    }
    res.status(200).json({ success: true, message: 'Schedule deleted successfully' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
