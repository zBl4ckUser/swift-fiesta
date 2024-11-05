const router = require('express').Router()

const userRoutes = require('./userRoutes')
const listingRoutes = require('./listingRoutes')
const fileRoutes = require('./fileRoutes')
const postRoutes = require('./postRoutes')
const commentRoutes = require('./commentRoutes')
const institutionRoutes = require('./institutionRoutes')
const likeRoutes = require('./likeRoutes')
const searchRoutes = require('./searchRoutes')

router.use('/u', userRoutes)
router.use('/l', listingRoutes)
router.use('/f', fileRoutes)
router.use('/p', postRoutes)
router.use('/c', commentRoutes)
router.use('/i', institutionRoutes)
router.use('/like', likeRoutes)
router.use('/search', searchRoutes)

module.exports = router