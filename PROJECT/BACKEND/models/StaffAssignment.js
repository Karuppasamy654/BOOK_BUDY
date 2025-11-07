module.exports = (sequelize, DataTypes) => {
  const StaffAssignment = sequelize.define('StaffAssignment', {
    task_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    staff_id: { type: DataTypes.INTEGER, allowNull: false },
    hotel_id: { type: DataTypes.INTEGER, allowNull: true },
    title: { type: DataTypes.STRING(150), allowNull: false },
    details: { type: DataTypes.TEXT, allowNull: true },
    due_date: { type: DataTypes.DATEONLY, allowNull: true },
    shift: { type: DataTypes.ENUM('Morning','Evening','Night'), allowNull: false, defaultValue: 'Morning' },
    status: { type: DataTypes.ENUM('Pending','In Progress','Complete','Overdue'), allowNull: false, defaultValue: 'Pending' },
    assigned_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
  }, { tableName: 'assigned_task', timestamps: false, underscored: true });
  StaffAssignment.associate = (models) => {
    StaffAssignment.belongsTo(models.User, { foreignKey: 'staff_id', as: 'staff' });
    StaffAssignment.belongsTo(models.Hotel, { foreignKey: 'hotel_id', as: 'hotel' });
  };
  return StaffAssignment;
};