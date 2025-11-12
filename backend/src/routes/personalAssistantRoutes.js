const express = require('express');
const router = express.Router();

const PersonalAssistant = require('../models/PersonalAssistant');
const PaAccess = require('../models/PaAccess');
const Doctor = require('../models/Doctor');
const Clinic = require('../models/Clinic');

const normalizePermissions = (input = {}) => ({
  allowPatients: Boolean(input.allowPatients),
  allowSchedules: Boolean(input.allowSchedules),
  allowInventory: Boolean(input.allowInventory),
  allowAlerts: Boolean(input.allowAlerts),
  allowBilling: Boolean(input.allowBilling)
});

const normalizeClinicAccess = (items = []) => {
  if (!Array.isArray(items)) return [];
  return items
    .map((item) => ({
      clinicId: Number(item.clinicId),
      allowPatients: Boolean(item.allowPatients),
      allowSchedules: Boolean(item.allowSchedules),
      allowInventory: Boolean(item.allowInventory),
      allowAlerts: Boolean(item.allowAlerts),
      allowBilling: Boolean(item.allowBilling)
    }))
    .filter((item) => !Number.isNaN(item.clinicId));
};

const attachClinicAccess = async (assistants = []) => {
  if (!assistants.length) return [];

  const paIds = assistants.map((pa) => pa.paId);
  const [accessRows, clinics] = await Promise.all([
    PaAccess.find({ paId: { $in: paIds } }).lean(),
    Clinic.find({}).lean()
  ]);

  const clinicMap = new Map();
  clinics.forEach((clinic) => {
    clinicMap.set(clinic.clinicId, clinic);
  });

  const groupedAccess = new Map();
  accessRows.forEach((row) => {
    if (!groupedAccess.has(row.paId)) {
      groupedAccess.set(row.paId, []);
    }
    const clinicDetails = clinicMap.get(row.clinicId);
    groupedAccess.get(row.paId).push({
      paAccessId: row.paAccessId,
      clinicId: row.clinicId,
      clinicName: clinicDetails ? clinicDetails.name : null,
      allowPatients: row.allowPatients,
      allowSchedules: row.allowSchedules,
      allowInventory: row.allowInventory,
      allowAlerts: row.allowAlerts,
      allowBilling: row.allowBilling
    });
  });

  return assistants.map((assistant) => ({
    ...assistant,
    clinicAccess: groupedAccess.get(assistant.paId) || []
  }));
};

// POST /api/personal-assistants - create PA for doctor
router.post('/', async (req, res) => {
  try {
    const {
      doctorId,
      firstName,
      lastName,
      email,
      password,
      mobileNumber,
      permissions,
      clinicAccess
    } = req.body || {};

    if (!doctorId || !firstName || !lastName || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'doctorId, firstName, lastName, email, and password are required'
      });
    }

    const doctor = await Doctor.findOne({ doctorId: Number(doctorId) });
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Doctor not found' });
    }

    const normalizedEmail = String(email).toLowerCase().trim();
    const existingAssistant = await PersonalAssistant.findOne({ email: normalizedEmail });
    if (existingAssistant) {
      return res.status(400).json({ success: false, message: 'Email already in use' });
    }

    const assistant = new PersonalAssistant({
      doctorId: Number(doctorId),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: normalizedEmail,
      password,
      mobileNumber: mobileNumber ? String(mobileNumber).trim() : '',
      permissions: normalizePermissions(permissions)
    });

    await assistant.save();

    const normalizedAccess = normalizeClinicAccess(clinicAccess);
    if (normalizedAccess.length) {
      const doctorClinics = await Clinic.find({ doctorId: Number(doctorId) }).lean();
      const allowedClinicIds = new Set(doctorClinics.map((clinic) => clinic.clinicId));

      for (const access of normalizedAccess) {
        if (!allowedClinicIds.has(access.clinicId)) {
          continue;
        }

        const existingAccess = await PaAccess.findOne({
          paId: assistant.paId,
          clinicId: access.clinicId
        });

        if (existingAccess) {
          existingAccess.allowPatients = access.allowPatients;
          existingAccess.allowSchedules = access.allowSchedules;
          existingAccess.allowInventory = access.allowInventory;
          existingAccess.allowAlerts = access.allowAlerts;
          existingAccess.allowBilling = access.allowBilling;
          await existingAccess.save();
        } else {
          await PaAccess.create({
            paId: assistant.paId,
            clinicId: access.clinicId,
            allowPatients: access.allowPatients,
            allowSchedules: access.allowSchedules,
            allowInventory: access.allowInventory,
            allowAlerts: access.allowAlerts,
            allowBilling: access.allowBilling
          });
        }
      }
    }

    const dataWithAccess = await attachClinicAccess([assistant.toObject()]);
    return res.status(201).json({ success: true, data: dataWithAccess[0] });
  } catch (error) {
    console.error('Create PA error:', error);
    return res.status(500).json({ success: false, message: error.message || 'Failed to create PA' });
  }
});

// GET /api/personal-assistants/doctor/:doctorId - list PAs for a doctor
router.get('/doctor/:doctorId', async (req, res) => {
  try {
    const doctorId = Number(req.params.doctorId);
    if (!doctorId) {
      return res.status(400).json({ success: false, message: 'Invalid doctorId' });
    }

    const assistants = await PersonalAssistant.find({ doctorId }).lean();
    const enriched = await attachClinicAccess(assistants);
    return res.status(200).json({ success: true, count: enriched.length, data: enriched });
  } catch (error) {
    console.error('List doctor PAs error:', error);
    return res.status(500).json({ success: false, message: error.message || 'Failed to fetch personal assistants' });
  }
});

