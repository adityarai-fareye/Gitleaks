const express = require('express')
const app = express()
const PORT = 3334

app.get('/', (request, response) => {
    console.log(request)
    response.append("res", 200);
    response.send('Default Route');
})

app.listen(PORT, () => console.log('server running on: ',PORT))
