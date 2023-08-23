class MessageGenerator {
  static List<String> requesteeMessages = [
    "Good day Dispatch! Please see the above ticket.",
    "Hi Dispatch! Can you look at the above ticket?",
    "Hello. Please look at my ticket.",
  ];

  static List<String> dispatcherMessages = [
    "Good day. Please review the ticket I generated!"
  ];

  static String generate({
    required int number,
    required bool isDispatch,
  }) {
    var messages = (isDispatch) ? dispatcherMessages : requesteeMessages;
    int position = number % messages.length;
    return messages[position];
  }
}
