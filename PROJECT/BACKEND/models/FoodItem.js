module.exports = (sequelize, DataTypes) => {
  const FoodItem = sequelize.define('FoodItem', {
    food_item_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), allowNull: false, unique: true },
    price: { type: DataTypes.DECIMAL(7,2), allowNull: false },
    category: { type: DataTypes.ENUM('Breakfast','Lunch','Dinner','Beverages'), allowNull: false },
    type: { type: DataTypes.ENUM('Veg','Non-Veg','General'), allowNull: false }
  }, { tableName: 'food_item', timestamps: false, underscored: true });
  FoodItem.associate = (models) => {
    FoodItem.belongsToMany(models.Hotel, { through: models.HotelFood, foreignKey: 'food_item_id', as: 'hotels' });
  };
  return FoodItem;
};