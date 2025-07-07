const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || '*',
  credentials: true
}));

// General middleware
app.use(compression());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

// API Info endpoint
app.get('/api', (req, res) => {
  res.json({
    name: 'AquaManager API',
    version: '1.0.0',
    description: 'A comprehensive aquarium management system API',
    endpoints: {
      health: '/health',
      api: '/api',
      aquariums: {
        list: 'GET /api/aquariums',
        get: 'GET /api/aquariums/:id',
        create: 'POST /api/aquariums',
        update: 'PUT /api/aquariums/:id',
        delete: 'DELETE /api/aquariums/:id',
        fish: 'GET /api/aquariums/:id/fish'
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
});

// Default route
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to AquaManager API',
    version: '1.0.0',
    health: '/health',
    docs: '/api'
  });
});

// Mock data for testing (replace with database later)
let aquariums = [
  {
    id: 1,
    name: "Main Tank",
    capacity: 100,
    waterType: "freshwater",
    temperature: 24.5,
    ph: 7.2,
    fishCount: 15,
    status: "healthy",
    createdAt: new Date().toISOString()
  },
  {
    id: 2,
    name: "Coral Reef",
    capacity: 200,
    waterType: "saltwater",
    temperature: 26.0,
    ph: 8.1,
    fishCount: 8,
    status: "healthy",
    createdAt: new Date().toISOString()
  }
];

let fish = [
  {
    id: 1,
    name: "Nemo",
    species: "Clownfish",
    aquariumId: 1,
    age: 2,
    health: "good",
    createdAt: new Date().toISOString()
  },
  {
    id: 2,
    name: "Dory",
    species: "Blue Tang",
    aquariumId: 2,
    age: 3,
    health: "excellent",
    createdAt: new Date().toISOString()
  }
];

// Mock tasks data
let tasks = [
  {
    id: 1,
    title: "Wymiana wody",
    taskType: "maintenance",
    dueDate: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    isCompleted: false,
    aquariumId: 1,
    createdAt: new Date().toISOString()
  },
  {
    id: 2,
    title: "Karmienie ryb",
    taskType: "feeding",
    dueDate: new Date(Date.now() + 12 * 60 * 60 * 1000).toISOString(),
    isCompleted: false,
    aquariumId: 2,
    createdAt: new Date().toISOString()
  }
];

// Aquarium Routes
app.get('/api/aquariums', (req, res) => {
  res.json({
    success: true,
    data: aquariums,
    count: aquariums.length
  });
});

app.get('/api/aquariums/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const aquarium = aquariums.find(a => a.id === id);
  
  if (!aquarium) {
    return res.status(404).json({
      success: false,
      error: 'Aquarium not found'
    });
  }
  
  // Add fish data for this aquarium
  const aquariumFish = fish.filter(f => f.aquariumId === id);
  
  res.json({
    success: true,
    data: {
      ...aquarium,
      fish: aquariumFish
    }
  });
});

app.post('/api/aquariums', (req, res) => {
  const { name, capacity, waterType, temperature, ph } = req.body;
  
  // Basic validation
  if (!name || !capacity || !waterType) {
    return res.status(400).json({
      success: false,
      error: 'Name, capacity, and waterType are required'
    });
  }
  
  const newAquarium = {
    id: aquariums.length + 1,
    name,
    capacity: parseFloat(capacity),
    waterType,
    temperature: temperature ? parseFloat(temperature) : null,
    ph: ph ? parseFloat(ph) : null,
    fishCount: 0,
    status: 'healthy',
    createdAt: new Date().toISOString()
  };
  
  aquariums.push(newAquarium);
  
  res.status(201).json({
    success: true,
    data: newAquarium,
    message: 'Aquarium created successfully'
  });
});

app.put('/api/aquariums/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const aquariumIndex = aquariums.findIndex(a => a.id === id);
  
  if (aquariumIndex === -1) {
    return res.status(404).json({
      success: false,
      error: 'Aquarium not found'
    });
  }
  
  const { name, capacity, waterType, temperature, ph, status } = req.body;
  
  // Update aquarium
  aquariums[aquariumIndex] = {
    ...aquariums[aquariumIndex],
    ...(name && { name }),
    ...(capacity && { capacity: parseFloat(capacity) }),
    ...(waterType && { waterType }),
    ...(temperature && { temperature: parseFloat(temperature) }),
    ...(ph && { ph: parseFloat(ph) }),
    ...(status && { status }),
    updatedAt: new Date().toISOString()
  };
  
  res.json({
    success: true,
    data: aquariums[aquariumIndex],
    message: 'Aquarium updated successfully'
  });
});

