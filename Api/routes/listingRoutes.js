const router = require('express').Router()
const listingController = require('../controllers/listingController')


router.get('/recent', listingController.getListings)
router.get('/', listingController.getListing)
router.get('/byspecie', listingController.getListingsBySpecie)
router.post('/', listingController.createListing)

module.exports = router