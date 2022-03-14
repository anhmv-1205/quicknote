import 'dart:convert';

class User {
  List modelData;

  User({
    required this.modelData,
  });

  static User fromMap(Map<String, dynamic> user) {
    return User(
      modelData: jsonDecode(user['faces']),
    );
  }

  toMap() {
    return {
      'faces': jsonEncode(modelData),
    };
  }
}
