const express = require('express');
const router = express.Router();
const Clinic = require('../models/Clinic');
const Doctor = require('../models/Doctor');

/**
 * @swagger
 * tags:
 *   name: Clinics
 *   description: Clinic management
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Clinic:
 *       type: object
 *       required:
 *         - name
 *         - address
 *         - regNo
 *         - phoneNumber
 *         - clinicFee
 *         - doctor
 *       properties:
 *         _id:
 *           type: string
 *           description: MongoDB ObjectId
 *         clinicId:
 *           type: number
 *           description: Auto-generated sequential ID
 *         name:
 *           type: string
 *           description: Clinic name
 *         address:
 *           type: string
 *           description: Clinic address
 *         regNo:
 *           type: string
 *           description: Registration number
 *         logo:
 *           type: string
 *           description: Clinic logo URL or base64
 *         phoneNumber:
 *           type: string
 *           description: Clinic phone number
 *         clinicFee:
 *           type: number
 *           description: Consultation fee
 *         doctor:
 *           type: string
 *           description: Doctor ObjectId
 *         isActive:
 *           type: boolean
 *           description: Clinic status
 */

/**
 * @swagger
 * /api/clinics:
 *   get:
 *     summary: Get all clinics
 *     tags: [Clinics]
 *     responses:
 *       200:
 *         description: List of all clinics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 count:
 *                   type: number
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Clinic'
 */
