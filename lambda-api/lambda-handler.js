const serverlessExpress = require('@codegenie/serverless-express');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const { Pool } = require('pg');
require('dotenv').config();

// Initialize Express app
const app = express();

// Database connection pool for Lambda
let dbPool;

const getDbPool = () => {
  if (!dbPool) {
    dbPool = new Pool({
      user: process.env.DB_USER,
      host: process.env.DB_HOST,
      database: process.env.DB_NAME,
      password: process.env.DB_PASSWORD,
      port: process.env.DB_PORT || 5432,
      max: 1,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
      ssl: {
        rejectUnauthorized: false
      }
    });
  }
  return dbPool;
};

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || '*',
  credentials: true
}));
app.use(compression());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check endpoint with database connection test
app.get('/health', async (req, res) => {
  try {
    const pool = getDbPool();
    // Test database connection
    const dbResult = await pool.query('SELECT NOW() as timestamp, version()');
    
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      environment: 'lambda',
      database: {
        connected: true,
        serverTime: dbResult.rows[0].timestamp,
        version: dbResult.rows[0].version.split(' ')[0] // Just PostgreSQL version
      }
    });
  } catch (error) {
    console.error('Health check - database error:', error);
    res.status(503).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      environment: 'lambda',
      database: {
        connected: false,
        error: error.message
      }
    });
  }
});

// API Info endpoint with database stats
app.get('/api', async (req, res) => {
  try {
    const pool = getDbPool();
    
    // Get basic stats from database
    const statsQuery = `
      SELECT 
        (SELECT COUNT(*) FROM aquariums) as aquarium_count,
        (SELECT COUNT(*) FROM fish) as fish_count,
        (SELECT COUNT(*) FROM tasks) as task_count,
        (SELECT COUNT(*) FROM tasks WHERE is_completed = false) as pending_tasks
    `;
    
    const stats = await pool.query(statsQuery);
    
    res.json({
      name: 'AquaManager API',
      version: '1.0.0',
      description: 'AquaManager API running on AWS Lambda with PostgreSQL RDS',
      environment: 'production',
      database: {
        connected: true,
        stats: {
          aquariums: parseInt(stats.rows[0].aquarium_count),
          fish: parseInt(stats.rows[0].fish_count),
          tasks: parseInt(stats.rows[0].task_count),
          pendingTasks: parseInt(stats.rows[0].pending_tasks)
        }
      },
      endpoints: {
        health: '/health',
        api: '/api',
        aquariums: {
          list: 'GET /api/aquariums',
          get: 'GET /api/aquariums/:id',
          create: 'POST /api/aquariums',
          update: 'PUT /api/aquariums/:id',
          delete: 'DELETE /api/aquariums/:id',
          fish: 'GET /api/aquariums/:id/fish',
          tasks: 'GET /api/aquariums/:id/tasks'
        },
        fish: {
          list: 'GET /api/fish',
          create: 'POST /api/fish'
        },
        tasks: {
          list: 'GET /api/tasks',
          create: 'POST /api/tasks',
          complete: 'PATCH /api/tasks/:id/complete',
          delete: 'DELETE /api/tasks/:id'
        }
      }
    });
  } catch (error) {
    console.error('API info - database error:', error);
    // Return basic info without stats if database fails
    res.json({
      name: 'AquaManager API',
      version: '1.0.0',
      description: 'AquaManager API running on AWS Lambda',
      environment: 'production',
      database: {
        connected: false,
        error: 'Database connection failed'
      }
    });
  }
});

// Default route
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to AquaManager API on AWS Lambda',
    version: '1.0.0'
  });
});

