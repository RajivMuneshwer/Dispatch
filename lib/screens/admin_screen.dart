import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Page"),
      ),
      body: const UserChoicesColumn(),
    );
  }
}

class UserChoiceBubble extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const UserChoiceBubble({
    super.key,
    required this.text,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = screenWidth * 2 / 3;
    double screenHeight = MediaQuery.of(context).size.height;
    double widgetHeight = screenHeight * 1 / 6;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: widgetWidth,
        height: widgetHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(100),
            right: Radius.circular(100),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class UserChoicesColumn extends StatelessWidget {
  const UserChoicesColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Center(
              child: UserChoiceBubble(
            text: "Requestees",
            onPressed: () {},
          )),
          const SizedBox(height: 40),
          Center(
              child: UserChoiceBubble(
            text: "Dispatchers",
            onPressed: () {},
          )),
          const SizedBox(height: 40),
          Center(
              child: UserChoiceBubble(
            text: "Administrators",
            onPressed: () {},
          )),
        ],
      ),
    );
  }
}
