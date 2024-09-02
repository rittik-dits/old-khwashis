
class EventPrice {
  String id;
  String name;
  num interCityPrice;
  num interStatePrice;
  num outerStatePrice;
  String priceUnit;
  bool withSecurity;
  EventPrice({
    required this.id,
    required this.name,
    required this.interCityPrice,
    required this.interStatePrice,
    required this.outerStatePrice,
    required this.priceUnit,
    required this.withSecurity,
  });
}

