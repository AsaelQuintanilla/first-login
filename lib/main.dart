// //---------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCneq3GoFkR6yNAhQgAh1--k2tblj-WpT4",
      authDomain: "flutter-firebase-6f68a.firebaseapp.com",
      projectId: "flutter-firebase-6f68a",
      storageBucket: "flutter-firebase-6f68a.appspot.com",
      messagingSenderId: "451079137617",
      appId: "1:451079137617:web:8e09264febd59b82914b70"
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Running Stats Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return RunningStatsPage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in: ${e.message}')),
        );
      }
    }
  }

  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account: ${e.message}')),
        );
      }
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({
      'login_hint': 'user@example.com'
    });

    // Try sign in with popup first (this works better for web)
    try {
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } catch (e) {
      // If popup fails, try with redirect
      await FirebaseAuth.instance.signInWithRedirect(googleProvider);

      return await FirebaseAuth.instance.getRedirectResult();
    }
  }

  void _handleGoogleSignIn() async {
    try {
      final UserCredential userCredential = await signInWithGoogle();
      print("Signed in with Google: ${userCredential.user?.displayName}");
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Enter a password 6+ chars long' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Sign In'),
                onPressed: _signInWithEmailAndPassword,
              ),
              TextButton(
                child: Text('Create Account'),
                onPressed: _createAccount,
              ),
              ElevatedButton(
                child: Text('Sign in with Google'),
                onPressed: _handleGoogleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RunningStatsPage extends StatefulWidget {
  @override
  _RunningStatsPageState createState() => _RunningStatsPageState();
}

class _RunningStatsPageState extends State<RunningStatsPage> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _timeController = TextEditingController();

  void _addRun() {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final distance = double.parse(_distanceController.text);
      final time = int.parse(_timeController.text);
      final speed = (distance / time * 60).round(); // m/min
      
      final runData = {
        'distance': distance,
        'time': time,
        'speed': speed,
        'timestamp': FieldValue.serverTimestamp(),
      };
      
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('runs')
          .add(runData);
      
      _distanceController.clear();
      _timeController.clear();
    }
  }

  void _deleteRun(String docId) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('runs')
        .doc(docId)
        .delete();
  }

  void _editRun(String docId, Map<String, dynamic> currentData) {
    showDialog(
      context: context,
      builder: (context) {
        final distanceController = TextEditingController(text: currentData['distance'].toString());
        final timeController = TextEditingController(text: currentData['time'].toString());
        
        return AlertDialog(
          title: Text('Edit Run'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: distanceController,
                  decoration: InputDecoration(labelText: 'Distance (km)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: timeController,
                  decoration: InputDecoration(labelText: 'Time (minutes)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                final userId = FirebaseAuth.instance.currentUser!.uid;
                final distance = double.parse(distanceController.text);
                final time = int.parse(timeController.text);
                final speed = (distance / time * 60).round(); // m/min
                
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('runs')
                    .doc(docId)
                    .update({
                  'distance': distance,
                  'time': time,
                  'speed': speed,
                });
                
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('Running Stats'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _distanceController,
                      decoration: InputDecoration(labelText: 'Distance (km)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter distance' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(labelText: 'Time (minutes)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter time' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    child: Text('Add Run'),
                    onPressed: _addRun,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('runs')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final runs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: runs.length,
                  itemBuilder: (context, index) {
                    final run = runs[index].data() as Map<String, dynamic>;
                    final runMessage = _getRunMessage(runs, index);
                    return ListTile(
                      title: Text('Distance: ${run['distance']} km, Time: ${run['time']} min'),
                      subtitle: Text('Speed: ${run['speed']} m/min\n$runMessage'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editRun(runs[index].id, run),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteRun(runs[index].id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getRunMessage(List<QueryDocumentSnapshot> runs, int index) {
    if (runs.length == 1) return "Great First Run!";
    
    final currentRun = runs[index].data() as Map<String, dynamic>;
    final currentSpeed = currentRun['speed'] as int;
    
    final fasterRuns = runs.where((run) {
      final runData = run.data() as Map<String, dynamic>;
      return (runData['speed'] as int) > currentSpeed;
    }).length;

    if (fasterRuns == 0) return "This was your fastest run ever!";
    if (fasterRuns == 1) return "2nd fastest run!";
    if (fasterRuns == 2) return "3rd fastest run!";
    return "${fasterRuns + 1}th fastest run";
  }
}