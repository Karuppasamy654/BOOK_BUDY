'use strict';

module.exports = {
  async up(queryInterface) {
    await queryInterface.sequelize.query(`
      ALTER TABLE assigned_task
      ADD COLUMN IF NOT EXISTS hotel_id INT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE;
    `);
    await queryInterface.sequelize.query(`
      DO $$ BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns
          WHERE table_name = 'assigned_task' AND column_name = 'shift'
        ) THEN
          ALTER TABLE assigned_task
          ADD COLUMN shift VARCHAR(16) NOT NULL DEFAULT 'Morning';
          ALTER TABLE assigned_task
          ADD CONSTRAINT assigned_task_shift_check CHECK (shift IN ('Morning','Evening','Night'));
        END IF;
      END $$;
    `);
  },

  async down(queryInterface) {
    await queryInterface.sequelize.query(`
      ALTER TABLE assigned_task DROP CONSTRAINT IF EXISTS assigned_task_shift_check;
    `);
    await queryInterface.sequelize.query(`
      ALTER TABLE assigned_task DROP COLUMN IF EXISTS shift;
    `);
    await queryInterface.sequelize.query(`
      ALTER TABLE assigned_task DROP COLUMN IF EXISTS hotel_id;
    `);
  }
};
