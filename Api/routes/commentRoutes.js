const router = require('express').Router()
const commentController = require('../controllers/commentController')

router.get('/all', commentController.getComments)
router.get('/', commentController.getComment)
router.get('/bypost', commentController.getCommentByPost)
router.get('/byuser', commentController.getCommentsByUser)
router.post('/', commentController.comment)
router.delete('/', commentController.deleteComment)

module.exports = router