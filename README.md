# AlchemyCMS Demo

This is the source code of the AlchemyCMS demo.

## Visit the demo online

The demo is located at https://alchemy-demo.herokuapp.com

Login to the admin backend at https://alchemy-demo.herokuapp.com/admin

* Username: `demo`
* Password: `demo123`

## Deploy your own demo

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Run the demo locally

1. Clone this repository to your machine
2. Run `bin/setup`
3. Create a [cloudinary](https://cloudinary.com/users/register/free) free account in order to use it for handling and storing images and files in general
4. Create a credentials file  
   Run  
   `EDITOR="subl --wait" rails credentials:edit`  
   or  
   `EDITOR=vim rails credentials:edit`  
   and add the following lines with the cloudinary account details:
```
cloudinary:
     cloud_name: <cloud name>
     api_key: <api key value>
     api_secret: <api secret value>
```
   ### Note:
   If there is no cloudinary section in the credentials file you will see:  

   a. A message (info) in the logs when starting server (rais s):
   > **Warning**: There is no 'cloudinary' section in the credentials file. 'See Readme.MD' for details.

   b. A message when the dialog window for images (Insert image) opens in edit page:
   > Must supply cloud_name in tag or in configuration

   c. A message (info) in the logs when editing, show, etc a page which contains an image:
   > URI::InvalidURIError bad URI(is not URI?): https://api.cloudinary.com/v1_1/name/...

4. Visit http://localhost:3000
5. Follow on-screen instructions
