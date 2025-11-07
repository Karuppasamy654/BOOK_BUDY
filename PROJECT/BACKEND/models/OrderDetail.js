const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  const OrderDetail = sequelize.define('OrderDetail', {
    order_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      field: 'order_id',
      references: {
        model: 'food_order',
        key: 'order_id'
      }
    },
    food_item_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      allowNull: false,
      field: 'food_item_id',
      references: {
        model: 'food_item',
        key: 'food_item_id'
      }
    },
    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 1
      }
    },
    subtotal: {
      type: DataTypes.DECIMAL(7, 2),
      allowNull: false,
      validate: {
        min: 0
      }
    }
  }, {
    tableName: 'order_detail',
    timestamps: false,
    underscored: true
  });

  OrderDetail.prototype.calculateSubtotal = function(price) {
    return (this.quantity * price).toFixed(2);
  };

  OrderDetail.associate = function(models) {
    OrderDetail.belongsTo(models.FoodOrder, {
      foreignKey: 'order_id',
      as: 'foodOrder'
    });

    OrderDetail.belongsTo(models.FoodItem, {
      foreignKey: 'food_item_id',
      as: 'foodItem'
    });
  };

  return OrderDetail;
};
