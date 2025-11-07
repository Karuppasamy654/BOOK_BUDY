'use strict';
const fs = require('fs');
const path = require('path');
const { DataTypes, Sequelize } = require('sequelize');
const { sequelize } = require('../config/database');
const basename = path.basename(__filename);

const db = {};

fs.readdirSync(__dirname)
  .filter(file => {
    if (file.indexOf('.') === 0) return false;
    if (file === basename) return false;
    if (!file.endsWith('.js')) return false;
    if (file === 'Food.js') return false;
    return true;
  })
  .forEach(file => {
    const model = require(path.join(__dirname, file))(sequelize, DataTypes);
    db[model.name] = model;
  });

Object.keys(db).forEach(modelName => {
  if (typeof db[modelName].associate === 'function') {
    db[modelName].associate(db);
  }
});

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;