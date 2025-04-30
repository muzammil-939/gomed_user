class ServicebookingModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  ServicebookingModel({this.statusCode, this.success, this.messages, this.data});

 ServicebookingModel.fromJson(Map<String, dynamic> json) {
  statusCode = json['statusCode'];
  success = json['success'];

  // Check if 'messages' is null, and if it is, assign an empty list
  messages = (json['messages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

  if (json['data'] != null) {
    data = <Data>[];
    json['data'].forEach((v) {
      data!.add(Data.fromJson(v));
    });
  }
}



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // CopyWith Method
  ServicebookingModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return ServicebookingModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  // Initial Method
  static ServicebookingModel initial() {
    return ServicebookingModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }
}
class Data {
  String? sId;
  UserId? userId;
  List<ServiceIds>? serviceIds;
  String? productId;
  String? location;
  String? address;
  String? date;
  String? time;
  String? status;
  String? serviceEngineerId;
  String? startOtp;
  String? endOtp;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.sId,
      this.userId,
      this.serviceIds,
      this.productId,
      this.location,
      this.address,
      this.date,
      this.time,
      this.status,
      this.serviceEngineerId,
      this.startOtp,
      this.endOtp,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'] != null ? new UserId.fromJson(json['userId']) : null;
    if (json['serviceIds'] != null) {
      serviceIds = <ServiceIds>[];
      json['serviceIds'].forEach((v) {
        serviceIds!.add(new ServiceIds.fromJson(v));
      });
    }
    productId = json['productId'];
    location = json['location'];
    address = json['address'];
    date = json['date'];
    time = json['time'];
    status = json['status'];
    serviceEngineerId = json['serviceEngineerId'];
    startOtp = json['startOtp'];
    endOtp = json['endOtp'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.userId != null) {
      data['userId'] = this.userId!.toJson();
    }
    if (this.serviceIds != null) {
      data['serviceIds'] = this.serviceIds!.map((v) => v.toJson()).toList();
    }
    data['productId'] = this.productId;
    data['location'] = this.location;
    data['address'] = this.address;
    data['date'] = this.date;
    data['time'] = this.time;
    data['status'] = this.status;
    data['serviceEngineerId'] = this.serviceEngineerId;
    data['startOtp'] = this.startOtp;
    data['endOtp'] = this.endOtp;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }

  // CopyWith Method
  Data copyWith({
    String? sId,
    UserId? userId,
    List<ServiceIds>? serviceIds,
    String? productId,
    String? location,
    String? address,
    String? date,
    String? time,
    String? status,
    String? serviceEngineerId,
    String? startOtp,
    String? endOtp,
    String? createdAt,
    String? updatedAt,
  }) {
    return Data(
      sId: sId ?? this.sId,
      userId: userId ?? this.userId,
      serviceIds: serviceIds ?? this.serviceIds,
      productId: productId ?? this.productId,
      location: location ?? this.location,
      address: address ?? this.address,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      serviceEngineerId: serviceEngineerId ?? this.serviceEngineerId,
      startOtp: startOtp ?? this.startOtp,
      endOtp: endOtp ?? this.endOtp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Initial Method
  static Data initial() {
    return Data(
      sId: '',
      userId: UserId.initial(),
      serviceIds: [],
      productId: '',
      location: '',
      address: '',
      date: '',
      time: '',
      status: '',
      serviceEngineerId: '',
      startOtp: '',
      endOtp: '',
      createdAt: '',
      updatedAt: '',
    );
  }
}
class UserId {
  String? sId;
  String? mobile;
  String? name;
  String? email;
  List<String>? profileImage;

  UserId({this.sId, this.mobile, this.name, this.email, this.profileImage});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mobile = json['mobile'];
    name = json['name'];
    email = json['email'];
    // Add null check for profileImage
    profileImage = json['profileImage'] != null 
        ? List<String>.from(json['profileImage']) 
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['mobile'] = this.mobile;
    data['name'] = this.name;
    data['email'] = this.email;
    data['profileImage'] = this.profileImage;
    return data;
  }

  // CopyWith Method
  UserId copyWith({
    String? sId,
    String? mobile,
    String? name,
    String? email,
    List<String>? profileImage,
  }) {
    return UserId(
      sId: sId ?? this.sId,
      mobile: mobile ?? this.mobile,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  // Initial Method
  static UserId initial() {
    return UserId(
      sId: '',
      mobile: '',
      name: '',
      email: '',
      profileImage: [],
    );
  }
}
class ServiceIds {
  String? sId;
  String? name;
  String? details;
  int? price;
  List<String>? productIds;

  ServiceIds({this.sId, this.name, this.details, this.price, this.productIds});

  ServiceIds.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    details = json['details'];
    price = json['price'];
    productIds = json['productIds'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['details'] = this.details;
    data['price'] = this.price;
    data['productIds'] = this.productIds;
    return data;
  }

  // CopyWith Method
  ServiceIds copyWith({
    String? sId,
    String? name,
    String? details,
    int? price,
    List<String>? productIds,
  }) {
    return ServiceIds(
      sId: sId ?? this.sId,
      name: name ?? this.name,
      details: details ?? this.details,
      price: price ?? this.price,
      productIds: productIds ?? this.productIds,
    );
  }

  // Initial Method
  static ServiceIds initial() {
    return ServiceIds(
      sId: '',
      name: '',
      details: '',
      price: 0,
      productIds: [],
    );
  }
}
