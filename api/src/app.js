const express = require('express');
const cors = require('cors');
const { initDatabase } = require('./database/connection');
const { seedDatabase } = require('./database/seed');
const errorMiddleware = require('./middleware/error.middleware');

const authRoutes = require('./routes/auth.routes');
const projectsRoutes = require('./routes/projects.routes');
const skillsRoutes = require('./routes/skills.routes');
const experienceRoutes = require('./routes/experience.routes');
const contactRoutes = require('./routes/contact.routes');
const aboutRoutes = require('./routes/about.routes');
const servicesRoutes = require('./routes/services.routes');
const educationRoutes = require('./routes/education.routes');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Inicializa banco e seed
initDatabase();
seedDatabase();

// Rotas
app.use('/api/auth', authRoutes);
app.use('/api/projects', projectsRoutes);
app.use('/api/skills', skillsRoutes);
app.use('/api/experience', experienceRoutes);
app.use('/api/contact', contactRoutes);
app.use('/api/about', aboutRoutes);
app.use('/api/services', servicesRoutes);
app.use('/api/education', educationRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'API Portfolio rodando' });
});

// 404
app.use((req, res) => {
  res.status(404).json({ error: 'Rota não encontrada' });
});

// Error handler
app.use(errorMiddleware);

module.exports = app;
