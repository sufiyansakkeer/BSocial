class UserModel {
  final String email;
  final String uid;
  final String photoUrl;
  final String userName;
  final List followers;
  final List following;

  UserModel({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.userName,
    required this.followers,
    required this.following,
  });
//here we used string as the first dataType because the key is string type,
//* when we call this function , it will convert the arguments into the object file
  Map<String, dynamic> toJson() => {
        'username': userName,
        "uid": uid,
        "email": email,
        "followers": followers,
        "following": following,
        "photoUrl": photoUrl,
      };
}
