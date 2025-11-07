'use strict';

module.exports = {
  async up(queryInterface) {
    await queryInterface.sequelize.query(`
      ALTER TABLE hotel
      ADD COLUMN IF NOT EXISTS max_staff INT NOT NULL DEFAULT 5;
    `);
    await queryInterface.sequelize.query(`
      ALTER TABLE hotel
      ADD COLUMN IF NOT EXISTS max_staff_per_shift INT NOT NULL DEFAULT 3;
    `);
  },

  async down(queryInterface) {
    await queryInterface.sequelize.query(`
      ALTER TABLE hotel DROP COLUMN IF EXISTS max_staff;
    `);
    await queryInterface.sequelize.query(`
      ALTER TABLE hotel DROP COLUMN IF EXISTS max_staff_per_shift;
    `);
  }
};