// Utility functions for case conversion
const toCamelCase = (str) => {
  return str.replace(/_([a-z])/g, (match, letter) => letter.toUpperCase());
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

// AQUARIUM ENDPOINTS
app.get('/api/aquariums', async (req, res) => {
  try {
    const pool = getDbPool();
    const result = await pool.query('SELECT * FROM aquariums ORDER BY created_at DESC');
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
      error: 'Failed to fetch aquariums',
      details: error.message
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
    
    const pool = getDbPool();
    const result = await pool.query(
      `INSERT INTO aquariums (name, capacity, water_type, temperature, ph) 
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [name, parseFloat(capacity), waterType, temperature ? parseFloat(temperature) : null, ph ? parseFloat(ph) : null]
    );
    
    const camelCaseData = convertKeysToCamelCase(result.rows[0]);
    
    res.status(201).json({
      success: true,
      data: camelCaseData,
      message: 'Aquarium created successfully'
    });
  } catch (error) {
    console.error('Error creating aquarium:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create aquarium',
      details: error.message
    });
  }
});

app.get('/api/aquariums/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const pool = getDbPool();
    
    const result = await pool.query('SELECT * FROM aquariums WHERE id = $1', [parseInt(id)]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Aquarium not found'
      });
    }
    
    const camelCaseData = convertKeysToCamelCase(result.rows[0]);
    
    res.json({
      success: true,
      data: camelCaseData
    });
  } catch (error) {
    console.error('Error fetching aquarium:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch aquarium',
      details: error.message
    });
  }
});

app.put('/api/aquariums/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, capacity, waterType, temperature, ph, status } = req.body;
    
    const pool = getDbPool();
    const result = await pool.query(
      `UPDATE aquariums 
       SET name = COALESCE($1, name), 
           capacity = COALESCE($2, capacity),
           water_type = COALESCE($3, water_type),
           temperature = COALESCE($4, temperature),
           ph = COALESCE($5, ph),
           status = COALESCE($6, status),
           updated_at = NOW()
       WHERE id = $7 RETURNING *`,
      [name, capacity ? parseFloat(capacity) : null, waterType, 
       temperature ? parseFloat(temperature) : null, ph ? parseFloat(ph) : null, 
       status, parseInt(id)]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Aquarium not found'
      });
    }
    
    const camelCaseData = convertKeysToCamelCase(result.rows[0]);
    
    res.json({
      success: true,
      data: camelCaseData,
      message: 'Aquarium updated successfully'
    });
  } catch (error) {
    console.error('Error updating aquarium:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update aquarium',
      details: error.message
    });
  }
});

app.delete('/api/aquariums/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const pool = getDbPool();
    
    const result = await pool.query('DELETE FROM aquariums WHERE id = $1 RETURNING *', [parseInt(id)]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Aquarium not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Aquarium deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting aquarium:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete aquarium',
      details: error.message
    });
  }
});

// FISH ENDPOINTS
app.get('/api/fish', async (req, res) => {
  try {
    const pool = getDbPool();
    const result = await pool.query(`
      SELECT f.*, a.name as aquarium_name 
      FROM fish f 
      LEFT JOIN aquariums a ON f.aquarium_id = a.id 
      ORDER BY f.created_at DESC
    `);
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
      error: 'Failed to fetch fish',
      details: error.message
    });
  }
});

app.get('/api/aquariums/:aquariumId/fish', async (req, res) => {
  try {
    const { aquariumId } = req.params;
    const pool = getDbPool();
    
    const result = await pool.query(
      'SELECT * FROM fish WHERE aquarium_id = $1 ORDER BY created_at DESC',
      [parseInt(aquariumId)]
    );
    const camelCaseData = result.rows.map(convertKeysToCamelCase);
    
    res.json({
      success: true,
      data: camelCaseData,
      count: camelCaseData.length
    });
  } catch (error) {
    console.error('Error fetching fish for aquarium:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch fish',
      details: error.message
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
    
    const pool = getDbPool();
    
    // Check if aquarium exists
    const aquariumCheck = await pool.query('SELECT id FROM aquariums WHERE id = $1', [parseInt(aquariumId)]);
    if (aquariumCheck.rows.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid aquarium ID'
      });
    }
    
    const result = await pool.query(
      `INSERT INTO fish (name, species, aquarium_id, age, health)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [name, species, parseInt(aquariumId), age ? parseInt(age) : null, health || 'good']
    );
    
    // Update fish count in aquarium
    await pool.query(
      `UPDATE aquariums 
       SET fish_count = (SELECT COUNT(*) FROM fish WHERE aquarium_id = $1),
           updated_at = NOW()
       WHERE id = $1`,
      [parseInt(aquariumId)]
    );
    
    const camelCaseData = convertKeysToCamelCase(result.rows[0]);
    
    res.status(201).json({
      success: true,
      data: camelCaseData,
      message: 'Fish added successfully'
    });
  } catch (error) {
    console.error('Error adding fish:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add fish',
      details: error.message
    });
  }
});