// GET /api/personal-assistants/:paId - get PA details with access
router.get('/:paId', async (req, res) => {
  try {
    const paId = Number(req.params.paId);
    if (!paId) {
      return res.status(400).json({ success: false, message: 'Invalid paId' });
    }

    const assistant = await PersonalAssistant.findOne({ paId }).lean();
    if (!assistant) {
      return res.status(404).json({ success: false, message: 'Personal assistant not found' });
    }

    const [enriched] = await attachClinicAccess([assistant]);
    return res.status(200).json({ success: true, data: enriched });
  } catch (error) {
    console.error('Get PA error:', error);
    return res.status(500).json({ success: false, message: error.message || 'Failed to fetch personal assistant' });
  }
});

// PUT /api/personal-assistants/:paId - update PA info
router.put('/:paId', async (req, res) => {
  try {
    const paId = Number(req.params.paId);
    if (!paId) {
      return res.status(400).json({ success: false, message: 'Invalid paId' });
    }

    const payload = { ...req.body };
    if (payload.email) {
      payload.email = String(payload.email).toLowerCase().trim();
      const emailOwner = await PersonalAssistant.findOne({ email: payload.email });
      if (emailOwner && emailOwner.paId !== paId) {
        return res.status(400).json({ success: false, message: 'Email already in use' });
      }
    }

    if (payload.firstName) payload.firstName = payload.firstName.trim();
    if (payload.lastName) payload.lastName = payload.lastName.trim();
    if (payload.mobileNumber) payload.mobileNumber = String(payload.mobileNumber).trim();

    const updated = await PersonalAssistant.findOneAndUpdate(
      { paId },
      payload,
      { new: true, runValidators: false }
    ).lean();

    if (!updated) {
      return res.status(404).json({ success: false, message: 'Personal assistant not found' });
    }

    const [enriched] = await attachClinicAccess([updated]);
    return res.status(200).json({ success: true, data: enriched });
  } catch (error) {
    console.error('Update PA error:', error);
    return res.status(500).json({ success: false, message: error.message || 'Failed to update personal assistant' });
  }
});

// PUT /api/personal-assistants/:paId/permissions - update module permissions
router.put('/:paId/permissions', async (req, res) => {
  try {
    const paId = Number(req.params.paId);
    if (!paId) {
      return res.status(400).json({ success: false, message: 'Invalid paId' });
    }

    const assistant = await PersonalAssistant.findOne({ paId });
    if (!assistant) {
      return res.status(404).json({ success: false, message: 'Personal assistant not found' });
    }

    assistant.permissions = normalizePermissions(req.body || {});
    await assistant.save();

    const [enriched] = await attachClinicAccess([assistant.toObject()]);
    return res.status(200).json({ success: true, data: enriched });
  } catch (error) {
    console.error('Update PA permissions error:', error);
    return res.status(500).json({ success: false, message: error.message || 'Failed to update permissions' });
  }
});

// PUT /api/personal-assistants/:paId/access - update clinic access permissions
router.put('/:paId/access', async (req, res) => {
  try {
    const paId = Number(req.params.paId);
    if (!paId) {
      return res.status(400).json({ success: false, message: 'Invalid paId' });
    }

    const assistant = await PersonalAssistant.findOne({ paId });
    if (!assistant) {
      return res.status(404).json({ success: false, message: 'Personal assistant not found' });
    }

    const normalizedAccess = normalizeClinicAccess(req.body?.clinicAccess);
    const doctorClinics = await Clinic.find({ doctorId: assistant.doctorId }).lean();
    const allowedClinicIds = new Set(doctorClinics.map((clinic) => clinic.clinicId));

    for (const access of normalizedAccess) {
      if (!allowedClinicIds.has(access.clinicId)) {
        continue;
      }

      const existingAccess = await PaAccess.findOne({ paId, clinicId: access.clinicId });

      if (existingAccess) {
        existingAccess.allowPatients = access.allowPatients;
        existingAccess.allowSchedules = access.allowSchedules;
        existingAccess.allowInventory = access.allowInventory;
        existingAccess.allowAlerts = access.allowAlerts;
        existingAccess.allowBilling = access.allowBilling;
        await existingAccess.save();
      } else {
        await PaAccess.create({
          paId,
          clinicId: access.clinicId,
          allowPatients: access.allowPatients,
          allowSchedules: access.allowSchedules,
          allowInventory: access.allowInventory,
          allowAlerts: access.allowAlerts,
          allowBilling: access.allowBilling
        });
      }
    }

    // Optionally clean up clinics not included to avoid stale permissions
    const providedClinicIds = new Set(normalizedAccess.map((item) => item.clinicId));
    await PaAccess.deleteMany({
      paId,
      clinicId: { $nin: Array.from(providedClinicIds) }
    });

    const [enriched] = await attachClinicAccess([assistant.toObject()]);
    return res.status(200).json({ success: true, data: enriched });
  } catch (error) {
    console.error('Update PA clinic access error:', error);
    return res.status(500).json({ success: false, message: error.message || 'Failed to update clinic access' });
  }
});

// DELETE /api/personal-assistants/:paId - deactivate PA
router.delete('/:paId', async (req, res) => {
  try {
    const paId = Number(req.params.paId);
    if (!paId) {
      return res.status(400).json({ success: false, message: 'Invalid paId' });
    }

    const assistant = await PersonalAssistant.findOne({ paId });
    if (!assistant) {
      return res.status(404).json({ success: false, message: 'Personal assistant not found' });
    }

    assistant.isActive = false;
    await assistant.save();

    return res.status(200).json({ success: true, message: 'Personal assistant deactivated' });
  } catch (error) {
    console.error('Deactivate PA error:', error);
    return res.status(500).json({ success: false, message: error.message || 'Failed to deactivate personal assistant' });
  }
});

module.exports = router;

