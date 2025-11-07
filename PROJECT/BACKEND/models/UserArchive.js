module.exports = (sequelize, DataTypes) => {
  const UserArchive = sequelize.define('UserArchive', {
    user_id: { type: DataTypes.INTEGER, allowNull: false },
    name: { type: DataTypes.STRING(100), allowNull: false },
    email: { type: DataTypes.STRING(100), allowNull: false },
    role: { type: DataTypes.ENUM('Customer','Staff','Manager'), allowNull: false },
    phone_number: { type: DataTypes.STRING(15), allowNull: true },
    archived_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW }
  }, {
    tableName: 'user_archive',
    timestamps: false,
    underscored: true
  });
  UserArchive.removeAttribute('id');
  return UserArchive;
};