router.get('/', async (req, res) => {
  try {
    const clinics = await Clinic.find({ isActive: true })
      .sort({ createdAt: -1 });

    // Fetch doctor information for each clinic
    const clinicsWithDoctorInfo = await Promise.all(clinics.map(async (clinic) => {
      const doctor = await Doctor.findOne({ doctorId: clinic.doctorId });
      const clinicObj = clinic.toObject();
      clinicObj.doctorInfo = doctor ? {
        _id: doctor._id,
        firstName: doctor.firstName,
        lastName: doctor.lastName,
        email: doctor.email,
        mobileNumber: doctor.mobileNumber
      } : null;
      return clinicObj;
    }));

    res.status(200).json({
      success: true,
      count: clinicsWithDoctorInfo.length,
      data: clinicsWithDoctorInfo
    });
  } catch (error) {
    console.error('Get clinics error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

/**
 * @swagger
 * /api/clinics/doctor/{doctorId}:
 *   get:
 *     summary: Get all clinics by doctor ID
 *     tags: [Clinics]
 *     parameters:
 *       - in: path
 *         name: doctorId
 *         required: true
 *         schema:
 *           type: string
 *         description: Doctor ObjectId
 *     responses:
 *       200:
 *         description: Clinics found
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 count:
 *                   type: number
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Clinic'
 */
router.get('/doctor/:doctorId', async (req, res) => {
  try {
    const { doctorId } = req.params;
    const numericDoctorId = parseInt(doctorId);

    const clinics = await Clinic.find({ 
      doctorId: numericDoctorId, 
      isActive: true 
    }).sort({ createdAt: -1 });

    // Fetch doctor information
    const doctor = await Doctor.findOne({ doctorId: numericDoctorId });
    const clinicsWithDoctorInfo = clinics.map(clinic => {
      const clinicObj = clinic.toObject();
      clinicObj.doctorInfo = doctor ? {
        _id: doctor._id,
        firstName: doctor.firstName,
        lastName: doctor.lastName,
        email: doctor.email,
        mobileNumber: doctor.mobileNumber
      } : null;
      return clinicObj;
    });

    res.status(200).json({
      success: true,
      count: clinicsWithDoctorInfo.length,
      data: clinicsWithDoctorInfo
    });
  } catch (error) {
    console.error('Get clinics by doctor error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

/**
 * @swagger
 * /api/clinics/doctor-mongo/{mongoId}:
 *   get:
 *     summary: Get clinics by doctor's MongoDB _id
 *     tags: [Clinics]
 *     parameters:
 *       - in: path
 *         name: mongoId
 *         required: true
 *         schema:
 *           type: string
 *         description: Doctor's MongoDB _id
 *     responses:
 *       200:
 *         description: Success
 */
router.get('/doctor-mongo/:mongoId', async (req, res) => {
  try {
    const { mongoId } = req.params;

    // First find the doctor by MongoDB _id
    const doctor = await Doctor.findById(mongoId);
    
    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    // Now get clinics by numeric doctorId
    const clinics = await Clinic.find({ 
      doctorId: doctor.doctorId, 
      isActive: true 
    }).sort({ createdAt: -1 });

    const clinicsWithDoctorInfo = clinics.map(clinic => {
      const clinicObj = clinic.toObject();
      clinicObj.doctorInfo = {
        _id: doctor._id,
        firstName: doctor.firstName,
        lastName: doctor.lastName,
        email: doctor.email,
        mobileNumber: doctor.mobileNumber
      };
      return clinicObj;
    });

    res.status(200).json({
      success: true,
      count: clinicsWithDoctorInfo.length,
      data: clinicsWithDoctorInfo
    });
  } catch (error) {
    console.error('Get clinics by doctor mongo ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

/**
 * @swagger
 * /api/clinics:
 *   post:
 *     summary: Create a new clinic
 *     tags: [Clinics]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - address
 *               - regNo
 *               - phoneNumber
 *               - clinicFee
 *               - doctor
 *             properties:
 *               name:
 *                 type: string
 *                 example: "City Medical Center"
 *               address:
 *                 type: string
 *                 example: "123 Main Street, City, State"
 *               regNo:
 *                 type: string
 *                 example: "REG123456"
 *               logo:
 *                 type: string
 *                 example: "data:image/jpeg;base64,..."
 *               phoneNumber:
 *                 type: string
 *                 example: "+1234567890"
 *               clinicFee:
 *                 type: number
 *                 example: 100
 *               doctor:
 *                 type: string
 *                 example: "507f1f77bcf86cd799439011"
 *     responses:
 *       201:
 *         description: Clinic created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   $ref: '#/components/schemas/Clinic'
 *       400:
 *         description: Bad request
 *       409:
 *         description: Doctor already has a clinic
 */
router.post('/', async (req, res) => {
  try {
    const { name, address, regNo, logo, phoneNumber, clinicFee, doctor } = req.body;

    // Validate required fields
    if (!name || !address || !regNo || !phoneNumber || !clinicFee || !doctor) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields: name, address, regNo, phoneNumber, clinicFee, doctor'
      });
    }

    // Check if doctor exists and get their numeric doctorId
    const doctorExists = await Doctor.findById(doctor);
    if (!doctorExists) {
      return res.status(400).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    // Allow multiple clinics per doctor - removed constraint

    // Check if registration number already exists
    const existingRegNo = await Clinic.findOne({ regNo, isActive: true });
    if (existingRegNo) {
      return res.status(400).json({
        success: false,
        message: 'Registration number already exists'
      });
    }

    // Check if this is the doctor's first clinic
    const existingClinics = await Clinic.find({ 
      doctorId: doctorExists.doctorId, 
      isActive: true 
    });

    const clinic = new Clinic({
      name: name.trim(),
      address: address.trim(),
      regNo: regNo.trim(),
      logo: logo || '',
      phoneNumber: phoneNumber.trim(),
      clinicFee: parseFloat(clinicFee),
      doctorId: doctorExists.doctorId, // Use numeric doctorId
      isOnline: existingClinics.length === 0 // Set online if this is the first clinic
    });

    const savedClinic = await clinic.save();
    
    // Attach doctor information
    savedClinic.doctorInfo = {
      _id: doctorExists._id,
      firstName: doctorExists.firstName,
      lastName: doctorExists.lastName,
      email: doctorExists.email,
      mobileNumber: doctorExists.mobileNumber
    };

    res.status(201).json({
      success: true,
      message: 'Clinic created successfully',
      data: savedClinic
    });
  } catch (error) {
    console.error('Create clinic error:', error);
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Registration number already exists'
      });
    }
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

/**
 * @swagger
 * /api/clinics/{id}:
 *   put:
 *     summary: Update clinic
 *     tags: [Clinics]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Clinic ObjectId
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               address:
 *                 type: string
 *               regNo:
 *                 type: string
 *               logo:
 *                 type: string
 *               phoneNumber:
 *                 type: string
 *               clinicFee:
 *                 type: number
 *     responses:
 *       200:
 *         description: Clinic updated successfully
 *       404:
 *         description: Clinic not found
 */
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Remove doctorId field from update data (can't change doctor)
    delete updateData.doctorId;

    const clinic = await Clinic.findByIdAndUpdate(
      id,
      { ...updateData, updatedAt: new Date() },
      { new: true, runValidators: true }
    );

    if (!clinic) {
      return res.status(404).json({
        success: false,
        message: 'Clinic not found'
      });
    }

    // Fetch doctor information
    const doctor = await Doctor.findOne({ doctorId: clinic.doctorId });
    const clinicObj = clinic.toObject();
    clinicObj.doctorInfo = doctor ? {
      _id: doctor._id,
      firstName: doctor.firstName,
      lastName: doctor.lastName,
      email: doctor.email,
      mobileNumber: doctor.mobileNumber
    } : null;

    res.status(200).json({
      success: true,
      message: 'Clinic updated successfully',
      data: clinicObj
    });
  } catch (error) {
    console.error('Update clinic error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

/**
 * @swagger
 * /api/clinics/{id}:
 *   delete:
 *     summary: Delete clinic (soft delete)
 *     tags: [Clinics]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Clinic ObjectId
 *     responses:
 *       200:
 *         description: Clinic deleted successfully
 *       404:
 *         description: Clinic not found
 */
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const clinic = await Clinic.findByIdAndUpdate(
      id,
      { isActive: false, updatedAt: new Date() },
      { new: true }
    );

    if (!clinic) {
      return res.status(404).json({
        success: false,
        message: 'Clinic not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Clinic deleted successfully'
    });
  } catch (error) {
    console.error('Delete clinic error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

/**
 * @swagger
 * /api/clinics/{id}/online:
 *   put:
 *     summary: Toggle clinic online status
 *     tags: [Clinics]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Clinic ObjectId
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               isOnline:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Clinic status updated successfully
 *       404:
 *         description: Clinic not found
 */
router.put('/:id/online', async (req, res) => {
  try {
    const { id } = req.params;
    const { isOnline } = req.body;

    // Find the clinic
    const clinic = await Clinic.findById(id);
    
    if (!clinic) {
      return res.status(404).json({
        success: false,
        message: 'Clinic not found'
      });
    }

    // If setting clinic online, set all other clinics of the same doctor to offline
    if (isOnline === true) {
      await Clinic.updateMany(
        { doctorId: clinic.doctorId, _id: { $ne: id }, isActive: true },
        { isOnline: false }
      );
    }

    // Update the clinic's online status
    const updatedClinic = await Clinic.findByIdAndUpdate(
      id,
      { isOnline, updatedAt: new Date() },
      { new: true, runValidators: true }
    );

    // Fetch doctor information
    const doctor = await Doctor.findOne({ doctorId: updatedClinic.doctorId });
    const clinicObj = updatedClinic.toObject();
    clinicObj.doctorInfo = doctor ? {
      _id: doctor._id,
      firstName: doctor.firstName,
      lastName: doctor.lastName,
      email: doctor.email,
      mobileNumber: doctor.mobileNumber
    } : null;

    res.status(200).json({
      success: true,
      message: isOnline ? 'Clinic set online successfully' : 'Clinic set offline successfully',
      data: clinicObj
    });
  } catch (error) {
    console.error('Toggle clinic online error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

/**
 * @swagger
 * /api/clinics/doctor-mongo/{mongoId}/auto-online:
 *   post:
 *     summary: Auto-set clinic online (for single clinic doctors)
 *     tags: [Clinics]
 *     parameters:
 *       - in: path
 *         name: mongoId
 *         required: true
 *         schema:
 *           type: string
 *         description: Doctor's MongoDB _id
 *     responses:
 *       200:
 *         description: Auto-set online completed
 *       404:
 *         description: No clinics found
 */
router.post('/doctor-mongo/:mongoId/auto-online', async (req, res) => {
  try {
    const { mongoId } = req.params;

    // Find the doctor by MongoDB _id
    const doctor = await Doctor.findById(mongoId);
    
    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    // Get all clinics for this doctor
    const clinics = await Clinic.find({ 
      doctorId: doctor.doctorId, 
      isActive: true 
    }).sort({ createdAt: 1 });

    if (clinics.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No clinics found for this doctor'
      });
    }

    // Check if any clinic is already online
    const onlineClinic = clinics.find(c => c.isOnline === true);
    
    if (onlineClinic) {
      // Already have an online clinic
      return res.status(200).json({
        success: true,
        message: 'Clinic already online',
        data: onlineClinic
      });
    }

    // If only one clinic, auto-set it online
    if (clinics.length === 1) {
      clinics[0].isOnline = true;
      await clinics[0].save();
      
      const clinicObj = clinics[0].toObject();
      clinicObj.doctorInfo = {
        _id: doctor._id,
        firstName: doctor.firstName,
        lastName: doctor.lastName,
        email: doctor.email,
        mobileNumber: doctor.mobileNumber
      };
      
      return res.status(200).json({
        success: true,
        message: 'Single clinic set online automatically',
        data: clinicObj,
        needsSelection: false
      });
    }

    // Multiple clinics - return list for manual selection
    const clinicsData = clinics.map(clinic => {
      const clinicObj = clinic.toObject();
      clinicObj.doctorInfo = {
        _id: doctor._id,
        firstName: doctor.firstName,
        lastName: doctor.lastName,
        email: doctor.email,
        mobileNumber: doctor.mobileNumber
      };
      return clinicObj;
    });

    return res.status(200).json({
      success: true,
      message: 'Multiple clinics found - please select one to set online',
      data: clinicsData,
      needsSelection: true
    });
  } catch (error) {
    console.error('Auto-set clinic online error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
});

module.exports = router;
