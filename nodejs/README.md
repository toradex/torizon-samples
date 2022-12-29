# Node.js Sample

This sample shows how to set-up a Node.js app in a container, and use Docker Compose to deploy and update the app using the Torizon Platform Services. The guide explainig the steps to build the image and the Docker Compose file can be found on the [Node.js on Torizon](https://developer.toradex.com/torizon/application-development/nodejs-on-torizon) article.

The sample contains an Express app which listens on port 3000 and returns a page with the device temperature.

To run this sample, on Torizon Platform, update your target device with the provided Docker Compose file (`docker-compose.yml`). After the update is finished, on your browser, access the page at `<device-ip>:3000`.
