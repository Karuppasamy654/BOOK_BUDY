const express = require('express');
const { body, validationResult, query } = require('express-validator');
const { Hotel, User } = require('../models');
const { protect, authorize, checkHotelAccess, optionalAuth } = require('../middleware/auth');
const { asyncHandler, AppError } = require('../middleware/errorHandler');
const { uploadMultiple } = require('../middleware/upload');

const router = express.Router();

router.get('/', 
  optionalAuth,
  [
    query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
    query('city').optional().trim(),
    query('state').optional().trim(),
    query('minPrice').optional().isFloat({ min: 0 }).withMessage('Min price must be a positive number'),
    query('maxPrice').optional().isFloat({ min: 0 }).withMessage('Max price must be a positive number'),
    query('rating').optional().isFloat({ min: 0, max: 5 }).withMessage('Rating must be between 0 and 5'),
    query('amenities').optional().isString(),
    query('sort').optional().isIn(['price', '-price', 'rating', '-rating', 'name', '-name', 'createdAt', '-createdAt']),
    query('search').optional().trim()
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const whereClause = {};

    if (req.query.city) {
      whereClause.location = { [require('sequelize').Op.iLike]: `%${req.query.city}%` };
    }

    if (req.query.minPrice || req.query.maxPrice) {
      whereClause.base_price_per_night = {};
      if (req.query.minPrice) {
        whereClause.base_price_per_night[require('sequelize').Op.gte] = parseFloat(req.query.minPrice);
      }
      if (req.query.maxPrice) {
        whereClause.base_price_per_night[require('sequelize').Op.lte] = parseFloat(req.query.maxPrice);
      }
    }

    if (req.query.rating) {
      whereClause.rating = { [require('sequelize').Op.gte]: parseFloat(req.query.rating) };
    }

    if (req.query.search) {
      whereClause[require('sequelize').Op.or] = [
        { name: { [require('sequelize').Op.iLike]: `%${req.query.search}%` } },
        { location: { [require('sequelize').Op.iLike]: `%${req.query.search}%` } }
      ];
    }

    let order = [['hotel_id', 'DESC']];
    if (req.query.sort) {
      let sortField = req.query.sort.startsWith('-') ? req.query.sort.slice(1) : req.query.sort;
      const sortOrder = req.query.sort.startsWith('-') ? 'DESC' : 'ASC';
      if (sortField === 'createdAt') sortField = 'hotel_id';
      if (sortField === 'price') sortField = 'base_price_per_night';
      order = [[sortField, sortOrder]];
    }

    const count = await Hotel.count({ where: whereClause });
    const hotels = await Hotel.findAll({
      where: whereClause,
      order: order,
      limit: limit,
      offset: offset,
      attributes: ['hotel_id','name','location','address','rating','base_price_per_night','image_url'],
    });

    res.json({
      success: true,
      count: hotels.length,
      total: count,
      page,
      pages: Math.ceil(count / limit),
      data: hotels
    });
  })
);

router.get('/:id', asyncHandler(async (req, res) => {
  const hotel = await Hotel.findByPk(req.params.id, {
    attributes: ['hotel_id','name','location','address','rating','base_price_per_night','image_url']
  });

  if (!hotel) {
    return res.status(404).json({
      success: false,
      message: 'Hotel not found'
    });
  }

  res.json({
    success: true,
    data: hotel
  });
}));

router.post('/',
  protect,
  authorize('manager', 'admin'),
  uploadMultiple('hotelImages', 10),
  [
    body('name').trim().isLength({ min: 2, max: 100 }).withMessage('Hotel name must be 2-100 characters'),
    body('description').trim().isLength({ min: 10, max: 1000 }).withMessage('Description must be 10-1000 characters'),
    body('location.address').trim().notEmpty().withMessage('Address is required'),
    body('location.city').trim().notEmpty().withMessage('City is required'),
    body('location.state').trim().notEmpty().withMessage('State is required'),
    body('location.pincode').matches(/^\d{6}$/).withMessage('Pincode must be 6 digits'),
    body('contact.phone').matches(/^[6-9]\d{9}$/).withMessage('Phone must be 10 digits'),
    body('contact.email').isEmail().withMessage('Valid email is required'),
    body('roomTypes').isArray({ min: 1 }).withMessage('At least one room type is required'),
    body('amenities').isArray().withMessage('Amenities must be an array')
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const images = [];
    if (req.files && req.files.length > 0) {
      req.files.forEach((file, index) => {
        images.push({
          url: file.url,
          alt: `${req.body.name} - Image ${index + 1}`,
          isPrimary: index === 0
        });
      });
    }

    const hotelData = {
      name: req.body.name,
      location: req.body.location,
      address: req.body.location?.address || '',
      rating: req.body.rating || 0.0,
      base_price_per_night: req.body.base_price_per_night || 0,
      image_url: images.length > 0 ? images[0].url : null
    };

    const hotel = await Hotel.create(hotelData);

    res.status(201).json({
      success: true,
      message: 'Hotel created successfully',
      data: hotel
    });
  })
);

