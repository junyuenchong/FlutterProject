import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart'; // Importing intl package for date formatting

part 'order.g.dart';

@JsonSerializable()
class Orders {
  @JsonKey(name: "orderid")
  String? orderid;

  @JsonKey(name: "customer")
  String? customer;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "image")
  String? image;

  @JsonKey(name: "price")
  double? price;

  @JsonKey(name: "payment status")
  String? paymentstatus;

  @JsonKey(name: "quantity")
  int quantity;

  @JsonKey(name: "address")
  String? address;

  @JsonKey(name: "dateTime", fromJson: _fromTimestamp, toJson: _toTimestamp)
  Timestamp? dateTime;

  Orders({
    this.orderid,
    this.customer,
    this.dateTime,
    this.name,
    this.image,
    this.price,
    this.paymentstatus,
    required this.quantity,
    this.address,
  });

  // Custom methods to handle Timestamp serialization
  static Timestamp? _fromTimestamp(Timestamp? timestamp) => timestamp;
  static Timestamp? _toTimestamp(Timestamp? timestamp) => timestamp;

  factory Orders.fromJson(Map<String, dynamic> json) => _$OrdersFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersToJson(this);

  // Safe method to format the dateTime
  String getFormattedDateTime() {
    if (dateTime == null) {
      return 'No date available'; // Default value if dateTime is null
    }
    // Format the timestamp to a readable format
    DateTime date = dateTime!.toDate();
    return DateFormat('d MMMM yyyy at HH:mm:ss').format(date);
  }
}
