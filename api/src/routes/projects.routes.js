const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth.middleware');
const { getAll, getById, create, update, remove } = require('../controllers/projects.controller');

router.get('/', getAll);
router.get('/:id', getById);
router.post('/', auth, create);
router.put('/:id', auth, update);
router.delete('/:id', auth, remove);

module.exports = router;
