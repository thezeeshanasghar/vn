const mongoose = require('mongoose');

const ClinicBrandPriceSchema = new mongoose.Schema(
  {
    priceId: {
      type: Number,
      unique: true,
      index: true
    },
    clinicId: {
      type: Number,
      required: true,
      index: true,
      ref: 'Clinic'
    },
    brandId: {
      type: Number,
      required: true,
      index: true,
      ref: 'Brand'
    },
    price: {
      type: Number,
      required: true,
      default: 0,
      min: 0
    }
  },
  {
    timestamps: true
  }
);

// Compound index to ensure unique price per clinic and brand
ClinicBrandPriceSchema.index({ clinicId: 1, brandId: 1 }, { unique: true });

// Auto-increment priceId
ClinicBrandPriceSchema.pre('save', async function (next) {
  if (this.isNew && !this.priceId) {
    try {
      const last = await mongoose.model('ClinicBrandPrice')
        .findOne({}, { priceId: 1 })
        .sort({ priceId: -1 })
        .lean();
      this.priceId = last && last.priceId ? last.priceId + 1 : 1;
    } catch (e) {
      return next(e);
    }
  }
  next();
});

module.exports = mongoose.model('ClinicBrandPrice', ClinicBrandPriceSchema);

