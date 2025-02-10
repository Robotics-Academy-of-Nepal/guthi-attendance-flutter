import 'package:bloc/bloc.dart';

class DNavigationCubit extends Cubit<int> {
  DNavigationCubit() : super(0);

  void updateTabIndex(int index) {
    emit(index);
  }
}
