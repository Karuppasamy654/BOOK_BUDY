const express = require('express');
const router = express.Router();
const db = require('../models');
const { sequelize, Booking, User, Hotel, Room, RoomType, FoodOrder, OrderDetail, FoodItem } = db;
const auth = require('../middleware/auth');

router.post('/create', auth.protect, async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { hotel_id, room_number, check_in_date, check_out_date, food_items } = req.body;

    let room;
    if (room_number) {
      room = await Room.findOne({
        where: { room_number, hotel_id, status: 'Vacant' },
        include: [
          { model: Hotel, as: 'hotel' },
          { model: RoomType, as: 'roomType' }
        ],
        transaction: t
      });
    } else {
      room = await Room.findOne({
        where: { hotel_id, status: 'Vacant' },
        include: [
          { model: Hotel, as: 'hotel' },
          { model: RoomType, as: 'roomType' }
        ],
        order: [['room_number','ASC']],
        transaction: t
      });
    }

    if (!room) {
      await t.rollback();
      return res.status(400).json({ message: 'Room not available' });
    }

    const checkIn = new Date(check_in_date);
    const checkOut = new Date(check_out_date);
    const totalNights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));
    if (!Number.isFinite(totalNights) || totalNights <= 0) {
      await t.rollback();
      return res.status(400).json({ message: 'Invalid dates' });
    }
    const roomTotal = Number(room.hotel.base_price_per_night) * Number(room.roomType.price_multiplier) * totalNights;

    const booking = await Booking.create({
      user_id: req.user.user_id,
      hotel_id,
      room_number: room.room_number,
      check_in_date,
      check_out_date,
      total_nights: totalNights,
      grand_total: roomTotal
    }, { transaction: t });

    let foodOrder = null;
    let foodTotal = 0;
    let foodLines = [];
    if (Array.isArray(food_items) && food_items.length) {
      for (const it of food_items) {
        const qty = Number(it.quantity || 0);
        if (!it.food_item_id || qty <= 0) {
          await t.rollback();
          return res.status(400).json({ message: 'Invalid food item or quantity' });
        }
      }
      foodOrder = await FoodOrder.create({ booking_id: booking.booking_id, status: 'Pending' }, { transaction: t });

      for (const it of food_items) {
        const qty = Number(it.quantity);
        const item = await FoodItem.findByPk(it.food_item_id, { transaction: t });
        if (!item) {
          await t.rollback();
          return res.status(400).json({ message: `Food item ${it.food_item_id} not found` });
        }
        const unit = Number(item.price);
        const subtotal = unit * qty;
        foodTotal += subtotal;
        foodLines.push({ name: item.name, qty, unit, subtotal });
        await OrderDetail.create({
          order_id: foodOrder.order_id,
          food_item_id: it.food_item_id,
          quantity: qty,
          subtotal
        }, { transaction: t });
      }
    }

    await room.update({ status: 'Occupied' }, { transaction: t });

    await t.commit();

    try {
      const nodemailer = require('nodemailer');
      if (process.env.EMAIL_HOST && process.env.EMAIL_USER) {
        const transporter = nodemailer.createTransport({
          host: process.env.EMAIL_HOST,
          port: process.env.EMAIL_PORT,
          secure: false,
          auth: { user: process.env.EMAIL_USER, pass: process.env.EMAIL_PASS }
        });
        const user = await User.findOne({ where: { user_id: req.user.user_id }, attributes: ['email','name'] });

        let foodHtml = '';
        if (foodLines.length) {
          const foodRows = foodLines.map(l => `<li>${l.name} × ${l.qty} @ ₹${l.unit} = ₹${l.subtotal.toFixed(2)}</li>`).join('');
          foodHtml = `<h3>Food Order</h3><ul>${foodRows}</ul><p><strong>Food Total:</strong> ₹${foodTotal.toFixed(2)}</p>`;
        }
        const totalPayable = roomTotal + foodTotal;
        const html = `
          <h2>Booking Confirmed - ${room.hotel.name}</h2>
          <p>Dear ${user?.name || 'Guest'}, your booking has been created.</p>
          <ul>
            <li>Hotel: ${room.hotel.name}</li>
            <li>Room: ${room.room_number}</li>
            <li>Check-in: ${check_in_date}</li>
            <li>Check-out: ${check_out_date}</li>
            <li>Total Nights: ${totalNights}</li>
            <li>Room Amount: ₹${roomTotal.toFixed(2)}</li>
          </ul>
          ${foodHtml}
          <p><strong>Total Payable:</strong> ₹${totalPayable.toFixed(2)}</p>
        `;
        await transporter.sendMail({
          from: process.env.EMAIL_FROM || process.env.EMAIL_USER,
          to: user?.email,
          subject: 'Your Booking Details',
          html
        });
      }
    } catch (e) {
      console.warn('Booking email skipped/failed:', e.message);
    }

    const total_payable = Number((roomTotal + foodTotal).toFixed(2));

    return res.status(201).json({
      message: 'Booking created successfully',
      booking: {
        booking_id: booking.booking_id,
        hotel_name: room.hotel.name,
        room_number: booking.room_number,
        check_in_date: booking.check_in_date,
        check_out_date: booking.check_out_date,
        total_nights: booking.total_nights,
        room_total: roomTotal,
        food_total: foodTotal,
        total_payable
      },
      next: { payment: { booking_id: booking.booking_id, total_payable } }
    });
  } catch (error) {
    try { await t.rollback(); } catch (_) {}
    console.error('Error creating booking:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

router.get('/available-rooms', async (req, res) => {
  try {
    const { hotel_id } = req.query;
    if (!hotel_id) return res.status(400).json({ message: 'hotel_id is required' });
    const rooms = await Room.findAll({
      where: { hotel_id: Number(hotel_id), status: 'Vacant' },
      order: [['room_number','ASC']],
      attributes: ['room_number','hotel_id','status']
    });
    return res.json({ success: true, data: rooms });
  } catch (e) {
    console.error('List available rooms failed:', e);
    return res.status(500).json({ message: 'Server error' });
  }
});

router.get('/my-bookings', auth.protect, async (req, res) => {
  try {
    const bookings = await Booking.findAll({
      where: { user_id: req.user.user_id },
      include: [
        { model: Hotel, as: 'hotel' },
        { model: Room, as: 'room', include: [{ model: RoomType, as: 'roomType' }] }
      ],
      order: [['booking_date', 'DESC']]
    });
    
    res.json(bookings);
  } catch (error) {
    console.error('Error fetching bookings:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

router.get('/:booking_id/summary', auth.protect, async (req, res) => {
  try {
    const { booking_id } = req.params;
    const booking = await Booking.findOne({
      where: { booking_id, user_id: req.user.user_id },
      include: [{ model: Hotel, as: 'hotel' }]
    });
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    const order = await FoodOrder.findOne({
      where: { booking_id: booking.booking_id },
      include: [{ model: OrderDetail, as: 'orderDetails', include: [{ model: FoodItem, as: 'foodItem' }] }]
    });

    const room_total = Number(booking.grand_total);
    let food_total = 0;
    const items = [];
    if (order && order.orderDetails) {
      for (const d of order.orderDetails) {
        food_total += Number(d.subtotal);
        items.push({ food_item_id: d.food_item_id, name: d.foodItem?.name, quantity: d.quantity, subtotal: Number(d.subtotal) });
      }
    }

    return res.json({
      booking: {
        booking_id: booking.booking_id,
        hotel_id: booking.hotel_id,
        hotel: booking.hotel?.name,
        check_in_date: booking.check_in_date,
        check_out_date: booking.check_out_date,
        total_nights: booking.total_nights,
        room_total
      },
      food_order: order ? { order_id: order.order_id, status: order.status, items } : null,
      totals: { room_total, food_total, total_payable: Number((room_total + food_total).toFixed(2)) }
    });
  } catch (e) {
    console.error('Summary failed:', e);
    return res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;