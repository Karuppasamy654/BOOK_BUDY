const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  const Review = sequelize.define('Review', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'user_id',
      references: {
        model: 'users',
        key: 'id'
      }
    },
    hotelId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'hotel_id',
      references: {
        model: 'hotels',
        key: 'id'
      }
    },
    bookingId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'booking_id',
      references: {
        model: 'bookings',
        key: 'id'
      }
    },
    rating: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 5
      }
    },
    title: {
      type: DataTypes.STRING(200),
      allowNull: true
    },
    comment: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    isVerified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
      field: 'is_verified'
    },
    isPublic: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      field: 'is_public'
    },
    helpful: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    notHelpful: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      field: 'not_helpful'
    },
    response: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    respondedBy: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'responded_by',
      references: {
        model: 'users',
        key: 'id'
      }
    },
    respondedAt: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'responded_at'
    }
  }, {
    tableName: 'reviews',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        fields: ['user_id']
      },
      {
        fields: ['hotel_id']
      },
      {
        fields: ['booking_id']
      },
      {
        fields: ['rating']
      },
      {
        fields: ['is_verified']
      },
      {
        fields: ['is_public']
      }
    ]
  });

  Review.prototype.markHelpful = function() {
    return this.increment('helpful');
  };

  Review.prototype.markNotHelpful = function() {
    return this.increment('not_helpful');
  };

  Review.prototype.addResponse = function(response, respondedBy) {
    return this.update({
      response,
      respondedBy,
      respondedAt: new Date()
    });
  };

  Review.findByHotel = function(hotelId) {
    return this.findAll({
      where: { hotelId, isPublic: true },
      order: [['createdAt', 'DESC']]
    });
  };

  Review.findByUser = function(userId) {
    return this.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']]
    });
  };

  Review.getAverageRating = function(hotelId) {
    return this.findOne({
      where: { hotelId, isPublic: true },
      attributes: [
        [sequelize.fn('AVG', sequelize.col('rating')), 'averageRating'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'totalReviews']
      ],
      raw: true
    });
  };

  Review.getRatingDistribution = function(hotelId) {
    return this.findAll({
      where: { hotelId, isPublic: true },
      attributes: [
        'rating',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['rating'],
      order: [['rating', 'DESC']],
      raw: true
    });
  };

  Review.associate = function(models) {
    Review.belongsTo(models.User, {
      foreignKey: 'user_id',
      as: 'user'
    });

    Review.belongsTo(models.Hotel, {
      foreignKey: 'hotel_id',
      as: 'hotel'
    });

    Review.belongsTo(models.Booking, {
      foreignKey: 'booking_id',
      as: 'booking'
    });

    Review.belongsTo(models.User, {
      foreignKey: 'responded_by',
      as: 'respondedByUser'
    });
  };

  return Review;
};
