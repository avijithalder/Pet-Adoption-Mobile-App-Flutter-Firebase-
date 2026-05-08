import 'package:flutter/material.dart';
import 'package:test/main.dart';
import 'package:test/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Controllers (used to get input from TextFields)
final emailController = TextEditingController();
final passwordController = TextEditingController();

// Form key (used for form validation)
final _formKey = GlobalKey<FormState>();

// Custom SnackBar function (to show messages)
void MySnackBar(message, context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, textAlign: TextAlign.center),
      backgroundColor: Colors.deepPurple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// Password visibility toggle variable
bool obscurePassword = true;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GestureDetector(
          // Hide keyboard when tapping outside input fields
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                children: [
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Log in to continue",
                    style: TextStyle(color: Colors.black54, fontSize: 18),
                  ),
                  const SizedBox(height: 50),

                  // Email Field
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      labelText: "Email Address",
                    ),

                    // Email validation logic
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return "Enter a valid email";
                      } else {
                        return null;
                      }
                    },
                  ),

                  SizedBox(height: 10),

                  //password filed
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    // obscureText: true, //  Password hide
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: "Password",

                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          obscurePassword = !obscurePassword;
                          setState(() {});
                        },
                      ),
                    ),

                    // Password validation logic
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password required";
                      }
                      if (value.length < 6) {
                        return "password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Login button
                  ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      String email = emailController.text.trim();
                      String password = passwordController.text;

                      // Call Firestore login function
                      var userData = await loginUser(email, password, context);

                      if (userData != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeActivity(
                              userId: userData["userId"], // Firestore doc ID
                              userName: userData["name"] ?? "",
                              userEmail: userData["email"] ?? "",
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  //Register button
                  // Clear all input fields before navigating
                  ElevatedButton(
                    onPressed: () {
                      nameController.clear();
                      emailController.clear();
                      phoneController.clear();
                      addressController.clear();
                      passwordController.clear();
                      confirmPasswordController.clear();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Color.fromRGBO(255, 138, 101, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//  Firestore login function
Future<Map<String, dynamic>?> loginUser(
  String email,
  String password,
  BuildContext context,
) async {
  if (email.isEmpty || password.isEmpty) {
    MySnackBar("Please enter email and password", context);
    return null;
  }

  try {
    var query = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .where("password", isEqualTo: password)
        .get();

    if (query.docs.isNotEmpty) {
      return {
        "userId": query.docs.first.id, //  Firestore doc ID
        "name": query.docs.first['name'],
        "email": query.docs.first['email'],
      };
    } else {
      MySnackBar("Incorrect email or password", context);
      return null;
    }
  } catch (e) {
    MySnackBar("Error: $e", context);
    return null;
  }
}
