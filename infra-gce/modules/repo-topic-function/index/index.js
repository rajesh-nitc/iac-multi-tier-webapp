const { google } = require('googleapis');
var compute = google.compute('beta');

exports.helloPubSub = (pubSubEvent, context) => {
    console.log(Buffer.from(pubSubEvent.data, 'base64').toString());

    authorize(function (authClient) {
        console.log("hi")
        let request1 = {
            project: 'tf-first-project',
            zone: 'asia-south1-a',
            instanceGroupManager: 'be-mig',
            auth: authClient,
        };

        compute.instanceGroupManagers.listManagedInstances(request1, function (err, response) {
            if (err) {
                console.log(err);
                return;
            }
            var instancesArray = response.data.managedInstances
            var instancesUrlsArary = []
            for (i = 0; i < instancesArray.length; i++) {
                instancesUrlsArary.push(instancesArray[i]['instance'])
            }

            console.log("Instances Urls", instancesUrlsArary);

            let request2 = {
                project: 'tf-first-project',
                zone: 'asia-south1-a',
                instanceGroupManager: 'be-mig',
                resource: {
                    "instances": instancesUrlsArary
                },
                auth: authClient,
            };

            compute.instanceGroupManagers.recreateInstances(request2, function (err, response) {
                if (err) {
                    console.log(err);
                    return;
                }

                console.log("Response from api", response.data);

            });
        });
    })

    function authorize(callback) {
        google.auth.getClient({
            scopes: ['https://www.googleapis.com/auth/cloud-platform']
        }).then(client => {
            callback(client);
        }).catch(err => {
            console.error('authentication failed: ', err);
        });
    }

};

