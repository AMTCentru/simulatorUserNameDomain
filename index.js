const express = require('express');
const app = express();
const cors = require('cors');
const PORT = 8080;
const crypto = require('crypto');

app.use(cors());
app.use(express.json());

// Disable caching
app.use((req, res, next) => {
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    next();
});

let gusername = "";

app.get('/simulate', (req, res) => {
    const { username } = req.query;
    console.log(username);
    if (username) {
        gusername = encrypt('AMTCENTRU\\' + username);
    }

    res.redirect(301, '/user');
});

app.get('/user', (req, res) => {
    if (!gusername) {
        res.send("null");
    } else {
        res.json({ username: gusername });
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`Serverul rulează \n
        rute disponibile: \n
        http://localhost:${PORT}/simulate?username=username`);
});

const key = '1018123456789012'; // Cheia de 16 bytes pentru AES-128

function decrypt(text) {
    const encryptedText = Buffer.from(text, 'base64');
    const iv = encryptedText.slice(0, 12); // Primele 12 bytes sunt nonce-ul
    const encryptedPayload = encryptedText.slice(12);

    const decipher = crypto.createDecipheriv('aes-128-gcm', Buffer.from(key), iv);

    decipher.setAuthTag(encryptedPayload.slice(-16)); // Setează tag-ul de autentificare
    const payload = encryptedPayload.slice(0, -16); // Îndepărtează tag-ul din payload

    let decrypted = decipher.update(payload);
    decrypted = Buffer.concat([decrypted, decipher.final()]);

    return decrypted.toString();
}

function encrypt(text) {
    const iv = crypto.randomBytes(12); // Generare nonce (IV) de 12 bytes
    const cipher = crypto.createCipheriv('aes-128-gcm', Buffer.from(key), iv);

    let encrypted = cipher.update(text, 'utf8', 'base64');
    encrypted += cipher.final('base64');

    const authTag = cipher.getAuthTag(); // Obține tag-ul de autentificare

    // Combină IV, text criptat și tag-ul de autentificare
    const result = Buffer.concat([iv, Buffer.from(encrypted, 'base64'), authTag]).toString('base64');

    return result;
}
