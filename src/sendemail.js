const nodemailer = require('nodemailer');

const SMTP_USERNAME = process.env.SMTP_USERNAME;
const SMTP_PASSWORD = process.env.SMTP_PASSWORD;
const RECEIVER_EMAIL = process.env.RECEIVER_EMAIL;

sendEmail = async (euroToInr) => {
    let transporter = nodemailer.createTransport({
        host: "smtp.gmail.com",
        port: 587,
        secure: false,
        auth: {
            user: SMTP_USERNAME,
            pass: SMTP_PASSWORD
        }
    });

    let info = await transporter.sendMail({
        from: SMTP_USERNAME,
        to: RECEIVER_EMAIL,
        subject: 'Euro to inr greater than 85',
        text: `Euro to inr is greater than 85 and current rate is ${euroToInr}`
    });

    console.log(`Email sent: %s`, info.messageId);
}

module.exports = {
    sendEmail: sendEmail
}