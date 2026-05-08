import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static Future<void> openWhatsApp(BuildContext context) async {
    final phone = "+8801883392397"; // তোমার number
    final message = "Hello, I need help from the app!";
    final whatsappUrl = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeFull(message)}",
    );

    // direct launch without canLaunchUrl
    try {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("WhatsApp could not be opened."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
