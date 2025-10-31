const mongoose = require('mongoose');

const SupplierSchema = new mongoose.Schema(
  {
    supplierId: { type: Number, unique: true, index: true },
    doctorId: { type: Number, required: true, index: true },
    name: { type: String, required: true, trim: true },
    mobileNumber: { type: String, required: true, trim: true },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

// Helpful compound index for filtering by doctor + mobile (not unique)
SupplierSchema.index({ doctorId: 1, mobileNumber: 1 }, { name: 'doctor_mobile_index' });

// Auto-increment supplierId
SupplierSchema.pre('save', async function setIncrement(next) {
  if (this.supplierId) return next();
  try {
    const latest = await mongoose
      .model('Supplier')
      .findOne({}, { supplierId: 1 })
      .sort({ supplierId: -1 })
      .lean();
    this.supplierId = latest && latest.supplierId ? latest.supplierId + 1 : 1;
    next();
  } catch (err) {
    next(err);
  }
});

module.exports = mongoose.model('Supplier', SupplierSchema);


