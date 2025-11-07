const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  const AssignedTask = sequelize.define('AssignedTask', {
    task_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      field: 'task_id'
    },
    staff_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'staff_id',
      references: {
        model: 'user',
        key: 'user_id'
      }
    },
    title: {
      type: DataTypes.STRING(150),
      allowNull: false
    },
    details: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    due_date: {
      type: DataTypes.DATEONLY,
      allowNull: true,
      field: 'due_date'
    },
    status: {
      type: DataTypes.ENUM('Pending', 'In Progress', 'Complete', 'Overdue'),
      allowNull: false,
      validate: {
        isIn: [['Pending', 'In Progress', 'Complete', 'Overdue']]
      }
    },
    assigned_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
      field: 'assigned_at'
    }
  }, {
    tableName: 'assigned_task',
    timestamps: false,
    underscored: true
  });

  AssignedTask.prototype.updateStatus = function(newStatus) {
    return this.update({ status: newStatus });
  };

  AssignedTask.prototype.complete = function() {
    return this.update({ status: 'Complete' });
  };

  AssignedTask.prototype.isOverdue = function() {
    if (!this.due_date || this.status === 'Complete') {
      return false;
    }
    return new Date() > new Date(this.due_date);
  };

  AssignedTask.findByStaff = function(staffId) {
    return this.findAll({
      where: { staff_id: staffId },
      order: [['assigned_at', 'DESC']]
    });
  };

  AssignedTask.findOverdue = function() {
    return this.findAll({
      where: {
        status: {
          [sequelize.Op.in]: ['Pending', 'In Progress']
        },
        due_date: {
          [sequelize.Op.lt]: new Date()
        }
      }
    });
  };

  AssignedTask.associate = function(models) {
    AssignedTask.belongsTo(models.User, {
      foreignKey: 'staff_id',
      as: 'staff'
    });
  };

  return AssignedTask;
};