app.delete('/api/aquariums/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const aquariumIndex = aquariums.findIndex(a => a.id === id);
  
  if (aquariumIndex === -1) {
    return res.status(404).json({
      success: false,
      error: 'Aquarium not found'
    });
  }
  
  const deletedAquarium = aquariums.splice(aquariumIndex, 1)[0];
  
  // Also remove fish from this aquarium
  fish = fish.filter(f => f.aquariumId !== id);
  
  res.json({
    success: true,
    data: deletedAquarium,
    message: 'Aquarium deleted successfully'
  });
});

// Fish Routes
app.get('/api/fish', (req, res) => {
  res.json({
    success: true,
    data: fish,
    count: fish.length
  });
});

app.get('/api/aquariums/:aquariumId/fish', (req, res) => {
  const aquariumId = parseInt(req.params.aquariumId);
  const aquariumFish = fish.filter(f => f.aquariumId === aquariumId);
  
  res.json({
    success: true,
    data: aquariumFish,
    count: aquariumFish.length
  });
});

app.post('/api/fish', (req, res) => {
  const { name, species, aquariumId, age, health } = req.body;
  
  // Basic validation
  if (!name || !species || !aquariumId) {
    return res.status(400).json({
      success: false,
      error: 'Name, species, and aquariumId are required'
    });
  }
  
  // Check if aquarium exists
  const aquarium = aquariums.find(a => a.id === parseInt(aquariumId));
  if (!aquarium) {
    return res.status(400).json({
      success: false,
      error: 'Invalid aquarium ID'
    });
  }
  
  const newFish = {
    id: fish.length + 1,
    name,
    species,
    aquariumId: parseInt(aquariumId),
    age: age ? parseInt(age) : null,
    health: health || 'good',
    createdAt: new Date().toISOString()
  };
  
  fish.push(newFish);
  
  // Update fish count in aquarium
  aquarium.fishCount = fish.filter(f => f.aquariumId === aquarium.id).length;
  
  res.status(201).json({
    success: true,
    data: newFish,
    message: 'Fish added successfully'
  });
});

// Task Routes
app.get('/api/tasks', (req, res) => {
  res.json({
    success: true,
    data: tasks,
    count: tasks.length
  });
});

app.get('/api/aquariums/:aquariumId/tasks', (req, res) => {
  const aquariumId = parseInt(req.params.aquariumId);
  const aquariumTasks = tasks.filter(t => t.aquariumId === aquariumId);
  
  res.json({
    success: true,
    data: aquariumTasks,
    count: aquariumTasks.length
  });
});

app.post('/api/tasks', (req, res) => {
  const { title, taskType, dueDate, aquariumId } = req.body;
  
  // Basic validation
  if (!title || !taskType || !dueDate || !aquariumId) {
    return res.status(400).json({
      success: false,
      error: 'Title, taskType, dueDate, and aquariumId are required'
    });
  }
  
  // Check if aquarium exists
  const aquarium = aquariums.find(a => a.id === parseInt(aquariumId));
  if (!aquarium) {
    return res.status(400).json({
      success: false,
      error: 'Invalid aquarium ID'
    });
  }
  
  const newTask = {
    id: tasks.length + 1,
    title,
    taskType,
    dueDate,
    isCompleted: false,
    aquariumId: parseInt(aquariumId),
    createdAt: new Date().toISOString()
  };
  
  tasks.push(newTask);
  
  res.status(201).json({
    success: true,
    data: newTask,
    message: 'Task created successfully'
  });
});

app.patch('/api/tasks/:id/complete', (req, res) => {
  const id = parseInt(req.params.id);
  const taskIndex = tasks.findIndex(t => t.id === id);
  
  if (taskIndex === -1) {
    return res.status(404).json({
      success: false,
      error: 'Task not found'
    });
  }
  
  tasks[taskIndex].isCompleted = true;
  tasks[taskIndex].completedAt = new Date().toISOString();
  
  res.json({
    success: true,
    data: tasks[taskIndex],
    message: 'Task marked as completed'
  });
});

app.delete('/api/tasks/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const taskIndex = tasks.findIndex(t => t.id === id);
  
  if (taskIndex === -1) {
    return res.status(404).json({
      success: false,
      error: 'Task not found'
    });
  }
  
  const deletedTask = tasks.splice(taskIndex, 1)[0];
  
  res.json({
    success: true,
    data: deletedTask,
    message: 'Task deleted successfully'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'production' ? 'Internal Server Error' : err.message
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `The requested route ${req.originalUrl} does not exist`
  });
});

// Start server
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`🚀 AquaManager API server running on port ${PORT}`);
    console.log(`📡 Health check: http://localhost:${PORT}/health`);
    console.log(`📋 API info: http://localhost:${PORT}/api`);
  });
}

module.exports = app;
