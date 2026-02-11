const express = require('express');
const router = express.Router();
const noteController = require('../controllers/noteController');
const auth = require('../middleware/authMiddleware');

const upload = require('../middleware/uploadMiddleware');

router.get('/', auth, noteController.getNotes);
router.post('/', auth, upload.array('attachments', 5), noteController.createNote);
router.delete('/:id', auth, noteController.deleteNote);

module.exports = router;
