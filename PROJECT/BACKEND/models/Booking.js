module.exports = (sequelize, DataTypes) => {
  const Booking = sequelize.define('Booking', {
    booking_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    user_id: { type: DataTypes.INTEGER, allowNull: false },
    hotel_id: { type: DataTypes.INTEGER, allowNull: false },
    room_number: { type: DataTypes.STRING(10), allowNull: false },
    check_in_date: { type: DataTypes.DATEONLY, allowNull: false },
    check_out_date: { type: DataTypes.DATEONLY, allowNull: false },
    total_nights: { type: DataTypes.INTEGER, allowNull: false },
    grand_total: { type: DataTypes.DECIMAL(10,2), allowNull: false }
  }, { tableName: 'booking', timestamps: false, underscored: true });
  Booking.associate = (models) => {
    Booking.belongsTo(models.User, { foreignKey: 'user_id', as: 'user' });
    Booking.belongsTo(models.Hotel, { foreignKey: 'hotel_id', as: 'hotel' });
    Booking.hasMany(models.FoodOrder, { foreignKey: 'booking_id', as: 'foodOrders' });
  };
  return Booking;
};