router.put('/:id',
  protect,
  checkHotelAccess,
  uploadMultiple('hotelImages', 10),
  [
    body('name').optional().trim().isLength({ min: 2, max: 100 }),
    body('description').optional().trim().isLength({ min: 10, max: 1000 }),
    body('location.address').optional().trim().notEmpty(),
    body('location.city').optional().trim().notEmpty(),
    body('location.state').optional().trim().notEmpty(),
    body('location.pincode').optional().matches(/^\d{6}$/),
    body('contact.phone').optional().matches(/^[6-9]\d{9}$/),
    body('contact.email').optional().isEmail()
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const hotel = await Hotel.findById(req.params.id);

    if (!hotel) {
      return res.status(404).json({
        success: false,
        message: 'Hotel not found'
      });
    }

    if (req.files && req.files.length > 0) {
      const newImages = req.files.map((file, index) => ({
        url: file.url,
        alt: `${hotel.name} - Image ${hotel.images.length + index + 1}`,
        isPrimary: false
      }));
      hotel.images.push(...newImages);
    }

    const allowedUpdates = [
      'name', 'description', 'location', 'contact', 'amenities', 
      'policies', 'roomTypes', 'status'
    ];

    allowedUpdates.forEach(field => {
      if (req.body[field] !== undefined) {
        hotel[field] = req.body[field];
      }
    });

    await hotel.save();

    res.json({
      success: true,
      message: 'Hotel updated successfully',
      data: hotel
    });
  })
);

router.delete('/:id',
  protect,
  authorize('admin'),
  asyncHandler(async (req, res) => {
    const hotel = await Hotel.findById(req.params.id);

    if (!hotel) {
      return res.status(404).json({
        success: false,
        message: 'Hotel not found'
      });
    }

    const Booking = require('../models/Booking');
    const activeBookings = await Booking.countDocuments({
      hotel: req.params.id,
      status: { $in: ['confirmed', 'checked_in'] }
    });

    if (activeBookings > 0) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete hotel with active bookings'
      });
    }

    await Hotel.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Hotel deleted successfully'
    });
  })
);

router.put('/:id/rooms/availability',
  protect,
  checkHotelAccess,
  [
    body('roomType').isIn(['standard', 'deluxe', 'suite', 'presidential']).withMessage('Invalid room type'),
    body('operation').isIn(['increase', 'decrease']).withMessage('Operation must be increase or decrease'),
    body('quantity').isInt({ min: 1 }).withMessage('Quantity must be a positive integer')
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { roomType, operation, quantity } = req.body;

    const hotel = await Hotel.findById(req.params.id);
    const room = hotel.roomTypes.find(r => r.type === roomType);

    if (!room) {
      return res.status(404).json({
        success: false,
        message: 'Room type not found'
      });
    }

    const success = hotel.updateRoomAvailability(roomType, quantity, operation);

    if (!success) {
      return res.status(400).json({
        success: false,
        message: 'Failed to update room availability'
      });
    }

    res.json({
      success: true,
      message: 'Room availability updated successfully',
      data: {
        roomType,
        availableRooms: room.availableRooms,
        totalRooms: room.totalRooms
      }
    });
  })
);

