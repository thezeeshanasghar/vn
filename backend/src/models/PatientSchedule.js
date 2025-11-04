const mongoose = require('mongoose');

const PatientScheduleSchema = new mongoose.Schema(
  {
    scheduleId: {
      type: Number,
      unique: true,
      index: true,
    },
    childId: {
      type: Number,
      required: true,
      index: true,
    },
    doseId: {
      type: Number,
      required: true,
      index: true,
    },
    planDate: {
      type: String,
      default: null,
      trim: true,
    },
    givenDate: {
      type: String,
      default: null,
      trim: true,
    },
    brandId: {
      type: Number,
      default: null,
    },
    IsDone: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

// Compound index for faster queries by child and dose
PatientScheduleSchema.index({ childId: 1, doseId: 1 });

// Auto-increment scheduleId
PatientScheduleSchema.pre('save', async function (next) {
  if (this.isNew && !this.scheduleId) {
    try {
      const lastSchedule = await mongoose
        .model('PatientSchedule')
        .findOne({}, { scheduleId: 1 })
        .sort({ scheduleId: -1 })
        .lean();
      this.scheduleId = lastSchedule && lastSchedule.scheduleId ? lastSchedule.scheduleId + 1 : 1;
      next();
    } catch (err) {
      next(err);
    }
  } else {
    next();
  }
});

module.exports = mongoose.model('PatientSchedule', PatientScheduleSchema);
