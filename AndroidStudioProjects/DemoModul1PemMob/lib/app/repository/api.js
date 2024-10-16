const express = require('express');
const app = express();
const port = 3000;

// Middleware to parse JSON bodies
app.use(express.json()); // Make sure to include this line to parse JSON request bodies

// Data kontak
const contacts = [
  { id: 1, name: 'Alice', phoneNumber: '08123456789' },
  { id: 2, name: 'Bob', phoneNumber: '08123456780' },
  { id: 3, name: 'Charlie', phoneNumber: '08123456781' },
  { id: 4, name: 'David', phoneNumber: '08123456782' },
  { id: 5, name: 'Eve', phoneNumber: '08123456783' },
];

// Data pesan dengan beberapa pesan awal
const messages = [
  { id: 1, sender: 'Alice', receiver: 'Bob', message: 'Hi Bob!', timestamp: '2023-10-01T10:00:00Z' },
  { id: 2, sender: 'Bob', receiver: 'Alice', message: 'Hello Alice!', timestamp: '2023-10-01T10:01:00Z' },
  { id: 3, sender: 'Charlie', receiver: 'David', message: 'Hey David, how are you?', timestamp: '2023-10-01T10:02:00Z' },
  { id: 4, sender: 'David', receiver: 'Charlie', message: 'I am good, thanks!', timestamp: '2023-10-01T10:03:00Z' },
  { id: 5, sender: 'Eve', receiver: 'Alice', message: 'Are we still on for lunch?', timestamp: '2023-10-01T10:04:00Z' },
];

// API untuk mendapatkan daftar kontak
app.get('/contacts', (req, res) => {
  res.json(contacts);
});

// API untuk mendapatkan daftar pesan
app.get('/messages', (req, res) => {
  res.json(messages);
});

// API untuk mengirim pesan
app.post('/messages', (req, res) => {
  const { sender, receiver, message } = req.body;
  const newMessage = { id: messages.length + 1, sender, receiver, message, timestamp: new Date().toISOString() };
  messages.push(newMessage);
  res.json(newMessage);
});

// API untuk mendapatkan pesan berdasarkan id kontak
app.get('/messages/:id', (req, res) => {
  const id = req.params.id;
  const contact = contacts.find((contact) => contact.id === parseInt(id));
  if (!contact) {
    res.status(404).json({ error: 'Kontak tidak ditemukan' });
  } else {
    const messagesForContact = messages.filter((message) => message.sender === contact.name || message.receiver === contact.name);
    res.json(messagesForContact);
  }
});

app.listen(port, () => {
  console.log(`API messenger app listening on port ${port}`);
});