router.post('/:id/rooms/check-availability',
  [
    body('roomType').isIn(['standard', 'deluxe', 'suite', 'presidential']).withMessage('Invalid room type'),
    body('checkIn').isISO8601().withMessage('Check-in date must be valid'),
    body('checkOut').isISO8601().withMessage('Check-out date must be valid'),
    body('quantity').optional().isInt({ min: 1 }).withMessage('Quantity must be a positive integer')
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { roomType, checkIn, checkOut, quantity = 1 } = req.body;

    const hotel = await Hotel.findById(req.params.id);

    if (!hotel) {
      return res.status(404).json({
        success: false,
        message: 'Hotel not found'
      });
    }

    const isAvailable = hotel.checkRoomAvailability(roomType, new Date(checkIn), new Date(checkOut), quantity);

    res.json({
      success: true,
      data: {
        available: isAvailable,
        roomType,
        checkIn,
        checkOut,
        quantity
      }
    });
  })
);

router.get('/:id/statistics',
  protect,
  checkHotelAccess,
  asyncHandler(async (req, res) => {
    const Booking = require('../models/Booking');
    const FoodItem = require('../models/FoodItem');

    const hotel = await Hotel.findById(req.params.id);

    const totalBookings = await Booking.countDocuments({ hotel: req.params.id });
    const confirmedBookings = await Booking.countDocuments({ 
      hotel: req.params.id, 
      status: 'confirmed' 
    });
    const checkedInBookings = await Booking.countDocuments({ 
      hotel: req.params.id, 
      status: 'checked_in' 
    });

    const revenueData = await Booking.aggregate([
      { $match: { hotel: hotel._id, status: { $in: ['confirmed', 'checked_in', 'checked_out'] } } },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$pricing.totalAmount' },
          averageBookingValue: { $avg: '$pricing.totalAmount' }
        }
      }
    ]);

    const foodItems = await FoodItem.countDocuments({ hotel: req.params.id });
    const availableFoodItems = await FoodItem.countDocuments({ 
      hotel: req.params.id, 
      isAvailable: true 
    });

    const totalRooms = hotel.roomTypes.reduce((total, roomType) => total + roomType.totalRooms, 0);
    const availableRooms = hotel.roomTypes.reduce((total, roomType) => total + roomType.availableRooms, 0);
    const occupiedRooms = totalRooms - availableRooms;
    const occupancyRate = totalRooms > 0 ? (occupiedRooms / totalRooms) * 100 : 0;

    res.json({
      success: true,
      data: {
        bookings: {
          total: totalBookings,
          confirmed: confirmedBookings,
          checkedIn: checkedInBookings
        },
        revenue: revenueData[0] || { totalRevenue: 0, averageBookingValue: 0 },
        food: {
          totalItems: foodItems,
          availableItems: availableFoodItems
        },
        occupancy: {
          totalRooms,
          availableRooms,
          occupiedRooms,
          occupancyRate: Math.round(occupancyRate * 100) / 100
        },
        rating: {
          average: hotel.rating,
          reviewCount: hotel.reviewCount
        }
      }
    });
  })
);

router.post('/:id/staff',
  protect,
  checkHotelAccess,
  [
    body('user').isMongoId().withMessage('Valid user ID is required'),
    body('role').isIn(['receptionist', 'housekeeping', 'maintenance', 'security', 'food_service']).withMessage('Invalid role'),
    body('department').trim().notEmpty().withMessage('Department is required')
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { user, role, department } = req.body;

    const userExists = await User.findById(user);
    if (!userExists) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const hotel = await Hotel.findById(req.params.id);
    const existingStaff = hotel.staff.find(s => s.user.toString() === user);
    
    if (existingStaff) {
      return res.status(400).json({
        success: false,
        message: 'User is already staff at this hotel'
      });
    }

    hotel.staff.push({
      user,
      role,
      department,
      isActive: true
    });

    await hotel.save();

    res.status(201).json({
      success: true,
      message: 'Staff member added successfully',
      data: hotel.staff[hotel.staff.length - 1]
    });
  })
);

router.delete('/:id/staff/:staffId',
  protect,
  checkHotelAccess,
  asyncHandler(async (req, res) => {
    const hotel = await Hotel.findById(req.params.id);
    
    const staffIndex = hotel.staff.findIndex(s => s._id.toString() === req.params.staffId);
    
    if (staffIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Staff member not found'
      });
    }

    hotel.staff.splice(staffIndex, 1);
    await hotel.save();

    res.json({
      success: true,
      message: 'Staff member removed successfully'
    });
  })
);

module.exports = router;
