const mongoose = require('mongoose');

const personalAssistantSchema = new mongoose.Schema(
  {
    paId: {
      type: Number,
      unique: true,
      index: true
    },
    doctorId: {
      type: Number,
      required: true,
      index: true
    },
    firstName: {
      type: String,
      required: true,
      trim: true
    },
    lastName: {
      type: String,
      required: true,
      trim: true
    },
    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      unique: true
    },
    mobileNumber: {
      type: String,
      trim: true,
      default: ''
    },
    password: {
      type: String,
      required: true
    },
    permissions: {
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
    isActive: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

personalAssistantSchema.index({ doctorId: 1 });

personalAssistantSchema.pre('save', async function (next) {
  if (this.isNew && !this.paId) {
    try {
      const lastAssistant = await mongoose
        .model('PersonalAssistant')
        .findOne({}, { paId: 1 })
        .sort({ paId: -1 })
        .lean();
      this.paId = lastAssistant && lastAssistant.paId ? lastAssistant.paId + 1 : 1;
    } catch (error) {
      return next(error);
    }
  }
  next();
});

module.exports = mongoose.model('PersonalAssistant', personalAssistantSchema);

