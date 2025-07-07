const { Pool } = require('pg');
require('dotenv').config();

// Import database initializer
const DatabaseInitializer = require('./utils/database-initializer');

// Database connection configuration
const dbConfig = {
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'aquamanager',
  password: process.env.DB_PASSWORD || 'password',
  port: process.env.DB_PORT || 5432,
  // Connection pool settings
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
  ssl: {
    rejectUnauthorized: false
  }
};

// Create connection pool
const pool = new Pool(dbConfig);

// Test connection on startup
pool.on('connect', () => {
  console.log('📦 Connected to PostgreSQL database');
});

pool.on('error', (err, client) => {
  console.error('❌ Unexpected error on idle client', err);
  process.exit(-1);
});

// Helper function to execute queries
const query = (text, params) => pool.query(text, params);

// Utility functions for case conversion
const toCamelCase = (str) => {
  return str.replace(/_([a-z])/g, (match, letter) => letter.toUpperCase());
};

const toSnakeCase = (str) => {
  return str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
};

const convertKeysToCamelCase = (obj) => {
  if (obj === null || obj === undefined || typeof obj !== 'object') {
    return obj;
  }
  
  if (Array.isArray(obj)) {
    return obj.map(convertKeysToCamelCase);
  }
  
  const converted = {};
  Object.keys(obj).forEach(key => {
    const camelKey = toCamelCase(key);
    const value = obj[key];
    
    if (value && typeof value === 'object' && !Array.isArray(value) && !(value instanceof Date)) {
      converted[camelKey] = convertKeysToCamelCase(value);
    } else {
      converted[camelKey] = value;
    }
  });
  
  return converted;
};

const convertKeysToSnakeCase = (obj) => {
  if (obj === null || obj === undefined || typeof obj !== 'object') {
    return obj;
  }
  
  if (Array.isArray(obj)) {
    return obj.map(convertKeysToSnakeCase);
  }
  
  const converted = {};
  Object.keys(obj).forEach(key => {
    const snakeKey = toSnakeCase(key);
    const value = obj[key];
    
    if (value && typeof value === 'object' && !Array.isArray(value) && !(value instanceof Date)) {
      converted[snakeKey] = convertKeysToSnakeCase(value);
    } else {
      converted[snakeKey] = value;
    }
  });
  
  return converted;
};

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await query('SELECT 1');
    res.json({
      status: 'healthy',
      service: 'AquaManager API',
      timestamp: new Date().toISOString(),
      database: 'connected'
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      service: 'AquaManager API',
      timestamp: new Date().toISOString(),
      database: 'disconnected',
      error: error.message
    });
  }
});

// API info endpoint
app.get('/api', (req, res) => {
  res.json({
    name: 'AquaManager API',
    version: '1.0.0',
    description: 'Backend API for aquarium management system',
    endpoints: {
      aquariums: '/api/aquariums',
      fish: '/api/fish',
      tasks: '/api/tasks'
    }
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to AquaManager API',
    version: '1.0.0',
    docs: '/api'
  });
});

// Aquarium Routes
app.get('/api/aquariums', async (req, res) => {
  try {
    const result = await query('SELECT * FROM aquariums ORDER BY created_at DESC');
    const camelCaseData = result.rows.map(convertKeysToCamelCase);
    
    res.json({
      success: true,
      data: camelCaseData,
      count: camelCaseData.length
    });
  } catch (error) {
    console.error('Error fetching aquariums:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch aquariums'
    });
  }
});

app.get('/api/aquariums/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const aquariumResult = await query('SELECT * FROM aquariums WHERE id = $1', [id]);
    
    if (aquariumResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Aquarium not found'
      });
    }
    
    // Get fish for this aquarium
    const fishResult = await query('SELECT * FROM fish WHERE aquarium_id = $1', [id]);
    
    const aquarium = convertKeysToCamelCase(aquariumResult.rows[0]);
    aquarium.fish = fishResult.rows.map(convertKeysToCamelCase);
    
    res.json({
      success: true,
      data: aquarium
    });
  } catch (error) {
    console.error('Error fetching aquarium:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch aquarium'
    });
  }
});

