const mongoose = require('mongoose');

const BrandArrivalSchema = new mongoose.Schema(
  {
    arrivalId: { type: Number, unique: true, index: true },
    billId: { type: Number, required: true, index: true },
    clinicId: { type: Number, index: true, sparse: true, default: null },
    brandId: { type: Number, required: true, index: true },
    quantity: { type: Number, required: true },
    unitPrice: { type: Number, required: true },
    lineTotal: { type: Number, required: true },
  },
  { 
    timestamps: true,
    minimize: false // Don't omit fields with null/undefined values
  }
);

BrandArrivalSchema.pre('save', async function (next) {
  if (this.isNew && !this.arrivalId) {
    try {
      const last = await mongoose
        .model('BrandArrival')
        .findOne({}, { arrivalId: 1 })
        .sort({ arrivalId: -1 })
        .lean();
      this.arrivalId = last && last.arrivalId ? last.arrivalId + 1 : 1;
    } catch (e) {
      return next(e);
    }
  }
  next();
});

module.exports = mongoose.model('BrandArrival', BrandArrivalSchema);


