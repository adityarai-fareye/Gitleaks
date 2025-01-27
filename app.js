const express = require('express')
const app = express()
const PORT = 3333

app.get('/', (request, response) => {
    response.append("res", 200)
    response.send('Default Route')
})

app.listen(PORT, () => console.log('server running on: ',PORT))
