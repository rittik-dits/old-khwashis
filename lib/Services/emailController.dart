import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:khwahish_provider/Components/util.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path_provider/path_provider.dart';

class EmailController {

  static const String adminEmail = 'support@khwahish.live';

  // MAIL_DRIVER=smtp
  // MAIL_HOST=smtp.googlemail.com
  // MAIL_PORT=465
  // mail_username=noreply.khwahish@gmail.com
  // MAIL_PASSWORD=qgdboxgmxtlemwxj
  // MAIL_ENCRYPTION=ssl

  void sendMail({
    required String recipientEmail,
    required String mailMessage,
  }) async {
    String username = 'noreply.khwahish@gmail.com';
    String password = 'qgdboxgmxtlemwxj';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = 'Mail '
      ..text = 'Message: $mailMessage';

    try {
      await send(message, smtpServer);
      // toastMessage(message: 'Email sent successfully');
    } catch (e) {
      print(e.toString());
    }
  }

  void sendMailOnAcceptanceWithDoc({
    required String recipientEmail,
    required String mailMessage,
  }) async {
    String username = 'noreply.khwahish@gmail.com';
    String password = 'qgdboxgmxtlemwxj';
    final smtpServer = gmail(username, password);

    String url = 'https://firebasestorage.googleapis.com/v0/b/talaash-399c8.appspot.com/o/util%2FArtist%20service%20agreement.pdf?alt=media&token=8d7be608-bad2-4010-a25b-bb6bb26067e3';
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    // Get the temporary directory and create a file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/attachment.pdf');

    // Write the downloaded file to the temporary file
    await file.writeAsBytes(bytes);

    // Create the email message with the attachment
    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = 'Booking Update'
      ..text = 'Message: $mailMessage'
      ..attachments.add(FileAttachment(file));

    try {
      await send(message, smtpServer);
      // toastMessage(message: 'Email sent successfully');
    } catch (e) {
      print(e.toString());
    }
  }


  void sendSubscriptionMail({
    required String recipientEmail,
    required Map<String, dynamic> price,
  }) async {
    String username = 'noreply.khwahish@gmail.com';
    String password = 'qgdboxgmxtlemwxj';
    final smtpServer = gmail(username, password);

    // Read the HTML file
    String htmlContent = await rootBundle.loadString('assets/demo.html');

    // Replace placeholders with actual values
    htmlContent = htmlContent.replaceAll('{{subscriptionAmount}}', '${price['subscriptionCharge']}');
    htmlContent = htmlContent.replaceAll('{{IGST/CGST}}', '${price['IGST/CGST']}');
    htmlContent = htmlContent.replaceAll('{{SGST}}', '${price['SGST']}');
    htmlContent = htmlContent.replaceAll('{{discount}}', '${price['discount']}');
    htmlContent = htmlContent.replaceAll('{{payableAmount}}', '${price['payableAmount']}');

    final message = Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = 'Mail'
      ..html = htmlContent;

    try {
      await send(message, smtpServer);
      // toastMessage(message: 'Email sent successfully');
    } catch (e) {
      print(e.toString());
    }
  }
}


