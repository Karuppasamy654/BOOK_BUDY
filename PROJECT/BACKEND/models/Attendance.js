const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  const Attendance = sequelize.define('Attendance', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    staffId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'staff_id',
      references: {
        model: 'staff',
        key: 'id'
      }
    },
    date: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    checkIn: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'check_in'
    },
    checkOut: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'check_out'
    },
    status: {
      type: DataTypes.ENUM('present', 'absent', 'late', 'half_day', 'overtime'),
      defaultValue: 'present',
      allowNull: false
    },
    hoursWorked: {
      type: DataTypes.DECIMAL(4, 2),
      defaultValue: 0.0,
      field: 'hours_worked'
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    approvedBy: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'approved_by',
      references: {
        model: 'users',
        key: 'id'
      }
    },
    approvedAt: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'approved_at'
    }
  }, {
    tableName: 'attendance',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        fields: ['staff_id']
      },
      {
        fields: ['date']
      },
      {
        fields: ['status']
      },
      {
        unique: true,
        fields: ['staff_id', 'date']
      }
    ]
  });

  Attendance.prototype.calculateHours = function() {
    if (this.checkIn && this.checkOut) {
      const hours = (new Date(this.checkOut) - new Date(this.checkIn)) / (1000 * 60 * 60);
      return Math.round(hours * 100) / 100;
    }
    return 0;
  };

  Attendance.prototype.approve = function(approvedBy) {
    return this.update({
      approvedBy,
      approvedAt: new Date()
    });
  };

  Attendance.findByStaff = function(staffId, startDate = null, endDate = null) {
    const whereClause = { staffId };
    
    if (startDate && endDate) {
      whereClause.date = {
        [sequelize.Op.between]: [startDate, endDate]
      };
    }
    
    return this.findAll({
      where: whereClause,
      order: [['date', 'DESC']]
    });
  };

  Attendance.findByDate = function(date) {
    return this.findAll({
      where: { date }
    });
  };

  Attendance.getStats = function(staffId, startDate, endDate) {
    return this.findAll({
      where: {
        staffId,
        date: {
          [sequelize.Op.between]: [startDate, endDate]
        }
      },
      attributes: [
        'status',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count'],
        [sequelize.fn('SUM', sequelize.col('hours_worked')), 'totalHours']
      ],
      group: ['status'],
      raw: true
    });
  };

  Attendance.associate = function(models) {
    Attendance.belongsTo(models.Staff, {
      foreignKey: 'staff_id',
      as: 'staff'
    });

    Attendance.belongsTo(models.User, {
      foreignKey: 'approved_by',
      as: 'approvedByUser'
    });
  };

  return Attendance;
};
