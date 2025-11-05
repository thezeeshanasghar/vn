const express = require('express');
const router = express.Router();
const ClinicBrandPrice = require('../models/ClinicBrandPrice');
const Brand = require('../models/Brand');
const Clinic = require('../models/Clinic');

/**
 * @swagger
 * tags:
 *   name: Clinic Brand Price
 *   description: Clinic-specific brand pricing management
 */

/**
 * @swagger
 * /api/clinic-brand-price/clinic/{clinicId}:
 *   get:
 *     summary: Get all brand prices for a specific clinic
 *     tags: [Clinic Brand Price]
 *     parameters:
 *       - in: path
 *         name: clinicId
 *         required: true
 *         schema:
 *           type: string
 *         description: Numeric ID of the clinic
 *     responses:
 *       200:
 *         description: List of brand prices for the clinic
 *       404:
 *         description: Clinic not found
 *       500:
 *         description: Server error
 */
router.get('/clinic/:clinicId', async (req, res) => {
  try {
    const { clinicId } = req.params;
    const numericClinicId = Number(clinicId);

    const clinic = await Clinic.findOne({ clinicId: numericClinicId });
    if (!clinic) {
      return res.status(404).json({ success: false, message: 'Clinic not found' });
    }

    const prices = await ClinicBrandPrice.find({ clinicId: numericClinicId }).sort({ brandId: 1 });

    // Get all brands and merge with prices
    const allBrands = await Brand.find({});
    const priceMap = new Map();
    prices.forEach(price => {
      priceMap.set(price.brandId, price.price);
    });

    // Create response with all brands, showing default price if not set
    const pricesWithBrands = allBrands.map(brand => ({
      brandId: brand.brandId,
      brandName: brand.name,
      defaultPrice: brand.amount || 0,
      clinicPrice: priceMap.get(brand.brandId) ?? null, // null means use default
    }));

    res.status(200).json({
      success: true,
      count: pricesWithBrands.length,
      data: pricesWithBrands
    });
  } catch (error) {
    console.error('Get clinic brand prices error:', error);
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

/**
 * @swagger
 * /api/clinic-brand-price:
 *   put:
 *     summary: Update or create brand price for a clinic
 *     tags: [Clinic Brand Price]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - clinicId
 *               - brandId
 *               - price
 *             properties:
 *               clinicId:
 *                 type: number
 *               brandId:
 *                 type: number
 *               price:
 *                 type: number
 *     responses:
 *       200:
 *         description: Price updated successfully
 *       400:
 *         description: Invalid input
 *       404:
 *         description: Clinic or brand not found
 *       500:
 *         description: Server error
 */
router.put('/', async (req, res) => {
  try {
    const { clinicId, brandId, price } = req.body;

    if (!clinicId || !brandId || price === undefined || price === null) {
      return res.status(400).json({
        success: false,
        message: 'clinicId, brandId, and price are required'
      });
    }

    const numericClinicId = Number(clinicId);
    const numericBrandId = Number(brandId);
    const numericPrice = Number(price);

    if (numericPrice < 0) {
      return res.status(400).json({
        success: false,
        message: 'Price cannot be negative'
      });
    }

    // Verify clinic and brand exist
    const clinic = await Clinic.findOne({ clinicId: numericClinicId });
    if (!clinic) {
      return res.status(404).json({ success: false, message: 'Clinic not found' });
    }

    const brand = await Brand.findOne({ brandId: numericBrandId });
    if (!brand) {
      return res.status(404).json({ success: false, message: 'Brand not found' });
    }

    // Find or create price record
    let priceRecord = await ClinicBrandPrice.findOne({
      clinicId: numericClinicId,
      brandId: numericBrandId
    });

    if (priceRecord) {
      priceRecord.price = numericPrice;
      await priceRecord.save();
    } else {
      priceRecord = await ClinicBrandPrice.create({
        clinicId: numericClinicId,
        brandId: numericBrandId,
        price: numericPrice
      });
    }

    res.status(200).json({
      success: true,
      message: 'Price updated successfully',
      data: priceRecord
    });
  } catch (error) {
    console.error('Update clinic brand price error:', error);
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

module.exports = router;

