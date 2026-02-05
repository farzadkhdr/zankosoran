const mysql = require('mysql2');
require('dotenv').config();

// ڕێکخستنەکانی پەیوەندیکردن بە داتابەیس
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'hospital_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// پەیوەندیەک بە MySQL دروست بکە
const promisePool = pool.promise();

module.exports = {
  query: async (sql, params) => {
    try {
      const [rows] = await promisePool.query(sql, params);
      return rows;
    } catch (error) {
      console.error('هەڵە لە کوێری داتابەیس:', error);
      throw error;
    }
  },
  
  execute: async (sql, params) => {
    try {
      const [result] = await promisePool.execute(sql, params);
      return result;
    } catch (error) {
      console.error('هەڵە لە جێبەجێکردنی داتابەیس:', error);
      throw error;
    }
  }
};
