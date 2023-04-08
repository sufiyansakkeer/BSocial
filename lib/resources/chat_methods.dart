class ChatMethods {
  String checkingId({required String user1, required String currentUser}) {
    if (user1[0].toLowerCase().codeUnits[0] >
        currentUser.toLowerCase().codeUnits[0]) {
      return "$user1$currentUser";
    } else {
      return "$currentUser$user1";
    }
  }
}
