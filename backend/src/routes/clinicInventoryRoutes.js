const express = require('express');
const router = express.Router();
const ClinicInventory = require('../models/ClinicInventory');
const ClinicBrandPrice = require('../models/ClinicBrandPrice');
const Brand = require('../models/Brand');
const Clinic = require('../models/Clinic');

// GET /api/clinic-inventory/clinic/:clinicId - Get inventory for a specific clinic
router.get('/clinic/:clinicId', async (req, res) => {
  try {
    const { clinicId } = req.params;
    const clinicInventory = await ClinicInventory.find({ clinicId: Number(clinicId) });

    // Get all brands and merge with inventory
    const allBrands = await Brand.find({});
    const inventoryMap = new Map();
    clinicInventory.forEach(inv => {
      inventoryMap.set(inv.brandId, inv.quantity);
    });

    // Get clinic-specific prices
    const prices = await ClinicBrandPrice.find({ clinicId: Number(clinicId) });
    const priceMap = new Map();
    prices.forEach(price => {
      priceMap.set(price.brandId, price.price);
    });

    // Create response with all brands, showing 0 if not in inventory
    // Use clinic-specific price if available, otherwise use default brand amount
    const inventoryWithBrands = allBrands.map(brand => ({
      brandId: brand.brandId,
      brandName: brand.name,
      brandAmount: priceMap.get(brand.brandId) ?? brand.amount ?? 0,
      defaultAmount: brand.amount ?? 0,
      quantity: inventoryMap.get(brand.brandId) || 0,
    }));

    res.status(200).json({
      success: true,
      count: inventoryWithBrands.length,
      data: inventoryWithBrands
    });
  } catch (error) {
    console.error('Get clinic inventory error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get clinic inventory'
    });
  }
});

// GET /api/clinic-inventory/doctor/:doctorId - Get inventory for all clinics of a doctor
router.get('/doctor/:doctorId', async (req, res) => {
  try {
    const { doctorId } = req.params;
    
    // Get all clinics for this doctor
    const clinics = await Clinic.find({ doctorId: Number(doctorId), isActive: true });
    
    if (clinics.length === 0) {
      return res.status(200).json({
        success: true,
        count: 0,
        data: []
      });
    }

    const clinicIds = clinics.map(c => c.clinicId);
    const clinicInventory = await ClinicInventory.find({ clinicId: { $in: clinicIds } });

    // Get all brands
    const allBrands = await Brand.find({});

    // Group inventory by clinic
    const inventoryByClinic = {};
    clinicInventory.forEach(inv => {
      if (!inventoryByClinic[inv.clinicId]) {
        inventoryByClinic[inv.clinicId] = new Map();
      }
      inventoryByClinic[inv.clinicId].set(inv.brandId, inv.quantity);
    });

    // Build response with clinic info and inventory
    const result = clinics.map(clinic => {
      const inventoryMap = inventoryByClinic[clinic.clinicId] || new Map();
      const inventory = allBrands.map(brand => ({
        brandId: brand.brandId,
        brandName: brand.name,
        brandAmount: brand.amount,
        quantity: inventoryMap.get(brand.brandId) || 0,
      }));

      return {
        clinicId: clinic.clinicId,
        clinicName: clinic.name,
        inventory: inventory
      };
    });

    res.status(200).json({
      success: true,
      count: result.length,
      data: result
    });
  } catch (error) {
    console.error('Get doctor inventory error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get doctor inventory'
    });
  }
});

module.exports = router;

