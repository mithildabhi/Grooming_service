abstract class AuthService {
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String role);
  Future<void> logout();
  Future<void> resetPassword(String email);
  bool isLoggedIn();
  String getRole(); // admin / user
}