// TASKS ENDPOINTS
app.get('/api/tasks', async (req, res) => {
  try {
    const pool = getDbPool();
    const result = await pool.query(`
      SELECT t.*, a.name as aquarium_name 
      FROM tasks t 
      LEFT JOIN aquariums a ON t.aquarium_id = a.id 
      ORDER BY t.due_date ASC
    `);
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
      error: 'Failed to fetch tasks',
      details: error.message
    });
  }
});

app.get('/api/aquariums/:aquariumId/tasks', async (req, res) => {
  try {
    const { aquariumId } = req.params;
    const pool = getDbPool();
    
    const result = await pool.query(
      'SELECT * FROM tasks WHERE aquarium_id = $1 ORDER BY due_date ASC',
      [parseInt(aquariumId)]
    );
    const camelCaseData = result.rows.map(convertKeysToCamelCase);
    
    res.json({
      success: true,
      data: camelCaseData,
      count: camelCaseData.length
    });
  } catch (error) {
    console.error('Error fetching tasks for aquarium:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch tasks',
      details: error.message
    });
  }
});

app.post('/api/tasks', async (req, res) => {
  try {
    const { title, taskType, dueDate, description, aquariumId } = req.body;
    
    // Basic validation
    if (!title || !taskType || !dueDate || !aquariumId) {
      return res.status(400).json({
        success: false,
        error: 'Title, taskType, dueDate, and aquariumId are required'
      });
    }
    
    const pool = getDbPool();
    
    // Check if aquarium exists
    const aquariumCheck = await pool.query('SELECT id FROM aquariums WHERE id = $1', [parseInt(aquariumId)]);
    if (aquariumCheck.rows.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Invalid aquarium ID'
      });
    }
    
    const result = await pool.query(
      `INSERT INTO tasks (title, task_type, due_date, description, aquarium_id)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [title, taskType, new Date(dueDate), description || null, parseInt(aquariumId)]
    );
    
    const camelCaseData = convertKeysToCamelCase(result.rows[0]);
    
    res.status(201).json({
      success: true,
      data: camelCaseData,
      message: 'Task created successfully'
    });
  } catch (error) {
    console.error('Error creating task:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create task',
      details: error.message
    });
  }
});

app.patch('/api/tasks/:id/complete', async (req, res) => {
  try {
    const { id } = req.params;
    const pool = getDbPool();
    
    const result = await pool.query(
      `UPDATE tasks 
       SET is_completed = true, 
           completed_at = NOW(),
           updated_at = NOW()
       WHERE id = $1 RETURNING *`,
      [parseInt(id)]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Task not found'
      });
    }
    
    const camelCaseData = convertKeysToCamelCase(result.rows[0]);
    
    res.json({
      success: true,
      data: camelCaseData,
      message: 'Task completed successfully'
    });
  } catch (error) {
    console.error('Error completing task:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to complete task',
      details: error.message
    });
  }
});

app.delete('/api/tasks/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const pool = getDbPool();
    
    const result = await pool.query('DELETE FROM tasks WHERE id = $1 RETURNING *', [parseInt(id)]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Task not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Task deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting task:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete task',
      details: error.message
    });
  }
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Create the serverless handler
const handler = serverlessExpress({ app });

module.exports = { handler };
