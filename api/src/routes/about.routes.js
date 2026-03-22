const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth.middleware');
const { getAbout, updateAbout } = require('../controllers/about.controller');

router.get('/', getAbout);
router.put('/', auth, updateAbout);

module.exports = router;
