const mongoose = require('mongoose');

const DoctorScheduleSchema = new mongoose.Schema(
  {
    scheduleId: {
      type: Number,
      unique: true,
      index: true,
    },
    doctorId: {
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
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

// Compound index to ensure one dose per doctor
DoctorScheduleSchema.index({ doctorId: 1, doseId: 1 }, { unique: true });

// Auto-increment scheduleId
DoctorScheduleSchema.pre('save', async function (next) {
  if (this.isNew && !this.scheduleId) {
    try {
      const lastSchedule = await mongoose
        .model('DoctorSchedule')
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

module.exports = mongoose.model('DoctorSchedule', DoctorScheduleSchema);
