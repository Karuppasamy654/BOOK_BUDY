module.exports = (sequelize, DataTypes) => {
  const Facility = sequelize.define('Facility', {
    facility_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), unique: true, allowNull: false }
  }, { tableName: 'facility', timestamps: false, underscored: true });
  Facility.associate = (models) => {
    Facility.belongsToMany(models.Hotel, { through: models.HotelFacility, foreignKey: 'facility_id', as: 'hotels' });
  };
  return Facility;
};