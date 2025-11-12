const express = require('express');
const jwt = require('jsonwebtoken');

const router = express.Router();

const PersonalAssistant = require('../models/PersonalAssistant');
const PaAccess = require('../models/PaAccess');
const Clinic = require('../models/Clinic');

const buildResponsePayload = async (assistantDocument) => {
  const assistant = assistantDocument.toObject ? assistantDocument.toObject() : assistantDocument;
  delete assistant.password;

  const accessRows = await PaAccess.find({ paId: assistant.paId }).lean();
  const clinicIds = accessRows.map((item) => item.clinicId);
  const clinics = clinicIds.length
    ? await Clinic.find({ clinicId: { $in: clinicIds } }).lean()
    : [];

  const clinicMap = new Map();
  clinics.forEach((clinic) => clinicMap.set(clinic.clinicId, clinic));

  const clinicAccess = accessRows.map((row) => ({
    paAccessId: row.paAccessId,
    clinicId: row.clinicId,
    clinicName: clinicMap.get(row.clinicId)?.name || null,
    allowPatients: row.allowPatients,
    allowSchedules: row.allowSchedules,
    allowInventory: row.allowInventory,
    allowAlerts: row.allowAlerts,
    allowBilling: row.allowBilling
  }));

  return { assistant, clinicAccess };
};

// POST /api/pa-auth/login
router.post('/login', async (req, res) => {
  const { identifier, password } = req.body || {};

  if (!identifier || !password) {
    return res.status(400).json({ success: false, message: 'identifier and password are required' });
  }

  try {
    const normalizedIdentifier = String(identifier).toLowerCase().trim();

    const assistant = await PersonalAssistant.findOne({
      $or: [{ email: normalizedIdentifier }, { mobileNumber: identifier }]
    });

    if (!assistant || assistant.password !== password) {
      return res.status(400).json({ success: false, message: 'Invalid credentials' });
    }

    if (!assistant.isActive) {
      return res.status(403).json({ success: false, message: 'Account is disabled' });
    }

    const token = jwt.sign(
      {
        id: assistant._id,
        paId: assistant.paId,
        doctorId: assistant.doctorId
      },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '1h' }
    );

    const payload = await buildResponsePayload(assistant);

    res.status(200).json({
      success: true,
      token,
      assistant: payload.assistant,
      clinicAccess: payload.clinicAccess
    });
  } catch (error) {
    console.error('PA login error:', error);
    res.status(500).json({ success: false, message: error.message || 'Failed to login' });
  }
});

// POST /api/pa-auth/verify
router.post('/verify', async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, message: 'Unauthorized: No token provided' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
    const assistant = await PersonalAssistant.findById(decoded.id);

    if (!assistant) {
      return res.status(401).json({ success: false, message: 'Unauthorized: Assistant not found' });
    }

    if (!assistant.isActive) {
      return res.status(403).json({ success: false, message: 'Account is disabled' });
    }

    const payload = await buildResponsePayload(assistant);

    res.status(200).json({
      success: true,
      assistant: payload.assistant,
      clinicAccess: payload.clinicAccess
    });
  } catch (error) {
    console.error('PA token verification error:', error);
    res.status(401).json({ success: false, message: 'Unauthorized: Invalid token' });
  }
});

module.exports = router;

