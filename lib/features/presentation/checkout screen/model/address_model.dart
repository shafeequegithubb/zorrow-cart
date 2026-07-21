class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
  });

  Map<String, dynamic> toMap() {
    return {
      "fullName": fullName,
      "phone": phone,
      "address": address,
      "city": city,
      "state": state,
      "pincode": pincode,
    };
  }

  factory AddressModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AddressModel(
      id: documentId,
      fullName: map["fullName"] ?? "",
      phone: map["phone"] ?? "",
      address: map["address"] ?? "",
      city: map["city"] ?? "",
      state: map["state"] ?? "",
      pincode: map["pincode"] ?? "",
    );
  }
}