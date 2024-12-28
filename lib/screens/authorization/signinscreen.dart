// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SignInScreen(),
//     );
//   }
// }
//
// class SignInScreen extends StatefulWidget {
//   @override
//   _SignInScreenState createState() => _SignInScreenState();
// }
//
// class _SignInScreenState extends State<SignInScreen> {
//   GoogleSignIn _googleSignIn = GoogleSignIn();
//   String _userName = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _checkSignInStatus();
//   }
//
//   Future<void> _checkSignInStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isSignedIn = prefs.getBool('isSignedIn') ?? false;
//     bool isGuest = prefs.getBool('isGuest') ?? false;
//
//     if (isSignedIn || isGuest) {
//       _userName = prefs.getString('userName') ?? '';
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (context) => HomeScreen(userName: _userName)),
//       );
//     }
//   }
//
//   Future<void> _signIn() async {
//     final GoogleSignInAccount? account = await _googleSignIn.signIn();
//     if (account != null) {
//       final GoogleSignInAuthentication authentication =
//           await account.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: authentication.accessToken,
//         idToken: authentication.idToken,
//       );
//       await FirebaseAuth.instance.signInWithCredential(credential);
//
//       _userName = account.displayName!;
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isSignedIn', true);
//       await prefs.setString('userName', _userName);
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (context) => HomeScreen(userName: _userName)),
//       );
//     }
//   }
//
//   Future<void> _guestSignIn() async {
//     TextEditingController _nameController = TextEditingController();
//     bool nameEntered = false;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Enter your name'),
//         content: TextField(
//           controller: _nameController,
//           decoration: InputDecoration(hintText: 'Name'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _userName = _nameController.text;
//                 nameEntered = true;
//               });
//               Navigator.of(context).pop();
//             },
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//
//     if (nameEntered && _userName.isNotEmpty) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isGuest', true);
//       await prefs.setString('userName', _userName);
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (context) => HomeScreen(userName: _userName)),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sign In'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: _signIn,
//               child: Text('Sign In with Google'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _guestSignIn,
//               child: Text('Continue as Guest'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   final String userName;
//
//   HomeScreen({required this.userName});
//
//   Future<void> _signOut(BuildContext context) async {
//     await GoogleSignIn().signOut();
//     await FirebaseAuth.instance.signOut();
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isSignedIn', false);
//     await prefs.setBool('isGuest', false);
//     await prefs.remove('userName');
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => SignInScreen()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(userName),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () => _signOut(context),
//           ),
//         ],
//       ),
//       body: Center(
//         child: Text('Welcome, $userName!'),
//       ),
//     );
//   }
// }
