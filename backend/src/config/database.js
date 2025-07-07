const { DataSource } = require('typeorm');
require('dotenv').config();

// TypeORM Configuration
const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT) || 5432,
  username: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'aquamanager',
  
  // Development settings
  synchronize: process.env.NODE_ENV === 'development',
  logging: process.env.NODE_ENV === 'development',
  
  // Entities
  entities: [
    __dirname + '/../models/*.js'
  ],
  
  // Migrations
  migrations: [
    __dirname + '/../migrations/*.js'
  ],
  
  // Subscribers
  subscribers: [
    __dirname + '/../subscribers/*.js'
  ],
  
  // Connection pool settings
  extra: {
    connectionLimit: 20,
    acquireTimeout: 60000,
    timeout: 60000,
  },
  
  // SSL settings for production
  ssl: process.env.NODE_ENV === 'production' ? {
    rejectUnauthorized: false
  } : false,
});

// Initialize connection
const initializeDatabase = async () => {
  try {
    await AppDataSource.initialize();
    console.log('✅ TypeORM Database connection established');
    
    // Run migrations in production
    if (process.env.NODE_ENV === 'production') {
      await AppDataSource.runMigrations();
      console.log('✅ Database migrations completed');
    }
    
    return AppDataSource;
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    process.exit(1);
  }
};

// Health check function
const checkDatabaseHealth = async () => {
  try {
    await AppDataSource.query('SELECT 1');
    return { status: 'healthy', timestamp: new Date().toISOString() };
  } catch (error) {
    return { 
      status: 'unhealthy', 
      error: error.message,
      timestamp: new Date().toISOString() 
    };
  }
};

// Close connection gracefully
const closeDatabaseConnection = async () => {
  try {
    await AppDataSource.destroy();
    console.log('✅ Database connection closed');
  } catch (error) {
    console.error('❌ Error closing database connection:', error);
  }
};

module.exports = {
  AppDataSource,
  initializeDatabase,
  checkDatabaseHealth,
  closeDatabaseConnection
};