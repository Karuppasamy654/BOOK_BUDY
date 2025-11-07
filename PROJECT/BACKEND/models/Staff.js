const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  const Staff = sequelize.define('Staff', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      unique: true,
      field: 'user_id',
      references: {
        model: 'users',
        key: 'id'
      }
    },
    hotelId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'hotel_id',
      references: {
        model: 'hotels',
        key: 'id'
      }
    },
    department: {
      type: DataTypes.ENUM('front_desk', 'housekeeping', 'food_service', 'maintenance', 'security', 'management', 'concierge'),
      allowNull: false
    },
    position: {
      type: DataTypes.STRING(100),
      allowNull: false,
      validate: {
        notEmpty: true
      }
    },
    role: {
      type: DataTypes.ENUM('staff', 'supervisor', 'manager', 'head'),
      defaultValue: 'staff',
      allowNull: false
    },
    shift: {
      type: DataTypes.ENUM('morning', 'afternoon', 'evening', 'night', 'flexible'),
      defaultValue: 'flexible',
      allowNull: false
    },
    salary: {
      type: DataTypes.JSONB,
      allowNull: false
    },
    hireDate: {
      type: DataTypes.DATEONLY,
      allowNull: false,
      field: 'hire_date'
    },
    permissions: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      field: 'is_active'
    },
    workSchedule: {
      type: DataTypes.JSONB,
      allowNull: true,
      field: 'work_schedule'
    },
    performance: {
      type: DataTypes.JSONB,
      defaultValue: {
        rating: 0,
        lastReview: null,
        nextReview: null
      }
    },
    documents: {
      type: DataTypes.JSONB,
      defaultValue: []
    }
  }, {
    tableName: 'staff',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        fields: ['user_id']
      },
      {
        fields: ['hotel_id']
      },
      {
        fields: ['department']
      },
      {
        fields: ['role']
      },
      {
        fields: ['is_active']
      }
    ]
  });

  Staff.prototype.addTask = function(taskData) {
    const tasks = this.tasks || [];
    const newTask = {
      id: require('uuid').v4(),
      ...taskData,
      status: 'pending',
      assignedAt: new Date()
    };
    tasks.push(newTask);
    return this.update({ tasks });
  };

  Staff.prototype.updateTaskStatus = function(taskId, status, notes = null) {
    const tasks = this.tasks || [];
    const taskIndex = tasks.findIndex(task => task.id === taskId);
    
    if (taskIndex === -1) return false;
    
    tasks[taskIndex].status = status;
    tasks[taskIndex].updatedAt = new Date();
    
    if (notes) {
      tasks[taskIndex].notes = notes;
    }
    
    if (status === 'completed') {
      tasks[taskIndex].completedAt = new Date();
    }
    
    return this.update({ tasks });
  };

  Staff.prototype.markAttendance = function(date, checkIn = null, checkOut = null) {
    const attendance = this.attendance || [];
    const attendanceRecord = {
      date: date,
      checkIn: checkIn,
      checkOut: checkOut,
      status: checkIn ? 'present' : 'absent',
      hoursWorked: 0
    };
    
    if (checkIn && checkOut) {
      const hours = (new Date(checkOut) - new Date(checkIn)) / (1000 * 60 * 60);
      attendanceRecord.hoursWorked = Math.round(hours * 100) / 100;
    }
    
    attendance.push(attendanceRecord);
    return this.update({ attendance });
  };

  Staff.prototype.getCurrentTasks = function() {
    return (this.tasks || []).filter(task => 
      task.status === 'pending' || task.status === 'in_progress'
    );
  };

  Staff.prototype.getOverdueTasks = function() {
    const now = new Date();
    return (this.tasks || []).filter(task => 
      task.status !== 'completed' && 
      task.status !== 'cancelled' && 
      task.dueDate && 
      new Date(task.dueDate) < now
    );
  };

  Staff.findByHotel = function(hotelId) {
    return this.findAll({
      where: { hotelId, isActive: true }
    });
  };

  Staff.findByDepartment = function(department, hotelId = null) {
    const whereClause = { department, isActive: true };
    if (hotelId) {
      whereClause.hotelId = hotelId;
    }
    return this.findAll({ where: whereClause });
  };

  Staff.getPerformanceStats = function(hotelId = null) {
    const whereClause = { isActive: true };
    if (hotelId) {
      whereClause.hotelId = hotelId;
    }
    
    return this.findAll({
      where: whereClause,
      attributes: [
        'department',
        [sequelize.fn('COUNT', sequelize.col('id')), 'totalStaff'],
        [sequelize.fn('AVG', sequelize.col('performance->rating')), 'averageRating']
      ],
      group: ['department'],
      raw: true
    });
  };

  Staff.associate = function(models) {
    Staff.belongsTo(models.User, {
      foreignKey: 'user_id',
      as: 'user'
    });

    Staff.belongsTo(models.Hotel, {
      foreignKey: 'hotel_id',
      as: 'hotel'
    });

    Staff.hasMany(models.Task, {
      foreignKey: 'staff_id',
      as: 'tasks'
    });

    Staff.hasMany(models.Attendance, {
      foreignKey: 'staff_id',
      as: 'attendance'
    });
  };

  return Staff;
};