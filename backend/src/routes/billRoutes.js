const express = require('express');
const router = express.Router();
const Bill = require('../models/Bill');
const BrandArrival = require('../models/BrandArrival');
const Brand = require('../models/Brand');
const Clinic = require('../models/Clinic');
const ClinicInventory = require('../models/ClinicInventory');

// POST /api/bills -> create bill with lines [{brandId, quantity}]
router.post('/', async (req, res) => {
  try {
    const { doctorId, clinicId, supplierId, date, paid, lines } = req.body || {};
    if (!doctorId || !supplierId || !Array.isArray(lines) || lines.length === 0) {
      return res.status(400).json({ success: false, message: 'doctorId, supplierId and at least one line are required' });
    }

    // Validate clinic belongs to doctor if clinicId is provided
    let validatedClinicId = null;
    
    if (clinicId !== undefined && clinicId !== null) {
      const clinic = await Clinic.findOne({ clinicId: Number(clinicId), doctorId: Number(doctorId), isActive: true });
      if (!clinic) {
        return res.status(400).json({ success: false, message: 'Clinic not found or does not belong to this doctor' });
      }
      validatedClinicId = Number(clinic.clinicId);
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

    // Save arrivals referencing billId and clinicId
    const createdArrivals = [];
    const arrivalErrors = [];
    
    for (let i = 0; i < pricedLines.length; i++) {
      const pl = pricedLines[i];
      try {
        const arrivalData = {
          brandId: pl.brandId,
          quantity: pl.quantity,
          unitPrice: pl.unitPrice,
          lineTotal: pl.lineTotal,
          billId: bill.billId,
        };
        
        // Explicitly set clinicId - ensure it's always included even if null
        if (validatedClinicId !== null && validatedClinicId !== undefined) {
          arrivalData.clinicId = validatedClinicId;
        } else {
          arrivalData.clinicId = null;
        }
        
        const createdArrival = await BrandArrival.create(arrivalData);
        createdArrivals.push(createdArrival);

        // Update clinic inventory if clinicId is provided
        if (validatedClinicId !== null && validatedClinicId !== undefined) {
          try {
            // Check if inventory record exists
            let inventory = await ClinicInventory.findOne({
              clinicId: validatedClinicId,
              brandId: pl.brandId
            });

            if (inventory) {
              // Update existing inventory
              inventory.quantity += pl.quantity;
              await inventory.save();
            } else {
              // Create new inventory record (this will trigger pre-save hook for inventoryId)
              inventory = new ClinicInventory({
                clinicId: validatedClinicId,
                brandId: pl.brandId,
                quantity: pl.quantity
              });
              await inventory.save();
            }
          } catch (inventoryError) {
            console.error(`Failed to update clinic inventory for clinicId ${validatedClinicId}, brandId ${pl.brandId}:`, inventoryError);
            // Don't fail the entire operation if inventory update fails
          }
        }
      } catch (arrivalError) {
        console.error(`Failed to create brand arrival:`, arrivalError);
        arrivalErrors.push({
          index: i,
          line: pl,
          error: arrivalError.message
        });
      }
    }

    // If no arrivals were created, delete the bill and return error
    if (createdArrivals.length === 0) {
      await Bill.deleteOne({ billId: bill.billId });
      return res.status(500).json({ 
        success: false, 
        message: 'Failed to create any brand arrivals. Bill was not created.',
        errors: arrivalErrors
      });
    }

    return res.status(201).json({ 
      success: true, 
      data: { 
        bill, 
        lines: pricedLines,
        arrivalsCreated: createdArrivals.length,
        totalLines: pricedLines.length
      } 
    });
  } catch (error) {
    console.error('Create bill error:', error);
    res.status(500).json({ 
      success: false, 
      message: error.message || 'Failed to create bill'
    });
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


