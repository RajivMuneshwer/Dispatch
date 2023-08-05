import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'dispatch_message_list_state.dart';

class DispatchUsersListCubit extends Cubit<DispatchUserListState> {
  DispatchUsersListCubit() : super(DispatchUserListInitial());

  Future<void> initialize() async {
    //connect to firebase to the dispatch and the users matched to them
    List<String> names = [
      "test",
      "Daniel",
      "Valeria",
      "Timmy",
      "Jay",
      "Rajiv",
      "Rust",
    ];
    await Future.delayed(
      duration,
      () {
        emit(DispatchUserListWithNames(names: names));
        return;
      },
    );
  }
}

const duration = Duration(microseconds: 500);
