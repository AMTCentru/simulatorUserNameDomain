const express = require('express');
const app = express();
const cors = require('cors');
const path = require('path');
const crypto = require('crypto');
const PORT = 8080;

app.use(cors());
app.use(express.json());

// Disable caching globally
app.use((req, res, next) => {
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    next();
});

// Serve the admin page
app.get('/admin', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

let gusername = ""; // Replace with a proper state management mechanism

// Simulate a user login and encryption
app.get('/simulate', (req, res) => {
    const { username } = req.query;

    if (username) {
        gusername = encrypt(`AMTCENTRU\\${username}`);
    }

    res.redirect(301, 'https://aplicatii.amtcentru.duckdns.org');
});

// Return the current user
app.get('/user', (req, res) => {
    if (!gusername) {
        res.send("null");
    } else {
        res.json({ username: gusername });
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/admin`);
});

// Encryption/Decryption Functions
const key = process.env.ENCRYPTION_KEY || '1018123456789012'; // Store the key securely

function encrypt(text) {
    const iv = crypto.randomBytes(12); // 12-byte nonce for AES-GCM
    const cipher = crypto.createCipheriv('aes-128-gcm', Buffer.from(key), iv);

    let encrypted = cipher.update(text, 'utf8', 'base64');
    encrypted += cipher.final('base64');

    const authTag = cipher.getAuthTag();
    return Buffer.concat([iv, Buffer.from(encrypted, 'base64'), authTag]).toString('base64');
}

function decrypt(text) {
    const encryptedText = Buffer.from(text, 'base64');
    const iv = encryptedText.slice(0, 12); // Extract IV
    const encryptedPayload = encryptedText.slice(12);

    const decipher = crypto.createDecipheriv('aes-128-gcm', Buffer.from(key), iv);
    decipher.setAuthTag(encryptedPayload.slice(-16)); // Set auth tag
    const payload = encryptedPayload.slice(0, -16);

    let decrypted = decipher.update(payload);
    decrypted = Buffer.concat([decrypted, decipher.final()]);

    return decrypted.toString();
}
