const fs = require('fs');
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  const temperature = fs.readFileSync('/sys/class/thermal/thermal_zone0/temp');
  res.send('Device Temperature: ' + parseFloat(temperature)/1000 + 'C')
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
