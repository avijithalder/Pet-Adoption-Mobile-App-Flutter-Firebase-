import 'package:flutter/material.dart';

class PoliciesPage extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const PoliciesPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Policies"),
          elevation: 5,
          shadowColor: const Color.fromARGB(254, 254, 254, 254),
          surfaceTintColor: Colors.transparent,
        ),
        body: Column(
          children: [
            // TabBar with gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue,
                    Colors.indigo,
                    Color.fromARGB(255, 198, 240, 190),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                labelStyle: TextStyle(fontSize: 16),
                tabs: [
                  Tab(text: "Policies"),
                  Tab(text: "Terms & Conditions"),
                ],
              ),
            ),
            // TabBarView must NOT be const
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 40),
                    child: Text(
                      """🔒 Privacy Policy

Privacy Policy – Little Life Saver App

📝 Information Collection
We collect your name, email, phone number, and profile information.
🐾 Adoption, rescue, and donation-related information is also stored.

⚙️ Use of Information
Your information is used only for app functionality, communication, and service purposes.
❌ Information is not sold or shared with third parties.

🛡️ Data Security
We take reasonable measures to protect your information from unauthorized access.

📊 Cookies & Analytics
The app may use analytics to improve service quality.

👤 User Rights
Users can request deletion or modification of their data by contacting the admin.

💰 Refund Policy

Refund Policy – Little Life Saver App

💸 Donation Refunds
All donations are voluntary.
❗ The App does not guarantee refunds for donations.

🏠 Adoption / Rescue Fees
If any fee is collected (optional), refunds must be handled directly between user and shelter/NGO.
❗ The App is not responsible for financial disputes.""",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      """📜 Terms & Conditions

Terms & Conditions – Little Life Saver App

🐾 General Use
This app is intended only for pet adoption, rescue, and donation purposes.
✅ Users must provide accurate and true information.

👤 User Responsibility
Users are responsible for any pets they adopt.
❌ The App or its developers are not responsible for the health, behavior, or safety of any pet.

🏠 Pet Adoption
Adoption must be completed through direct communication between the adopter and the pet owner/NGO.
⚠️ After adoption, the App or Admin will not be liable for any issues or responsibilities.

🚑 Rescue
Users can submit rescue reports for animals in need.
❗ The App only facilitates reporting and communication; it does not assume responsibility for rescue outcomes.

💰 Donation
Donations are completely voluntary.
❌ The App cannot guarantee how donations are used.
✅ Users are responsible for the payment process.

🚫 Prohibited Activities
Providing false information or attempting fraud is strictly prohibited.
❌ Illegal activities, animal trafficking, or misuse of the App are not allowed.

🛠️ Modifications
The App developers reserve the right to modify these Terms & Conditions at any time.""",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
