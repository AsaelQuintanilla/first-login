
//---------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: const FirebaseOptions(
//       apiKey: "AIzaSyCneq3GoFkR6yNAhQgAh1--k2tblj-WpT4",
//       authDomain: "flutter-firebase-6f68a.firebaseapp.com",
//       projectId: "flutter-firebase-6f68a",
//       storageBucket: "flutter-firebase-6f68a.appspot.com",
//       messagingSenderId: "451079137617",
//       appId: "1:451079137617:web:8e09264febd59b82914b70"
//     ),
//   );
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Firebase Todo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: AuthWrapper(),
//     );
//   }
// }

// class AuthWrapper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return TodoList();
//         } else {
//           return SignInPage();
//         }
//       },
//     );
//   }
// }
// class SignInPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Sign In')),
//       body: Center(
//         child: ElevatedButton(
//           child: Text('Sign in with Google'),
//           onPressed: () async {
//             await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
//           },
//         ),
//       ),
//     );
//   }
// }

// class TodoList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Todo List'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () => FirebaseAuth.instance.signOut(),
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('todos')
//             .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return CircularProgressIndicator();
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var todo = snapshot.data!.docs[index];
//               return ListTile(
//                 title: Text(todo['title']),
//                 trailing: IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () => todo.reference.delete(),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () => _addTodo(context),
//       ),
//     );
//   }

//   void _addTodo(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String newTodo = '';
//         return AlertDialog(
//           title: Text('Add Todo'),
//           content: TextField(
//             onChanged: (value) => newTodo = value,
//           ),
//           actions: [
//             TextButton(
//               child: Text('Add'),
//               onPressed: () {
//                 FirebaseFirestore.instance.collection('todos').add({
//                   'title': newTodo,
//                   'userId': FirebaseAuth.instance.currentUser!.uid,
//                 });
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//--------------------------------------------------
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
      title: 'Flutter Firebase Todo',
      theme: ThemeData(primarySwatch: Colors.blue),
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
        if (snapshot.hasData) {
          return TodoList();
        } else {
          return SignInPage();
        }
      },
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
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
          email: _email,
          password: _password,
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                onChanged: (value) => _email = value.trim(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Enter a password 6+ chars long' : null,
                onChanged: (value) => _password = value.trim(),
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
              Divider(),
              ElevatedButton(
                child: Text('Sign in with Google'),
                onPressed: () async {
                  await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // TodoList class remains the same as in the previous version
class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('todos')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var todo = snapshot.data!.docs[index];
              return ListTile(
                title: Text(todo['title']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => todo.reference.delete(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addTodo(context),
      ),
    );
  }

  void _addTodo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String newTodo = '';
        return AlertDialog(
          title: Text('Add Todo'),
          content: TextField(
            onChanged: (value) => newTodo = value,
          ),
          actions: [
            TextButton(
              child: Text('Add'),
              onPressed: () {
                FirebaseFirestore.instance.collection('todos').add({
                  'title': newTodo,
                  'userId': FirebaseAuth.instance.currentUser!.uid,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}