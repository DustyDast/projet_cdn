# Projet Integrateur Chatbot
###### par Naoufel Gharsalli, Carlos Mora Rincon, Diego Sanchez

#### Creating a chatbot integration on flutter 
- using [dialogflow ES](https://cloud.google.com/dialogflow/es/docs)
- using [dialog_flowtter](https://github.com/Deimos-Applications/dialog_flowtter)
- starting from [instaflutter](https://github.com/instaflutter/flutter-login-screen-firebase-auth-facebook-login)
- [firebase](https://firebase.google.com/docs/flutter/setup) authentification, firestore and storage for flutter

##### [firebase_options.dart](https://firebase.google.com/docs/flutter/setup) & [dialog_flow_auth.json](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) are not included


##### Allows you to SignUp (adding your image to cloud storage), and LogIn with Email-and Password
SignUp             |  LogIn
:-------------------------:|:-------------------------:
<img src="https://user-images.githubusercontent.com/99768335/194368753-f5789b63-975f-41e8-b943-a49f4d8b6c6c.gif" width=50% height=50%> |    <img src="https://user-images.githubusercontent.com/99768335/194369364-a1641947-37e9-4cae-8a44-db5c5ea0269b.gif" width=50% height=50%>
##### Searches APIs through Dialogflow's webhook to fetch information
Simple YES options             |  Simple NO options             | Technical search          
:-------------------------:|:-------------------------:|:-------------------------:
<img src="https://user-images.githubusercontent.com/99768335/194370022-0c9be220-4120-4273-9743-77fba1a9560b.gif" width=80% height=80%> | ![Chercher-non](https://user-images.githubusercontent.com/99768335/194370077-f7dac27e-3007-4f84-92c7-b274a0161d69.gif) | <img src="https://user-images.githubusercontent.com/99768335/194370134-93b8385a-ccef-4558-81c5-21afc7dae008.gif" width=80% height=80%>

##### Writes and Reads data from firebase Storage and firestore, loops back when interaction over or if the bot doesn't understand (TODO)
Sell              |  Buy             | Fallback         
:-------------------------:|:-------------------------:|:-------------------------:
![Vendre](https://user-images.githubusercontent.com/99768335/194370661-ef15f93c-0918-4826-98de-2ff3d28e98f4.gif) | <img src="https://user-images.githubusercontent.com/99768335/194370730-418b709b-4a89-41cc-a8e0-5c42450d744d.gif" width=80% height=80%> | <img src="https://user-images.githubusercontent.com/99768335/194370770-17104adc-1bec-4473-84be-344534fded97.gif" width=80% height=80%>
