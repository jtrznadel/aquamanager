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
      max: 1, // Lambda ma ograniczone połączenia
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

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: 'lambda'
  });
});

// API Info endpoint
app.get('/api', (req, res) => {
  res.json({
    name: 'AquaManager API',
    version: '1.0.0',
    description: 'AquaManager API running on AWS Lambda',
    endpoints: {
      health: '/health',
      api: '/api',
      aquariums: {
        list: 'GET /api/aquariums',
        get: 'GET /api/aquariums/:id',
        create: 'POST /api/aquariums',
        update: 'PUT /api/aquariums/:id',
        delete: 'DELETE /api/aquariums/:id'
      },
      fish: {
        list: 'GET /api/fish',
        create: 'POST /api/fish'
      },
      tasks: {
        list: 'GET /api/tasks',
        create: 'POST /api/tasks',
        complete: 'PATCH /api/tasks/:id/complete'
      }
    }
  });
});

// Default route
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to AquaManager API on AWS Lambda',
    version: '1.0.0'
  });
});

// Mock data dla testów (zastąp prawdziwymi zapytaniami do RDS)
const mockAquariums = [
  {
    id: 1,
    name: "Main Tank",
    capacity: 100,
    waterType: "freshwater",
    temperature: 24.5,
    ph: 7.2,
    fishCount: 15,
    status: "healthy"
  }
];

// AQUARIUM ENDPOINTS
app.get('/api/aquariums', async (req, res) => {
  try {
    const pool = getDbPool();
    // Przykładowe zapytanie - dostosuj do swojego schematu
    const result = await pool.query('SELECT * FROM aquariums ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching aquariums:', error);
    // Fallback na mock data
    res.json(mockAquariums);
  }
});

app.post('/api/aquariums', async (req, res) => {
  try {
    const { name, capacity, waterType } = req.body;
    const pool = getDbPool();
    
    const result = await pool.query(
      'INSERT INTO aquariums (name, capacity, water_type) VALUES ($1, $2, $3) RETURNING *',
      [name, capacity, waterType]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating aquarium:', error);
    res.status(500).json({ error: 'Failed to create aquarium' });
  }
});

app.get('/api/aquariums/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const pool = getDbPool();
    
    const result = await pool.query('SELECT * FROM aquariums WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Aquarium not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching aquarium:', error);
    res.status(500).json({ error: 'Failed to fetch aquarium' });
  }
});

// FISH ENDPOINTS
app.get('/api/fish', async (req, res) => {
  try {
    const pool = getDbPool();
    const result = await pool.query('SELECT * FROM fish ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching fish:', error);
    res.json([]);
  }
});

app.post('/api/fish', async (req, res) => {
  try {
    const { name, species, aquariumId } = req.body;
    const pool = getDbPool();
    
    const result = await pool.query(
      'INSERT INTO fish (name, species, aquarium_id) VALUES ($1, $2, $3) RETURNING *',
      [name, species, aquariumId]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating fish:', error);
    res.status(500).json({ error: 'Failed to create fish' });
  }
});

// TASKS ENDPOINTS
app.get('/api/tasks', async (req, res) => {
  try {
    const pool = getDbPool();
    const result = await pool.query('SELECT * FROM tasks ORDER BY due_date ASC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching tasks:', error);
    res.json([]);
  }
});

app.post('/api/tasks', async (req, res) => {
  try {
    const { title, taskType, dueDate, description } = req.body;
    const pool = getDbPool();
    
    const result = await pool.query(
      'INSERT INTO tasks (title, task_type, due_date, description) VALUES ($1, $2, $3, $4) RETURNING *',
      [title, taskType, dueDate, description]
    );
    
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating task:', error);
    res.status(500).json({ error: 'Failed to create task' });
  }
});

app.patch('/api/tasks/:id/complete', async (req, res) => {
  try {
    const { id } = req.params;
    const pool = getDbPool();
    
    const result = await pool.query(
      'UPDATE tasks SET completed = true, completed_at = NOW() WHERE id = $1 RETURNING *',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error completing task:', error);
    res.status(500).json({ error: 'Failed to complete task' });
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