const axios = require('axios');

const sendemail = require('./src/sendemail');

const CONVERSION_API = 'http://data.fixer.io/api/latest';
const API_KEY = process.env.API_KEY;
const THRESHOLD_EMAIL = 85;

exports.handler = (event) => {

    let promise = axios
        .get(CONVERSION_API, {
            params: {
                'access_key': API_KEY
            }
        });

    promise
        .then(res => {
            console.log('Response status : ', res.status);
            let euroToInr = res.data.rates.INR;

            if(euroToInr > Number(THRESHOLD_EMAIL)) {
                sendemail.sendEmail(euroToInr);
            }
        })
}