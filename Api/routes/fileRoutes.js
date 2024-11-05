const router = require('express').Router()
const fileController = require('../controllers/fileController')

router.post('/', fileController.uploadImage)

module.exports = router