class CalculateFeePayload{
  final String? provinceSource;
  final String? districtSource;
  final String? detailSource;
  final String? provinceDestination;
  final String? districtDestination;
  final String? detailDestination;
  final String? deliveryMethod;
  final num? height;
  final num? width;
  final num? length;
  final num? mass;
  
  CalculateFeePayload(this.provinceSource, this.districtSource, this.detailSource, this.provinceDestination, this.districtDestination, this.detailDestination, this.deliveryMethod, this.height, this.length, this.mass, this.width);

  Map<String, dynamic> toJson() {
    return {
      'provinceSource': provinceSource,
      'districtSource': districtSource,
      'detailSource': detailSource,
      'provinceDestination': provinceDestination,
      'districtDestination': districtDestination,
      'detailDestination': detailDestination,
      'deliveryMethod': deliveryMethod,
      'height': height,
      'width': width,
      'length': length,
      'mass': mass,
    };
  }
}
