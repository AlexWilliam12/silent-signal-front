class MessageContext {
  late String user = "";
  late List<dynamic> chats = [];
  late Map<String, dynamic> lastMessages = {};

  void filterLastMessages() {
    for (Map<String, dynamic> element in chats) {
      if (element['sender'] != user) {
        if (!lastMessages.containsKey(element['sender']) ||
            DateTime.parse(element['createdAt']).isAfter(
              DateTime.parse(lastMessages[element['sender']]['createdAt']),
            )) {
          lastMessages[element['sender']] = element;
        }
      }
    }
  }
}
