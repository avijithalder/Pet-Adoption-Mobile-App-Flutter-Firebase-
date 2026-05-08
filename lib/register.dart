import 'package:flutter/material.dart';
import 'package:test/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Custom SnackBar function (to show messages)
void MySnackBar(message, context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        //  style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.deepPurple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// Used to get user input from TextFields
final nameController = TextEditingController();
final emailController = TextEditingController();
final phoneController = TextEditingController();
final addressController = TextEditingController();
final passwordController = TextEditingController();
final confirmPasswordController = TextEditingController();

// Form key (used for validation)
final _formKey = GlobalKey<FormState>();

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Password visibility toggle
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? emailError; //  for duplicate email

  // register function (no duplicate check here now)
  Future registerUser(BuildContext context) async {
    await FirebaseFirestore.instance.collection("users").add({
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "password": passwordController.text.trim(),
    });
    MySnackBar("Registration Successful!", context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GestureDetector(
          // Hide keyboard when tapping outside
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Create your account",
                      style: TextStyle(color: Colors.black54, fontSize: 18),
                    ),
                    const SizedBox(height: 20),

                    // Name Field
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Username Required";
                        }
                        if (value.length < 2) {
                          return "Enter your full name";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 5),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        errorText: emailError, // show duplicate error
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email Required";
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return "Enter valid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 5),

                    // Phone Field
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Number Required";
                        }
                        if (value.length < 11 || value.length > 11) {
                          return "Enter valid phone number";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 5),

                    // Address Field
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: "Address",
                        prefixIcon: Icon(Icons.home),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Address Required";
                        }
                        if (value.length < 3) {
                          return "Enter address";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 5),

                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password Required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 5),

                    // Confirm Password Field
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Must Write Confirm Password";
                        }
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          emailError = null; // any email error reset first
                        });
                        // check full form ok or not (rules)
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        //  Check duplicate email
                        final existingUser = await FirebaseFirestore.instance
                            .collection("users")
                            .where(
                              "email",
                              isEqualTo: emailController.text.trim(),
                            )
                            .get();

                        if (existingUser.docs.isNotEmpty) {
                          setState(() {
                            emailError =
                                "This email already exists, use another one";
                          });
                          return;
                        }

                        await registerUser(context);

                        // Clear all filed
                        nameController.clear();
                        emailController.clear();
                        phoneController.clear();
                        addressController.clear();
                        passwordController.clear();
                        confirmPasswordController.clear();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Already have an account ?",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),

                    const SizedBox(height: 5),

                    ElevatedButton(
                      onPressed: () {
                        emailController.clear();
                        passwordController.clear();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color.fromRGBO(255, 138, 101, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
