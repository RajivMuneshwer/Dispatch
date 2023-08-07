import 'package:bloc/bloc.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:meta/meta.dart';

part 'user_view_state.dart';

class UserViewCubit extends Cubit<UserViewState> {
  UserViewCubit() : super(UserViewInitial());

  Future<void> initialize({
    required Future<List<User>> Function() loadData,
  }) async {
    Future.delayed(duration, () async {
      List<User> users = await loadData();
      emit(UserViewWithData(
        users: users,
      ));
    });
  }
}

const duration = Duration(
  microseconds: 500,
);
