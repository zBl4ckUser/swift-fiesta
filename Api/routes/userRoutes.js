const router = require('express').Router()
const userController = require('../controllers/userController')

router.get('/', userController.getUser)
router.post('/', userController.signUp)
router.post('/signin', userController.signIn)
router.post('/signout', userController.signOut)
router.patch('/', userController.updateUser)
// router.post('/resetpwd', userController.resetPassword)

module.exports = router