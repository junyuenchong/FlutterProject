import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart'; // Part directive to include the generated code for JSON serialization

// The @JsonSerializable annotation indicates that the class can be converted to and from JSON.
@JsonSerializable()
class User {
  // @JsonKey allows customization of the keys when serializing/deserializing.
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "number")
  int? number;

  @JsonKey(name: "password")
  String? password;

  @JsonKey(name: "email")
  String? email;

  // Constructor to initialize the Product object
  User({
    this.id,
    this.name,
    this.number,
    this.password,
    this.email,
  });

  // Factory method to create a Product object from a JSON map
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Method to convert the Product object to a JSON map
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
