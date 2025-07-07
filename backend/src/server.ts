// PLIK: backend/src/server.js
// ŹRÓDŁO: complete_setup_guide artifact (sekcja 3.5)

require('dotenv').config();
require('reflect-metadata');

const app = require('./app');
const { initializeDatabase, closeDatabaseConnection } = require('./config/database');

const PORT = process.env.PORT || 3000;

// Initialize database and start server
const startServer = async () => {
  try {
    // Initialize TypeORM database connection
    await initializeDatabase();
    
    // Start server
    const server = app.listen(PORT, () => {
      console.log(`🚀 AquaManager API server running on port ${PORT}`);
      console.log(`📡 Health check: http://localhost:${PORT}/health`);
      console.log(`📚 API docs: http://localhost:${PORT}/api/docs`);
    });

    // Graceful shutdown
    const gracefulShutdown = (signal: string) => {
      console.log(`${signal} received, shutting down gracefully`);
      server.close(async () => {
        await closeDatabaseConnection();
        console.log('Server closed');
        process.exit(0);
      });
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));
    
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();