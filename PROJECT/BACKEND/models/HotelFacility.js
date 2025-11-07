module.exports = (sequelize, DataTypes) => {
  const HotelFacility = sequelize.define('HotelFacility', {
    hotel_id: { type: DataTypes.INTEGER, allowNull: false, primaryKey: true },
    facility_id: { type: DataTypes.INTEGER, allowNull: false, primaryKey: true }
  }, { tableName: 'hotel_facility', timestamps: false, underscored: true });
  return HotelFacility;
};