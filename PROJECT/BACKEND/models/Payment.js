const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  const Payment = sequelize.define('Payment', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    bookingId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'booking_id',
      references: {
        model: 'bookings',
        key: 'id'
      }
    },
    amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      validate: {
        min: 0
      }
    },
    currency: {
      type: DataTypes.STRING(3),
      defaultValue: 'INR',
      allowNull: false
    },
    method: {
      type: DataTypes.ENUM('cash', 'card', 'razorpay', 'stripe'),
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM('pending', 'completed', 'failed', 'cancelled', 'refunded'),
      defaultValue: 'pending',
      allowNull: false
    },
    transactionId: {
      type: DataTypes.STRING(255),
      allowNull: true,
      field: 'transaction_id'
    },
    paymentGateway: {
      type: DataTypes.STRING(50),
      allowNull: true,
      field: 'payment_gateway'
    },
    gatewayResponse: {
      type: DataTypes.JSONB,
      allowNull: true,
      field: 'gateway_response'
    },
    refundAmount: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.0,
      field: 'refund_amount'
    },
    refundReason: {
      type: DataTypes.TEXT,
      allowNull: true,
      field: 'refund_reason'
    },
    refundedAt: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'refunded_at'
    },
    processedAt: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'processed_at'
    }
  }, {
    tableName: 'payments',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        fields: ['booking_id']
      },
      {
        fields: ['transaction_id']
      },
      {
        fields: ['status']
      },
      {
        fields: ['method']
      },
      {
        fields: ['payment_gateway']
      }
    ]
  });

  Payment.prototype.complete = function(transactionId, gatewayResponse = null) {
    return this.update({
      status: 'completed',
      transactionId,
      gatewayResponse,
      processedAt: new Date()
    });
  };

  Payment.prototype.fail = function(reason) {
    return this.update({
      status: 'failed',
      gatewayResponse: { error: reason }
    });
  };

  Payment.prototype.refund = function(amount, reason) {
    return this.update({
      status: 'refunded',
      refundAmount: amount,
      refundReason: reason,
      refundedAt: new Date()
    });
  };

  Payment.findByBooking = function(bookingId) {
    return this.findAll({
      where: { bookingId },
      order: [['createdAt', 'DESC']]
    });
  };

  Payment.findByTransaction = function(transactionId) {
    return this.findOne({
      where: { transactionId }
    });
  };

  Payment.getRevenueStats = function(hotelId = null, startDate = null, endDate = null) {
    const whereClause = { status: 'completed' };
    
    if (startDate && endDate) {
      whereClause.processedAt = {
        [sequelize.Op.between]: [startDate, endDate]
      };
    }

    return this.findAll({
      where: whereClause,
      attributes: [
        [sequelize.fn('COUNT', sequelize.col('id')), 'totalPayments'],
        [sequelize.fn('SUM', sequelize.col('amount')), 'totalRevenue'],
        [sequelize.fn('AVG', sequelize.col('amount')), 'averageAmount']
      ],
      raw: true
    });
  };

  Payment.associate = function(models) {
    Payment.belongsTo(models.Booking, {
      foreignKey: 'booking_id',
      as: 'booking'
    });
  };

  return Payment;
};
