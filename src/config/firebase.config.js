import firebase from "firebase";

const prodConfig = {
  apiKey: "AIzaSyCVF5TqxSClfFbmD9Uy8MShyq0VKyqphRc",
  authDomain: "nails-1aa53.firebaseapp.com",
  databaseURL: "https://nails-1aa53.firebaseio.com",
  projectId: "nails-1aa53",
  storageBucket: "nails-1aa53.appspot.com",
  messagingSenderId: "995808788393",
  appId: "1:995808788393:web:d99ea8ab49ebbd6e"
};

const devConfig = {
  apiKey: "***************",
  authDomain: "***************",
  databaseURL: "***************",
  projectId: "***************",
  storageBucket: "***************",
  messagingSenderId: "***************"
};

const config = process.env.NODE_ENV === "production" ? prodConfig : devConfig;

export const firebaseImpl = firebase.initializeApp(config);
export const firebaseDatabase = firebase.database();
export const firebaseAuth = firebase.auth();
export const googleProvider = new firebase.auth.GoogleAuthProvider();
export const facebookProvider = new firebase.auth.FacebookAuthProvider();
