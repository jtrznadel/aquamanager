const express = require('express');
const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require('../config/swagger');

// Import route modules
// const aquariumRoutes = require('./aquariums');
// const fishRoutes = require('./fish');
// const taskRoutes = require('./tasks');

const router = express.Router();

// API Documentation
router.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'AquaManager API Docs'
}));

// API Routes will be added at the end of the file after router definitions

// API Info endpoint
router.get('/', (req, res) => {
  res.json({
    name: 'AquaManager API',
    version: '1.0.0',
    description: 'REST API for managing aquariums, fish, and maintenance tasks',
    endpoints: {
      aquariums: '/api/aquariums',
      fish: '/api/fish',
      tasks: '/api/tasks',
      search: '/api/search',
      dashboard: '/api/dashboard',
      docs: '/api/docs'
    }
  });
});

module.exports = router;

// ==================== AQUARIUM ROUTES ====================
// File: backend/src/routes/aquariums.js

const { Router } = require('express');
const { body, param } = require('express-validator');
const AquariumController = require('../controllers/aquarium_controller');
const { FishController, TaskController } = require('../controllers/fish_controller');

const aquariumRouter = Router();

// Validation middleware
const aquariumValidation = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters'),
  body('length_cm')
    .isInt({ min: 1, max: 1000 })
    .withMessage('Length must be between 1 and 1000 cm'),
  body('width_cm')
    .isInt({ min: 1, max: 1000 })
    .withMessage('Width must be between 1 and 1000 cm'),
  body('height_cm')
    .isInt({ min: 1, max: 1000 })
    .withMessage('Height must be between 1 and 1000 cm'),
  body('volume_liters')
    .isInt({ min: 1 })
    .withMessage('Volume must be greater than 0'),
];

const idValidation = [
  param('id').isInt({ min: 1 }).withMessage('ID must be a positive integer')
];

/**
 * @swagger
 * components:
 *   schemas:
 *     Aquarium:
 *       type: object
 *       required:
 *         - name
 *         - length_cm
 *         - width_cm
 *         - height_cm
 *         - volume_liters
 *       properties:
 *         id:
 *           type: integer
 *           description: Auto-generated ID
 *         name:
 *           type: string
 *           minLength: 2
 *           maxLength: 100
 *           description: Aquarium name
 *         length_cm:
 *           type: integer
 *           minimum: 1
 *           maximum: 1000
 *           description: Length in centimeters
 *         width_cm:
 *           type: integer
 *           minimum: 1
 *           maximum: 1000
 *           description: Width in centimeters
 *         height_cm:
 *           type: integer
 *           minimum: 1
 *           maximum: 1000
 *           description: Height in centimeters
 *         volume_liters:
 *           type: integer
 *           minimum: 1
 *           description: Volume in liters
 *         created_at:
 *           type: string
 *           format: date-time
 *         updated_at:
 *           type: string
 *           format: date-time
 */

/**
 * @swagger
 * /api/aquariums:
 *   get:
 *     summary: Get all aquariums
 *     tags: [Aquariums]
 *     responses:
 *       200:
 *         description: List of aquariums
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Aquarium'
 */
aquariumRouter.get('/', AquariumController.getAllAquariums);

/**
 * @swagger
 * /api/aquariums/{id}:
 *   get:
 *     summary: Get aquarium by ID
 *     tags: [Aquariums]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Aquarium ID
 *     responses:
 *       200:
 *         description: Aquarium details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Aquarium'
 *       404:
 *         description: Aquarium not found
 */
aquariumRouter.get('/:id', idValidation, AquariumController.getAquariumById);

/**
 * @swagger
 * /api/aquariums:
 *   post:
 *     summary: Create new aquarium
 *     tags: [Aquariums]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Aquarium'
 *     responses:
 *       201:
 *         description: Aquarium created successfully
 *       400:
 *         description: Validation errors
 */
