module.exports = (sequelize, DataTypes) => {
  const HotelFood = sequelize.define('HotelFood', {
    hotel_id: { type: DataTypes.INTEGER, allowNull: false, primaryKey: true },
    food_item_id: { type: DataTypes.INTEGER, allowNull: false, primaryKey: true },
    price: { type: DataTypes.DECIMAL(10,2), allowNull: true },
    stock: { type: DataTypes.INTEGER, allowNull: true }
  }, { tableName: 'hotel_foods', timestamps: false, underscored: true });
  return HotelFood;
};