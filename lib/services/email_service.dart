import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  static Future<bool> sendOtp(String recipientEmail, int otp) async {
    try {
      // Replace these with your email credentials and SMTP server
      String username = dotenv.env['EMAIL_USERNAME'] ?? '';
      String password = dotenv.env['EMAIL_PASSWORD'] ?? '';
      
      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'Your App Name')
        ..recipients.add(recipientEmail)
        ..subject = 'Your OTP Code'
        ..text = 'Your OTP code is: $otp';

      final sendReport = await send(message, smtpServer);

      print('OTP sent: $sendReport');
      return true;
    } catch (e) {
      print('Email sending failed: $e');
      return false;
    }
  }
}
