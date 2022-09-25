import '../models/user.dart';

class UserRepository {
  static Future<User?> loginUserByUid(String uid) async {
    return null;

    // var data = await FirebaseFirestore.instance
    //      .collection('users')
    //      .where('uid', isEqualTo: uid)
    //      .get();

    // if (data.size == 0) {
    //   return null;
    // } else {
    //   return User.fromJson(data.docs.first.data());
    //   ;
    // }
  }

  static Future<bool> signup(User user) async {
    try {
      // await FirebaseFirestore.instance.collection('users').add(user.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }
}
