const mongoose = require('mongoose');

const BillSchema = new mongoose.Schema(
  {
    billId: { type: Number, unique: true, index: true },
    doctorId: { type: Number, required: true, index: true },
    supplierId: { type: Number, required: true, index: true },
    date: { type: Date, default: () => new Date() },
    totalQuantity: { type: Number, default: 0 },
    totalAmount: { type: Number, default: 0 },
    paid: { type: Boolean, default: false },
  },
  { timestamps: true }
);

// Auto-increment billId
BillSchema.pre('save', async function (next) {
  if (this.isNew && !this.billId) {
    try {
      const last = await mongoose.model('Bill').findOne({}, { billId: 1 }).sort({ billId: -1 }).lean();
      this.billId = last && last.billId ? last.billId + 1 : 1;
    } catch (e) {
      return next(e);
    }
  }
  next();
});

module.exports = mongoose.model('Bill', BillSchema);


