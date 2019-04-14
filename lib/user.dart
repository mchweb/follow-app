import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserType { patient, doctor }
enum SignInType { new_user_success, existing_user_success, failed }

String id;
String username;
String email;
String photoUrl;
UserType userType = UserType.patient;

GoogleSignIn _googleSignIn = GoogleSignIn();

Future<SignInType> signIn() async {
  GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  if (googleUser == null) {
    return SignInType.failed;
  }

  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  if (googleAuth == null) {
    return SignInType.failed;
  }

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // User authenticated by Firebase
  FirebaseUser firebaseUser = await FirebaseAuth
    .instance
    .signInWithCredential(credential);
  
  if (firebaseUser != null) {
    _loadUserDataFromDb(firebaseUser.uid);

    if (id == null) {
      id = firebaseUser.uid;
      username = firebaseUser.displayName;
      email = firebaseUser.email;
      photoUrl = firebaseUser.photoUrl;
      userType = UserType.patient;
      _registerUserInDb();
      _saveUserDataToLocalStorage();
      return SignInType.new_user_success;
    }

    _saveUserDataToLocalStorage();
    return SignInType.existing_user_success;
  } else {
    return SignInType.failed;
  }
}

Future signOut() async {
  await FirebaseAuth.instance.signOut();
  await _googleSignIn.disconnect();
  await _googleSignIn.signOut();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
}

Future<bool> isSignedIn() async {
  bool status = await _googleSignIn.isSignedIn();
  if (status == false) {
    return false;
  }

  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getString('id') == null) {
    return false;
  }

  _loadUserDataFromLocalStorage();

  return status;
}

void updateDataToDb() {
  Firestore.instance
    .collection('users')
    .document(id)
    .setData({
      'id': id,
      'nickname': username, 
      'email': email, 
      'photoUrl': photoUrl,
      'userType': userType.toString().split('.').last
    });

  _saveUserDataToLocalStorage();
}

void _loadUserDataFromDb(String id) async {
// List of users satisfying Firestore query
  QuerySnapshot result = await Firestore.instance
    .collection('users')
    .where('id', isEqualTo: id)
    .getDocuments();

  List<DocumentSnapshot> docs = result.documents;

  if (docs.length > 0) {
    DocumentSnapshot userDoc = docs[0];
    id = userDoc['id'];
    username = userDoc['nickname'];
    email = userDoc['email'];
    photoUrl = userDoc['photoUrl'];
    userType = UserType.values.firstWhere(
      (e) => e.toString().split('.').last == userDoc['userType'],
      orElse: () => UserType.patient
    );
  }
}

void _saveUserDataToLocalStorage() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString('id', id);
  await preferences.setString('nickname', username);
  await preferences.setString('email', email);
  await preferences.setString('photoUrl', photoUrl);
  await preferences.setString('userType', userType.toString().split('.').last);
}

void _loadUserDataFromLocalStorage() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  id = preferences.getString('id');
  username = preferences.getString('nickname');
  photoUrl = preferences.getString('photoUrl');
  email = preferences.getString('email');
  userType = UserType.values.firstWhere(
    (e) => e.toString().split('.').last == preferences.getString('userType'),
    orElse: () => UserType.patient
  );
}

void _registerUserInDb() {
  updateDataToDb();
}