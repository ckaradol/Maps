import 'package:equatable/equatable.dart';

class DataModel extends Equatable {
  late final double? lat;
  late final double? lng;
  late final String? userId;
  late final bool? connect;

  DataModel.fromJson(Map<dynamic, dynamic> json, String userId) {
    connect=json['connect'];
    lat = json['lat'];
    lng = json['lng'];
    this.userId = userId;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [userId];
}
