import 'package:json_annotation/json_annotation.dart';

part 'cart.g.dart';

@JsonSerializable()
class Cart{
  @JsonKey(name: "orderid")
  String? orderid;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "image")
  String? image;

  @JsonKey(name: "price")
  double? price;

  @JsonKey(name: "quantity")
  int quantity; // Non-nullable integer for quantity

  Cart({
    this.orderid,
    this.name,
    this.image,
    this.price,
    required this.quantity, // quantity is now required
  });

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  Map<String, dynamic> toJson() => _$CartToJson(this);
}
