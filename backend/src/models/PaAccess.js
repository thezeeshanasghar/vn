const mongoose = require('mongoose');

const paAccessSchema = new mongoose.Schema(
  {
    paAccessId: {
      type: Number,
      unique: true,
      index: true
    },
    paId: {
      type: Number,
      required: true,
      index: true
    },
    clinicId: {
      type: Number,
      required: true,
      index: true
    },
    allowPatients: {
      type: Boolean,
      default: false
    },
    allowSchedules: {
      type: Boolean,
      default: false
    },
    allowInventory: {
      type: Boolean,
      default: false
    },
    allowAlerts: {
      type: Boolean,
      default: false
    },
    allowBilling: {
      type: Boolean,
      default: false
    }
  },
  {
    timestamps: true
  }
);

paAccessSchema.index({ paId: 1, clinicId: 1 }, { unique: true });

paAccessSchema.pre('save', async function (next) {
  if (this.isNew && !this.paAccessId) {
    try {
      const lastAccess = await mongoose
        .model('PaAccess')
        .findOne({}, { paAccessId: 1 })
        .sort({ paAccessId: -1 })
        .lean();
      this.paAccessId = lastAccess && lastAccess.paAccessId ? lastAccess.paAccessId + 1 : 1;
    } catch (error) {
      return next(error);
    }
  }
  next();
});

module.exports = mongoose.model('PaAccess', paAccessSchema);

