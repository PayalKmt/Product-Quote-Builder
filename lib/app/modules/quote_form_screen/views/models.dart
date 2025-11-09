// Model for Client Information
import 'package:get/get.dart';

class ClientInfo {
  String name;
  String contact;
  String address;
  String reference;

  ClientInfo({
    this.name = '',
    this.contact = '',
    this.address = '',
    this.reference = '',
  });
}

// Model for a single Line Item in the quote
class LineItem {
  final String id; // Unique ID for key management
  RxString name;
  RxDouble quantity;
  RxDouble rate;
  RxDouble discountPercent;
  RxDouble taxPercent;

  LineItem({
    required this.id,
    String name = 'New Product/Service',
    double quantity = 1.0,
    double rate = 0.0,
    double discountPercent = 0.0,
    double taxPercent = 10.0, // Default 10% tax
  })  : name = name.obs,
        quantity = quantity.obs,
        rate = rate.obs,
        discountPercent = discountPercent.obs,
        taxPercent = taxPercent.obs;

  // Calculated properties for this item
  double get priceAfterDiscountPerUnit => rate.value * (1 - discountPercent.value / 100.0);
  double get taxableAmount => priceAfterDiscountPerUnit * quantity.value;
  double get taxAmount => taxableAmount * (taxPercent.value / 100.0);
  double get total => taxableAmount + taxAmount;
}