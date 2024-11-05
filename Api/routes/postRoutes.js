const router = require('express').Router()
const postController = require('../controllers/postController')

router.get('/recent', postController.getRecentPosts)
router.get('/recent_ul', postController.getRecentPostsWithLikedStatus)
router.get('/byinstitutionid', postController.getInstitutionsPosts)
router.get('/', postController.getPostById)
router.post('/', postController.createPost)
router.patch('/', postController.patchPost)
router.delete('/', postController.deletePost)


module.exports = router