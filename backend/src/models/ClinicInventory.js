const mongoose = require('mongoose');

const clinicInventorySchema = new mongoose.Schema(
  {
    inventoryId: { type: Number, unique: true, index: true },
    clinicId: { type: Number, required: true, index: true },
    brandId: { type: Number, required: true, index: true },
    quantity: { type: Number, required: true, default: 0, min: 0 },
  },
  { 
    timestamps: true 
  }
);

// Compound unique index to ensure one inventory record per clinic-brand combination
clinicInventorySchema.index({ clinicId: 1, brandId: 1 }, { unique: true });

// Auto-increment inventoryId
clinicInventorySchema.pre('save', async function (next) {
  if (this.isNew && !this.inventoryId) {
    try {
      const last = await mongoose
        .model('ClinicInventory')
        .findOne({}, { inventoryId: 1 })
        .sort({ inventoryId: -1 })
        .lean();
      this.inventoryId = last && last.inventoryId ? last.inventoryId + 1 : 1;
    } catch (e) {
      return next(e);
    }
  }
  next();
});

module.exports = mongoose.model('ClinicInventory', clinicInventorySchema);

