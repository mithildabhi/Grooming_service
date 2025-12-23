import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _role = 'user';

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    _role = email.contains('admin') ? 'admin' : 'user';
  }

  Future<void> register(String email, String password, String role) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _role = role;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String getRole() => _role;

  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return await user.getIdToken(true);
  }
}
