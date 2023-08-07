import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/screens/user_list_screen.dart';

class DispatchRequesteeListScreen extends UserListScreen {
  const DispatchRequesteeListScreen({
    super.key,
    super.title = "Requestee Messages",
  });

  @override
  Future<List<User>> loadUserData() {
    return Future.delayed(duration, () {
      List<Requestee> requestees = [
        Requestee(id: 1, name: 'test', sortBy: 'test'),
        Requestee(id: 2, name: 'daniel', sortBy: 'daniel'),
        Requestee(id: 3, name: 'valeria', sortBy: 'valeria'),
        Requestee(id: 4, name: 'tommy', sortBy: 'tommy'),
        Requestee(id: 5, name: 'jay', sortBy: 'jay'),
        Requestee(id: 6, name: 'rajiv', sortBy: 'rajiv'),
        Requestee(id: 7, name: 'rust', sortBy: 'rust'),
      ];
      return requestees;
    });
  }

  @override
  UserRowFactory<User> rowFactory() => const GenericUserRowFactory();

  @override
  void onTap() {}
}

const duration = Duration(microseconds: 100);
