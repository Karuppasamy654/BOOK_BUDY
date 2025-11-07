const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  const RoomType = sequelize.define('RoomType', {
    room_type_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      field: 'room_type_id'
    },
    name: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true
    },
    max_capacity: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'max_capacity',
      validate: {
        min: 1
      }
    },
    price_multiplier: {
      type: DataTypes.DECIMAL(3, 2),
      defaultValue: 1.00,
      field: 'price_multiplier',
      validate: {
        min: 0.01
      }
    }
  }, {
    tableName: 'room_type',
    timestamps: false,
    underscored: true
  });

  RoomType.associate = function(models) {
    RoomType.hasMany(models.Room, {
      foreignKey: 'room_type_id',
      as: 'rooms'
    });
  };

  return RoomType;
};
