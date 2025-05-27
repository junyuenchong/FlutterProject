import 'package:json_annotation/json_annotation.dart';
part 'product.g.dart'; // Part directive to include the generated code for JSON serialization

// The @JsonSerializable annotation indicates that the class can be converted to and from JSON.
@JsonSerializable()
class Product {
  // @JsonKey allows customization of the keys when serializing/deserializing.
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "description")
  String? description;

  @JsonKey(name: "category")
  String? category;

  @JsonKey(name: "image")
  String? image;

  @JsonKey(name: "price")
  double? price;

  @JsonKey(name: "brand")
  String? brand;

  @JsonKey(name: "offer")
  bool? offer;

  // Constructor to initialize the Product object
  Product({
    this.id,
    this.name,
    this.description,
    this.category,
    this.image,
    this.offer,
    this.price,
    this.brand,
  });

  // Factory method to create a Product object from a JSON map
  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  // Method to convert the Product object to a JSON map
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}