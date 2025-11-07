const { DataTypes } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  const Task = sequelize.define('Task', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    title: {
      type: DataTypes.STRING(200),
      allowNull: false,
      validate: {
        notEmpty: true
      }
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    priority: {
      type: DataTypes.ENUM('low', 'medium', 'high', 'urgent'),
      defaultValue: 'medium',
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM('pending', 'in_progress', 'completed', 'cancelled'),
      defaultValue: 'pending',
      allowNull: false
    },
    assignedTo: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'assigned_to',
      references: {
        model: 'users',
        key: 'id'
      }
    },
    assignedBy: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'assigned_by',
      references: {
        model: 'users',
        key: 'id'
      }
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
    hotelId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'hotel_id',
      references: {
        model: 'hotels',
        key: 'id'
      }
    },
    dueDate: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'due_date'
    },
    completedAt: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'completed_at'
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    tags: {
      type: DataTypes.JSONB,
      defaultValue: []
    }
  }, {
    tableName: 'tasks',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        fields: ['assigned_to']
      },
      {
        fields: ['assigned_by']
      },
      {
        fields: ['staff_id']
      },
      {
        fields: ['hotel_id']
      },
      {
        fields: ['status']
      },
      {
        fields: ['priority']
      },
      {
        fields: ['due_date']
      }
    ]
  });

  Task.prototype.complete = function(notes = null) {
    return this.update({
      status: 'completed',
      completedAt: new Date(),
      notes: notes || this.notes
    });
  };

  Task.prototype.cancel = function(reason) {
    return this.update({
      status: 'cancelled',
      notes: reason
    });
  };

  Task.prototype.isOverdue = function() {
    if (!this.dueDate || this.status === 'completed' || this.status === 'cancelled') {
      return false;
    }
    return new Date() > new Date(this.dueDate);
  };

  Task.findByUser = function(userId) {
    return this.findAll({
      where: { assignedTo: userId },
      order: [['createdAt', 'DESC']]
    });
  };

  Task.findByStaff = function(staffId) {
    return this.findAll({
      where: { staffId },
      order: [['createdAt', 'DESC']]
    });
  };

  Task.findByHotel = function(hotelId) {
    return this.findAll({
      where: { hotelId },
      order: [['createdAt', 'DESC']]
    });
  };

  Task.findOverdue = function(hotelId = null) {
    const whereClause = {
      status: {
        [sequelize.Op.in]: ['pending', 'in_progress']
      },
      dueDate: {
        [sequelize.Op.lt]: new Date()
      }
    };
    
    if (hotelId) {
      whereClause.hotelId = hotelId;
    }
    
    return this.findAll({
      where: whereClause,
      order: [['dueDate', 'ASC']]
    });
  };

  Task.getStats = function(hotelId = null, startDate = null, endDate = null) {
    const whereClause = {};
    
    if (hotelId) {
      whereClause.hotelId = hotelId;
    }
    
    if (startDate && endDate) {
      whereClause.createdAt = {
        [sequelize.Op.between]: [startDate, endDate]
      };
    }

    return this.findAll({
      where: whereClause,
      attributes: [
        'status',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['status'],
      raw: true
    });
  };

  Task.associate = function(models) {
    Task.belongsTo(models.User, {
      foreignKey: 'assigned_to',
      as: 'assignedUser'
    });

    Task.belongsTo(models.User, {
      foreignKey: 'assigned_by',
      as: 'assignedByUser'
    });

    Task.belongsTo(models.Staff, {
      foreignKey: 'staff_id',
      as: 'staff'
    });

    Task.belongsTo(models.Hotel, {
      foreignKey: 'hotel_id',
      as: 'hotel'
    });
  };

  return Task;
};
