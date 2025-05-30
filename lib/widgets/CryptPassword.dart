import 'package:bcrypt/bcrypt.dart';


class PasswordUtils {
  /// Hash the password using bcrypt
  static String hashPassword(String password) {
    // Generate a salt and hash the password with it
    final String hashed = BCrypt.hashpw(password, BCrypt.gensalt());
    return hashed;
  }

  /// Verify plain password against a bcrypt hashed password
  static bool verifyPassword(String inputPassword, String storedHash) {
    return BCrypt.checkpw(inputPassword, storedHash);
  }
}
