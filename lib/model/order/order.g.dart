// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Orders _$OrdersFromJson(Map<String, dynamic> json) => Orders(
      orderid: json['orderid'] as String?,
      customer: json['customer'] as String?,
      dateTime: Orders._fromTimestamp(json['dateTime'] as Timestamp?),
      name: json['name'] as String?,
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      paymentstatus: json['payment status'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      address: json['address'] as String?,
    );

Map<String, dynamic> _$OrdersToJson(Orders instance) => <String, dynamic>{
      'orderid': instance.orderid,
      'customer': instance.customer,
      'name': instance.name,
      'image': instance.image,
      'price': instance.price,
      'payment status': instance.paymentstatus,
      'quantity': instance.quantity,
      'address': instance.address,
      'dateTime': Orders._toTimestamp(instance.dateTime),
    };
