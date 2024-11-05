const router = require('express').Router()
const likeController = require('../controllers/likeController')

router.get('/favorites', likeController.getFavoriteListings)
router.get('/liked', likeController.getLikedPosts)
router.get('/count', likeController.getLikesCountFromPost)
router.post('/', likeController.toggleLike)

module.exports = router
