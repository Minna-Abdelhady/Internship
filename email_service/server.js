const express = require('express');
const nodemailer = require('nodemailer');
const bodyParser = require('body-parser');
const cors = require('cors'); // Import cors

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(cors()); // Use cors

const transporter = nodemailer.createTransport({
    service: 'Gmail',
    auth: {
        user: 'attendancemm@gmail.com',
        pass: 'odbs bmam kxsw agma'
    },
    debug: true   // enable debug output
});

app.post('/send-code', (req, res) => {
    const { email, code } = req.body;

    const mailOptions = {
        from: 'attendancemm@gmail.com',
        to: email,
        subject: 'Your Verification Code',
        text: `Your verification code is ${code}`
    };

    transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
            return res.status(500).send('Error sending email: ' + error.toString());
        }
        res.status(200).send('Verification code sent: ' + info.response);
    });
});

app.listen(port, () => {
    console.log(`Email service listening at http://localhost:${port}`);
});
