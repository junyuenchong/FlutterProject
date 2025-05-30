import 'package:json_annotation/json_annotation.dart';
part 'product_category.g.dart'; // Part directive to include the generated code for JSON serialization

// The @JsonSerializable annotation indicates that the class can be converted to and from JSON.
@JsonSerializable()
class ProductCategory {
  // @JsonKey allows customization of the keys when serializing/deserializing.
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "name")
  String? name;


  // Constructor to initialize the Product object
  ProductCategory({
    this.id,
    this.name,
  });

  // Factory method to create a Product object from a JSON map
  factory ProductCategory.fromJson(Map<String, dynamic> json) => _$ProductCategoryFromJson(json);

  // Method to convert the Product object to a JSON map
  Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);
}