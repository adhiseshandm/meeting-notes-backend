const http = require('http');

const data = JSON.stringify({
  username: 'Judge',
  email: 'judge@demo.com',
  password: 'password123',
  role: 'admin'
});

const req = http.request(
  'http://localhost:5000/api/auth/signup',
  {
    method: 'POST',
    headers: { 
      'Content-Type': 'application/json', 
      'Content-Length': data.length 
    }
  },
  (res) => {
    let responseData = '';
    res.on('data', chunk => responseData += chunk);
    res.on('end', () => console.log('Status:', res.statusCode, responseData));
  }
);
req.on('error', (e) => console.log(e));
req.write(data);
req.end();