app.post('/api/aquariums', async (req, res) => {
  try {
    const { name, capacity, waterType, temperature, ph } = req.body;
    
    // Basic validation
    if (!name || !capacity || !waterType) {
      return res.status(400).json({
        success: false,
        error: 'Name, capacity, and waterType are required'
      });
    }
    
    const result = await query(`
      INSERT INTO aquariums (name, capacity, water_type, temperature, ph)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `, [name, parseFloat(capacity), waterType, temperature ? parseFloat(temperature) : null, ph ? parseFloat(ph) : null]);
    
    res.status(201).json({
      success: true,
      data: convertKeysToCamelCase(result.rows[0]),
      message: 'Aquarium created successfully'
    });
  } catch (error) {
    console.error('Error creating aquarium:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create aquarium'
    });
  }
});

app.put('/api/aquariums/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { name, capacity, waterType, temperature, ph, status } = req.body;
    
    const result = await query(`
      UPDATE aquariums 
      SET name = COALESCE($1, name),
          capacity = COALESCE($2, capacity),
          water_type = COALESCE($3, water_type),
          temperature = COALESCE($4, temperature),
          ph = COALESCE($5, ph),
          status = COALESCE($6, status),
          updated_at = NOW()
      WHERE id = $7
      RETURNING *
    `, [name, capacity ? parseFloat(capacity) : null, waterType, temperature ? parseFloat(temperature) : null, ph ? parseFloat(ph) : null, status, id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Aquarium not found'
      });
    }
    
    res.json({
      success: true,
      data: convertKeysToCamelCase(result.rows[0]),
      message: 'Aquarium updated successfully'
    });
  } catch (error) {
    console.error('Error updating aquarium:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update aquarium'
    });
  }
});

app.delete('/api/aquariums/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    
    const result = await query('DELETE FROM aquariums WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Aquarium not found'
      });
    }
    
    res.json({
      success: true,
      data: convertKeysToCamelCase(result.rows[0]),
      message: 'Aquarium deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting aquarium:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete aquarium'
    });
  }
});

// Fish Routes
app.get('/api/fish', async (req, res) => {
  try {
    const result = await query('SELECT * FROM fish ORDER BY created_at DESC');
    const camelCaseData = result.rows.map(convertKeysToCamelCase);
    
    res.json({
      success: true,
      data: camelCaseData,
      count: camelCaseData.length
    });
  } catch (error) {
    console.error('Error fetching fish:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch fish'
    });
  }
});

app.get('/api/aquariums/:aquariumId/fish', async (req, res) => {
  try {
    const aquariumId = parseInt(req.params.aquariumId);
    const result = await query('SELECT * FROM fish WHERE aquarium_id = $1 ORDER BY created_at DESC', [aquariumId]);
    const camelCaseData = result.rows.map(convertKeysToCamelCase);
    
    res.json({
      success: true,
      data: camelCaseData,
      count: camelCaseData.length
    });
  } catch (error) {
    console.error('Error fetching fish:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch fish'
    });
  }
});

app.post('/api/fish', async (req, res) => {
  try {
    const { name, species, aquariumId, age, health } = req.body;
    
    // Basic validation
    if (!name || !species || !aquariumId) {
      return res.status(400).json({
        success: false,
        error: 'Name, species, and aquariumId are required'
      });
    }
    
    // Check if aquarium exists
    const aquariumCheck = await query('SELECT id FROM aquariums WHERE id = $1', [parseInt(aquariumId)]);
    if (aquariumCheck.rows.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid aquarium ID'
      });
    }
    
    const result = await query(`
      INSERT INTO fish (name, species, aquarium_id, age, health)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `, [name, species, parseInt(aquariumId), age ? parseInt(age) : null, health || 'good']);
    
    // Update fish count in aquarium
    await query(`
      UPDATE aquariums 
      SET fish_count = (SELECT COUNT(*) FROM fish WHERE aquarium_id = $1)
      WHERE id = $1
    `, [parseInt(aquariumId)]);
    
    res.status(201).json({
      success: true,
      data: convertKeysToCamelCase(result.rows[0]),
      message: 'Fish added successfully'
    });
  } catch (error) {
    console.error('Error adding fish:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add fish'
    });
  }
});

