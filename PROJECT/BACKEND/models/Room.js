const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  const Room = sequelize.define('Room', {
    room_number: {
      type: DataTypes.STRING(10),
      primaryKey: true,
      field: 'room_number'
    },
    hotel_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      field: 'hotel_id',
      references: {
        model: 'hotel',
        key: 'hotel_id'
      }
    },
    room_type_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'room_type_id',
      references: {
        model: 'room_type',
        key: 'room_type_id'
      }
    },
    status: {
      type: DataTypes.ENUM('Vacant', 'Occupied', 'Cleaning'),
      allowNull: false,
      validate: {
        isIn: [['Vacant', 'Occupied', 'Cleaning']]
      }
    }
  }, {
    tableName: 'room',
    timestamps: false,
    underscored: true
  });

  Room.associate = function(models) {
    Room.belongsTo(models.Hotel, {
      foreignKey: 'hotel_id',
      as: 'hotel'
    });

    Room.belongsTo(models.RoomType, {
      foreignKey: 'room_type_id',
      as: 'roomType'
    });

    
  };

  return Room;
};
