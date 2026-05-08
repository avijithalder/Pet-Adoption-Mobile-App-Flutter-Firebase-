import 'package:flutter/material.dart';

class AlartPage extends StatelessWidget {
  const AlartPage({super.key});

  void MySnackBar(message, context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  MyAlertDialog(context) {
    return showDialog(
      context: context,
      builder: (BuildContext) {
        return Expanded(
          child: AlertDialog(
            title: Text("Alert"),
            content: Text("Do you want to delete"),
            actions: [
              TextButton(
                onPressed: () {
                  MySnackBar("Logout successful", context);
                },
                child: Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: () {}, child: Text("click me")),
      ),
    );
  }
}
