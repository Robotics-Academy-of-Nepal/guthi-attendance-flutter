import 'package:bloc/bloc.dart';

class ItNavigationCubit extends Cubit<int> {
  ItNavigationCubit() : super(0);

  void updateTabIndex(int index) {
    emit(index);
  }
}
