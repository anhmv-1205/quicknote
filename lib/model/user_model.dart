import 'dart:convert';

import 'package:google_ml_kit/google_ml_kit.dart';

class User {
  List<Face> modelData;

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
