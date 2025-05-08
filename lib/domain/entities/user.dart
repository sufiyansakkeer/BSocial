// User entity class
class User {
  const User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.userName,
    required this.followers,
    required this.following,
    this.status = 'offline',
  });
  final String email;
  final String uid;
  final String photoUrl;
  final String userName;
  final List<String> followers;
  final List<String> following;
  final String status;
}
