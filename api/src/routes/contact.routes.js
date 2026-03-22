const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth.middleware');
const { sendMessage, getAll, markRead, remove } = require('../controllers/contact.controller');

router.post('/', sendMessage);
router.get('/', auth, getAll);
router.patch('/:id/read', auth, markRead);
router.delete('/:id', auth, remove);

module.exports = router;
