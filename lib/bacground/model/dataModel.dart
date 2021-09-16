class DataModel {
  double? lat;
  double? lng;



  DataModel.fromJson(Map<String, dynamic> json) {
    lat = double.parse(json['lat']);
    lng = double.parse(json['lng']);
  }
}