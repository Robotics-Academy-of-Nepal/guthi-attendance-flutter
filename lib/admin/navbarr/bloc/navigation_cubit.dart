import 'package:bloc/bloc.dart';

class ANavigationCubit extends Cubit<int> {
  ANavigationCubit() : super(0);

  void updateTabIndex(int index) {
    emit(index);
  }
}
