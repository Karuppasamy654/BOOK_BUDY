module.exports = (sequelize, DataTypes) => {
  const Hotel = sequelize.define('Hotel', {
    hotel_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(150), unique: true, allowNull: false },
    location: { type: DataTypes.STRING(100), allowNull: false },
    address: { type: DataTypes.TEXT, allowNull: true },
    rating: { type: DataTypes.DECIMAL(2,1), allowNull: true, defaultValue: 0.0 },
    base_price_per_night: { type: DataTypes.DECIMAL(10,2), allowNull: false },
    image_url: { type: DataTypes.STRING(255), allowNull: true }
  }, { tableName: 'hotel', timestamps: false, underscored: true });
  Hotel.associate = (models) => {
    Hotel.hasMany(models.Booking, { foreignKey: 'hotel_id', as: 'bookings' });
    Hotel.belongsToMany(models.Facility, { through: models.HotelFacility, foreignKey: 'hotel_id', as: 'facilities' });
    if (models.HotelFood && models.FoodItem) {
      Hotel.belongsToMany(models.FoodItem, { through: models.HotelFood, foreignKey: 'hotel_id', as: 'foods' });
    }
    Hotel.hasMany(models.User, { foreignKey: 'hotel_id', as: 'users' }); // managers/staff
  };
  return Hotel;
};