import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  @JsonKey(name: "address")
  String? address;

  @JsonKey(name: "isDefault")
  bool? isDefault;

  Address({
    this.address,
    this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
