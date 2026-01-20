import '../../auth/domain/models/user.dart';
import '../domain/profile_repository.dart';

class ProfileRepositoryMock implements ProfileRepository {
  ProfileRepositoryMock({required this.role});
  final String role;

  @override
  Future<User> getMyProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (role == 'coach') {
      return User.fromJson(const {
        'id': '11111111-1111-1111-1111-111111111111',
        'login': 'coach-maria',
        'email': 'maria@example.com',
        'full_name': 'Сидорова Мария Александровна',
        'role': 'coach',
        'created_at': '2026-01-15T10:00:00Z',
      });
    }
    return User.fromJson(const {
      'id': '22222222-2222-2222-2222-222222222222',
      'login': 'ivan-petrov',
      'email': 'ivan@example.com',
      'full_name': 'Петров Иван Сергеевич',
      'role': 'athlete',
      'created_at': '2026-02-20T10:00:00Z',
    });
  }
}
