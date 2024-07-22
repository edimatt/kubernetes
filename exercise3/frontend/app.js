const express = require('express');
const axios = require('axios');

const app = express();
const backendUrl = process.env.BACKEND_URL || 'http://backend-srv:5000/api/data';

app.get('/', async (req, res) => {
   try {
       const response = await axios.get(backendUrl);
       res.send(`Message from backend: ${response.data.message}`);
   } catch (error) {
       res.send('Error fetching data from backend');
   }
});

const port = 3000;
app.listen(port, () => {
   console.log(`Frontend running on port ${port}`);
});
