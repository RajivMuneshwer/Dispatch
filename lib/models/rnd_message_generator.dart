import 'dart:math';

class RndMessageGenerator {
  static List<String> randomMessages = [
    "Good day Dispatch! Please see the above ticket.",
    "Hi Dispatch! Can you look at the above ticket?",
    "Hello. Please look at my ticket.",
  ];

  static generate() {
    Random rnd = Random();
    int rndint = rnd.nextInt(randomMessages.length);
    return randomMessages[rndint];
  }
}
