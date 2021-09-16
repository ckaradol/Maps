part of 'data_bloc.dart';

@immutable
abstract class DataState {}

class DataInitial extends DataState {}
class DataSetState extends DataState{
 final List<Marker> data;

  DataSetState(this.data);
}