// Task Routes
app.get('/api/tasks', async (req, res) => {
  try {
    const result = await query('SELECT * FROM tasks ORDER BY due_date ASC');
    const camelCaseData = result.rows.map(convertKeysToCamelCase);
    
    res.json({
      success: true,
      data: camelCaseData,
      count: camelCaseData.length
    });
  } catch (error) {
    console.error('Error fetching tasks:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch tasks'
    });
  }
});

app.get('/api/aquariums/:aquariumId/tasks', async (req, res) => {
  try {
    const aquariumId = parseInt(req.params.aquariumId);
    const result = await query('SELECT * FROM tasks WHERE aquarium_id = $1 ORDER BY due_date ASC', [aquariumId]);
    const camelCaseData = result.rows.map(convertKeysToCamelCase);
    
    res.json({
      success: true,
      data: camelCaseData,
      count: camelCaseData.length
    });
  } catch (error) {
    console.error('Error fetching tasks:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch tasks'
    });
  }
});

app.post('/api/tasks', async (req, res) => {
  try {
    const { title, taskType, dueDate, aquariumId } = req.body;
    
    // Basic validation
    if (!title || !taskType || !dueDate || !aquariumId) {
      return res.status(400).json({
        success: false,
        error: 'Title, taskType, dueDate, and aquariumId are required'
      });
    }
    
    // Check if aquarium exists
    const aquariumCheck = await query('SELECT id FROM aquariums WHERE id = $1', [parseInt(aquariumId)]);
    if (aquariumCheck.rows.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid aquarium ID'
      });
    }
    
    const result = await query(`
      INSERT INTO tasks (title, task_type, due_date, aquarium_id)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `, [title, taskType, new Date(dueDate), parseInt(aquariumId)]);
    
    res.status(201).json({
      success: true,
      data: convertKeysToCamelCase(result.rows[0]),
      message: 'Task created successfully'
    });
  } catch (error) {
    console.error('Error creating task:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create task'
    });
  }
});

app.patch('/api/tasks/:id/complete', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    
    const result = await query(`
      UPDATE tasks 
      SET is_completed = true, completed_at = NOW(), updated_at = NOW()
      WHERE id = $1
      RETURNING *
    `, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Task not found'
      });
    }
    
    res.json({
      success: true,
      data: convertKeysToCamelCase(result.rows[0]),
      message: 'Task marked as completed'
    });
  } catch (error) {
    console.error('Error completing task:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to complete task'
    });
  }
});

app.delete('/api/tasks/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    
    const result = await query('DELETE FROM tasks WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Task not found'
      });
    }
    
    res.json({
      success: true,
      data: convertKeysToCamelCase(result.rows[0]),
      message: 'Task deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting task:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete task'
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'production' ? 'Internal Server Error' : err.message
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Route not found',
    message: `The requested route ${req.originalUrl} does not exist`
  });
});

// Start server with database initialization
if (require.main === module) {
  const startServer = async () => {
    try {
      // Initialize database
      const dbInitializer = new DatabaseInitializer(pool);
      await dbInitializer.initialize();
      
      // Start server
      app.listen(PORT, () => {
        console.log(`🚀 AquaManager API server running on port ${PORT}`);
        console.log(`📡 Health check: http://localhost:${PORT}/health`);
        console.log(`📋 API info: http://localhost:${PORT}/api`);
        console.log(`💾 Database: Connected to ${process.env.DB_HOST || 'localhost'}`);
      });
    } catch (error) {
      console.error('❌ Failed to start server:', error);
      process.exit(1);
    }
  };

  startServer();
}

module.exports = app;
