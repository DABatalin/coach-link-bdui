import '../../auth/domain/models/user.dart';

abstract class ProfileRepository {
  Future<User> getMyProfile();
}
