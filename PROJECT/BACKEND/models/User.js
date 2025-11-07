module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    user_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), allowNull: false },
    email: { type: DataTypes.STRING(100), unique: true, allowNull: false, validate: { isEmail: true } },
    password_hash: { type: DataTypes.STRING(255), allowNull: false },
    password: { type: DataTypes.BLOB, allowNull: true },
    password_plain_tmp: { type: DataTypes.TEXT, allowNull: true },
    role: { type: DataTypes.ENUM('Customer','Staff','Manager'), allowNull: false, defaultValue: 'Customer' },
    phone_number: { type: DataTypes.STRING(15), allowNull: true },
    hotel_id: { type: DataTypes.INTEGER, allowNull: true }
  }, {
    tableName: 'user',
    timestamps: false,
    underscored: true
  });
  User.associate = (models) => {
    User.belongsTo(models.Hotel, { foreignKey: 'hotel_id', as: 'hotel' });
    User.hasMany(models.Booking, { foreignKey: 'user_id', as: 'bookings' });
    if (models.StaffAssignment) {
      User.hasMany(models.StaffAssignment, { foreignKey: 'staff_id', as: 'staffAssignments' });
    }
  };
  return User;
};