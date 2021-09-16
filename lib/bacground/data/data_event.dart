part of 'data_bloc.dart';

@immutable
abstract class DataEvent {}
class DataInitialEvent extends DataEvent{

}
class DataSetStateEvent extends DataEvent{
 final List<Marker>marker;

  DataSetStateEvent(this.marker);
}