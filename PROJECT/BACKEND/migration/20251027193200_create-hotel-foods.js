'use strict';

module.exports = {
  async up(queryInterface) {
    await queryInterface.sequelize.query(`
      CREATE TABLE IF NOT EXISTS hotel_foods (
        hotel_id INT NOT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE,
        food_item_id INT NOT NULL REFERENCES food_item(food_item_id) ON DELETE CASCADE,
        PRIMARY KEY (hotel_id, food_item_id)
      );
    `);
  },

  async down(queryInterface) {
    await queryInterface.sequelize.query(`
      DROP TABLE IF EXISTS hotel_foods;
    `);
  }
};
