const router = require('express').Router()
const institutionController = require('../controllers/institutionController')

router.get('/', institutionController.getInstitution)
router.get('/all', institutionController.getInstitutions)
router.post('/', institutionController.createInstitution)
router.patch('/', institutionController.patchInstitution)
router.delete('/', institutionController.deleteInstitution)

module.exports = router