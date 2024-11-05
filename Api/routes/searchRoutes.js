const router = require('express').Router()
const searchController = require('../controllers/searchController')

router.get('/s/all', searchController.getSpecies)
router.get('/s', searchController.getSpecieById)

router.get('/b/fromspecie', searchController.getBreedsFromSpecie)
router.get('/b/', searchController.getBreedById)

router.get('/', searchController.search)

module.exports = router