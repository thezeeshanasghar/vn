const express = require('express');
const router = express.Router();
const Bill = require('../models/Bill');
const BrandArrival = require('../models/BrandArrival');
const Brand = require('../models/Brand');

// POST /api/bills -> create bill with lines [{brandId, quantity}]
router.post('/', async (req, res) => {
  try {
    const { doctorId, supplierId, date, paid, lines } = req.body || {};
    if (!doctorId || !supplierId || !Array.isArray(lines) || lines.length === 0) {
      return res.status(400).json({ success: false, message: 'doctorId, supplierId and at least one line are required' });
    }

    // Compute prices from Brand.amount
    let totalQty = 0;
    let totalAmt = 0;
    const pricedLines = [];
    for (const ln of lines) {
      const brand = await Brand.findOne({ brandId: Number(ln.brandId) });
      if (!brand) return res.status(400).json({ success: false, message: `Brand not found: ${ln.brandId}` });
      const qty = Number(ln.quantity || 0);
      const unit = Number(brand.amount || 0);
      const lineTotal = unit * qty;
      totalQty += qty;
      totalAmt += lineTotal;
      pricedLines.push({ brandId: brand.brandId, quantity: qty, unitPrice: unit, lineTotal });
    }

    const bill = await Bill.create({
      doctorId: Number(doctorId),
      supplierId: Number(supplierId),
      date: date ? new Date(date) : new Date(),
      totalQuantity: totalQty,
      totalAmount: totalAmt,
      paid: !!paid,
    });

    // Save arrivals referencing billId
    for (const pl of pricedLines) {
      await BrandArrival.create({ ...pl, billId: bill.billId });
    }

    return res.status(201).json({ success: true, data: { bill, lines: pricedLines } });
  } catch (error) {
    console.error('Create bill error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/bills?doctorId=NN
router.get('/', async (req, res) => {
  try {
    const { doctorId } = req.query;
    if (!doctorId) {
      return res.status(400).json({ success: false, message: 'doctorId is required' });
    }
    const bills = await Bill.find({ doctorId: Number(doctorId) }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, count: bills.length, data: bills });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/bills/:billId -> bill with lines
router.get('/:billId', async (req, res) => {
  try {
    const bill = await Bill.findOne({ billId: Number(req.params.billId) });
    if (!bill) return res.status(404).json({ success: false, message: 'Bill not found' });
    const lines = await BrandArrival.find({ billId: bill.billId }).sort({ createdAt: 1 });
    res.status(200).json({ success: true, data: { bill, lines } });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;


