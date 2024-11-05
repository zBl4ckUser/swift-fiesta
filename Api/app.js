const express = require('express')
const router = require('./routes/router')
const cors = require('cors')
const app = express()
const PORT = 1824

app.use(express.json())
app.use(express.urlencoded({ extended: true}))
app.use(cors({origin: '*'}))
app.use('/', router)

app.listen(PORT, () => {
    console.log(`Server running under port ${PORT} | ${new Date}`)
})
