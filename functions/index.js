const functions = require("firebase-functions");

const admin = require('firebase-admin');
const { user } = require("firebase-functions/v1/auth");

const nodemailer = require('nodemailer');

admin.initializeApp();

let transporter = nodemailer.createTransport({
    service: 'gmail',
    secure: true,
    auth: {
        user: 'dishu1bansal@gmail.com',
        pass: 'obwizhigvvjfgtoq'
    }
});

class Tickets {
    
    constructor(id, name, owner, start, end, warning){
        this.name = name;
        this.owner = owner;
        this.start = start;
        this.end = end;
        this.id = id;
        this.warning = warning;
    }

    myid () {
        return this.id;
    }
    myname () {
        return this.name;
    }
    myowner () {
        return this.owner;
    }
    mystart () {
        return this.start;
    }
    myend () {
        return this.end;
    }
    mywarning () {
        return this.warning;
    }
}

exports.myfun = functions.pubsub.schedule('every 24 hours').onRun((context) => {
    var tickets = [];
    return admin.firestore().collection('tickets').get().then((snap) => {
        snap.docs.forEach((doc) => {
            data = doc.data();
            console.log("Ticket is " + String(doc.id) + "," + String(data["name"]) + "," + String(data["owner"]) + "," + String(data["issue"]) + "," + String(data["expiry"]))
            tickets.push(new Tickets(doc.id, data["name"], data["owner"], data["issue"], data["expiry"], data["warning"]))
        });
        tickets.forEach(async (ticket) => {
            console.log('Current ticket is ' + String(ticket.myowner()));
            current = Date.now();
            console.log("Value is " + String(ticket.myend() < current));
            if (ticket.myend() < current)
            {
                console.log("Sending Email to " + String(ticket.myowner()));
                sendEmail(ticket, true);
            }
            else if(ticket.myend() - current < 60 * 24 *60 *60 *1000)
            {
                if(!ticket.mywarning())
                {
                    console.log("Sending Warning to " + String(ticket.myowner()));
                    sendEmail(ticket, false);
                }
            }
        })
    });
});

function sendEmail(ticket, expired) {
    warningsub = "Your Ticket is about to expire";
    warningtext = "This is a reminder message. One of you Tickets on EWM app is about to expire in less than 60 days. Please go to the app and update it.";
    expirysub = "Your Ticket expired";
    expirytext = "This is a reminder message. One of you Tickets on EWM app has expired. Please go to the app and update it.";
    console.log("User id is " + ticket.myowner());
    return admin.auth().getUser(String(ticket.myowner())).then((user) => {
        // cors(() => {
      
            // // getting dest email by query string
            // const dest = req.query.dest;
            console.log("User email is " + user.email);
            if(expired)
            {
                const mailOptions = {
                    from: 'Dishu Bansal <dishu1bansal@gmail.com>', // Something like: Jane Doe <janedoe@gmail.com>
                    to: user.email,
                    subject: expirysub, // email subject
                    text: expirytext
                };
                return transporter.sendMail(mailOptions, (erro, info) => {
                    console.log("Error is: " + erro.message);
                    console.log("Info is: " + info.response);
                });
            }
            else
            {
                const mailOptions = {
                    from: 'Dishu Bansal <dishu1bansal@gmail.com>', // Something like: Jane Doe <janedoe@gmail.com>
                    to: user.email,
                    subject: warningsub, // email subject
                    text: warningtext
                };
                transporter.sendMail(mailOptions, (erro, info) => {
                    console.log("Error is: " + erro.message);
                    console.log("Info is: " + info.response);
                });
                return admin.firestore().collection('tickets').doc(ticket.myid()).set({'warning' : true} , { merge: true });
            }
      
            // returning result
            
        // });
    })
}

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