aquariumRouter.post('/', aquariumValidation, AquariumController.createAquarium);

/**
 * @swagger
 * /api/aquariums/{id}:
 *   put:
 *     summary: Update aquarium
 *     tags: [Aquariums]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Aquarium'
 *     responses:
 *       200:
 *         description: Aquarium updated successfully
 *       404:
 *         description: Aquarium not found
 */
aquariumRouter.put('/:id', [...idValidation, ...aquariumValidation], AquariumController.updateAquarium);

/**
 * @swagger
 * /api/aquariums/{id}:
 *   delete:
 *     summary: Delete aquarium
 *     tags: [Aquariums]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Aquarium deleted successfully
 *       404:
 *         description: Aquarium not found
 */
aquariumRouter.delete('/:id', idValidation, AquariumController.deleteAquarium);

// Nested routes
aquariumRouter.get('/:id/fish', idValidation, FishController.getFishByAquarium);
aquariumRouter.get('/:id/tasks', idValidation, TaskController.getTasksByAquarium);
aquariumRouter.get('/:id/stats', idValidation, AquariumController.getAquariumStats);

module.exports = aquariumRouter;

// ==================== FISH ROUTES ====================
// File: backend/src/routes/fish.js

const fishRouter = Router();
// FishController is already imported at the top of the file

const fishValidation = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters'),
  body('species')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Species must be between 2 and 100 characters'),
  body('quantity')
    .isInt({ min: 1, max: 999 })
    .withMessage('Quantity must be between 1 and 999'),
  body('aquarium_id')
    .isInt({ min: 1 })
    .withMessage('Aquarium ID must be a positive integer'),
  body('notes')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Notes cannot exceed 500 characters'),
];

fishRouter.get('/', FishController.getAllFish);
fishRouter.post('/', fishValidation, FishController.createFish);
fishRouter.put('/:id', [...idValidation, ...fishValidation.slice(0, -1)], FishController.updateFish);
fishRouter.delete('/:id', idValidation, FishController.deleteFish);

module.exports = fishRouter;

// ==================== TASK ROUTES ====================
// File: backend/src/routes/tasks.js

const taskRouter = Router();
// TaskController is already imported at the top of the file

const taskValidation = [
  body('title')
    .trim()
    .isLength({ min: 3, max: 200 })
    .withMessage('Title must be between 3 and 200 characters'),
  body('task_type')
    .isIn(['water_change', 'feeding', 'cleaning', 'testing', 'maintenance'])
    .withMessage('Invalid task type'),
  body('due_date')
    .isISO8601()
    .withMessage('Due date must be a valid date'),
  body('aquarium_id')
    .isInt({ min: 1 })
    .withMessage('Aquarium ID must be a positive integer'),
];

taskRouter.get('/', TaskController.getAllTasks);
taskRouter.post('/', taskValidation, TaskController.createTask);
taskRouter.put('/:id', [...idValidation, ...taskValidation.slice(0, -1)], TaskController.updateTask);
taskRouter.patch('/:id/complete', idValidation, TaskController.completeTask);
taskRouter.patch('/:id/uncomplete', idValidation, TaskController.uncompleteTask);
taskRouter.delete('/:id', idValidation, TaskController.deleteTask);

module.exports = taskRouter;

// ==================== SEARCH ROUTES ====================
// File: backend/src/routes/search.js

const searchRouter = Router();

searchRouter.get('/fish', FishController.searchFish);

// ==================== DASHBOARD ROUTES ====================
// File: backend/src/routes/dashboard.js

const dashboardRouter = Router();

dashboardRouter.get('/stats', AquariumController.getDashboardStats);

// Now add all routes to the main router (temporarily commented for debugging)
// router.use('/aquariums', aquariumRouter);
// router.use('/fish', fishRouter);
// router.use('/tasks', taskRouter);
// router.use('/search', searchRouter);
// router.use('/dashboard', dashboardRouter);

// Export the main router
module.exports = router;