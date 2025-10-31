const express = require('express');
const router = express.Router();
const Supplier = require('../models/Supplier');

// One-time index hygiene for legacy deployments
(async () => {
  try {
    // Drop legacy unique index on mobileNumber if present
    const hasLegacy = await Supplier.collection.indexExists('mobileNumber_1');
    if (hasLegacy) {
      await Supplier.collection.dropIndex('mobileNumber_1');
      console.log('🧹 Suppliers: dropped legacy index mobileNumber_1');
    }
  } catch (e) {
    // ignore at runtime; only best-effort cleanup
  }
  try {
    const idx = await Supplier.collection.indexes();
    for (const i of idx) {
      if (i.name !== '_id_' && i.unique === true) {
        await Supplier.collection.dropIndex(i.name);
        console.log(`🧹 Suppliers: dropped unique index ${i.name}`);
      }
    }
  } catch (_) {}
})();

// GET /api/suppliers?doctorId=NN
router.get('/', async (req, res) => {
  try {
    const { doctorId } = req.query;
    if (!doctorId) {
      return res.status(400).json({ success: false, message: 'Doctor ID is required' });
    }
    const items = await Supplier.find({ isActive: true, doctorId: Number(doctorId) }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, count: items.length, data: items });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/suppliers
router.post('/', async (req, res) => {
  try {
    const { name, mobileNumber, doctorId } = req.body || {};
    if (!name || !mobileNumber || !doctorId) {
      return res.status(400).json({ success: false, message: 'Name, mobileNumber and doctorId are required' });
    }
    const created = await Supplier.create({ name: name.trim(), mobileNumber: mobileNumber.trim(), doctorId: Number(doctorId) });
    res.status(201).json({ success: true, data: created });
  } catch (err) {
    if (err && err.code === 11000) {
      // If any unique index remains, drop all uniques except _id_ and retry once
      try {
        const idx = await Supplier.collection.indexes();
        for (const i of idx) {
          if (i.name !== '_id_' && i.unique === true) {
            await Supplier.collection.dropIndex(i.name);
          }
        }
        const created = await Supplier.create({
          name: req.body.name.trim(),
          mobileNumber: req.body.mobileNumber.trim(),
          doctorId: Number(req.body.doctorId)
        });
        return res.status(201).json({ success: true, data: created });
      } catch (e2) {
        return res.status(400).json({ success: false, message: 'Duplicate detected by legacy index. Please restart backend and retry.' });
      }
    }
    res.status(500).json({ success: false, message: err.message });
  }
});

// PUT /api/suppliers/:supplierId
router.put('/:supplierId', async (req, res) => {
  try {
    const supplierId = Number(req.params.supplierId);
    const update = { ...req.body };
    delete update.doctorId; // doctor ownership cannot be changed
    const updated = await Supplier.findOneAndUpdate({ supplierId }, update, { new: true });
    if (!updated) return res.status(404).json({ success: false, message: 'Supplier not found' });
    res.status(200).json({ success: true, data: updated });
  } catch (err) {
    if (err && err.code === 11000) {
      return res.status(400).json({ success: false, message: 'Supplier with this mobile already exists for this doctor' });
    }
    res.status(500).json({ success: false, message: err.message });
  }
});

// DELETE /api/suppliers/:supplierId
router.delete('/:supplierId', async (req, res) => {
  try {
    const supplierId = Number(req.params.supplierId);
    const deleted = await Supplier.findOneAndUpdate({ supplierId }, { isActive: false }, { new: true });
    if (!deleted) return res.status(404).json({ success: false, message: 'Supplier not found' });
    res.status(200).json({ success: true, message: 'Supplier deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;


