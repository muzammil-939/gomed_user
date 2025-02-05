class UserModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  UserModel({this.statusCode, this.success, this.messages, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = json['messages'].cast<String>();
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  UserModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return UserModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  UserModel.initial()
      : statusCode = 0,
        success = false,
        messages = [],
        data = [];
}

class Data {
  String? accessToken;
  String? refreshToken;
  User? user;

  Data({this.accessToken, this.refreshToken, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['access_token'] = this.accessToken;
    data['refresh_token'] = this.refreshToken;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }

  Data copyWith({
    String? accessToken,
    String? refreshToken,
    User? user,
  }) {
    return Data(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  Data.initial()
      : accessToken = "",
        refreshToken = "",
        user = User.initial();
}

class User {
  String? sId;
  String? mobile;
  String? password;
  String? role;
  String? email;
  String? address;
  String? employeeNumber;
  String? certificate;
  String? experience;
  String? ownerName;
  String? photo;
  String? aadhar;
  String? gstNumber;
  String? firmName;
  String? activity;
  List<dynamic>? products;
  int? iV;

  User({
    this.sId,
    this.mobile,
    this.password,
    this.role,
    this.email,
    this.address,
    this.employeeNumber,
    this.certificate,
    this.experience,
    this.ownerName,
    this.photo,
    this.aadhar,
    this.gstNumber,
    this.firmName,
    this.activity,
    this.products,
    this.iV,
  });

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mobile = json['mobile'];
    password = json['password'];
    role = json['role'];
    email = json['email'];
    address = json['address'];
    employeeNumber = json['employeeNumber'];
    certificate = json['certificate'];
    experience = json['experience'];
    ownerName = json['ownerName'];
    photo = json['photo'];
    aadhar = json['aadhar'];
    gstNumber = json['gstNumber'];
    firmName = json['firmName'];
    activity = json['activity'];
    products = json['products'] ?? [];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['mobile'] = this.mobile;
    data['password'] = this.password;
    data['role'] = this.role;
    data['email'] = this.email;
    data['address'] = this.address;
    data['employeeNumber'] = this.employeeNumber;
    data['certificate'] = this.certificate;
    data['experience'] = this.experience;
    data['ownerName'] = this.ownerName;
    data['photo'] = this.photo;
    data['aadhar'] = this.aadhar;
    data['gstNumber'] = this.gstNumber;
    data['firmName'] = this.firmName;
    data['activity'] = this.activity;
    data['products'] = this.products;
    data['__v'] = this.iV;
    return data;
  }

  User copyWith({
    String? sId,
    String? mobile,
    String? password,
    String? role,
    String? email,
    String? address,
    String? employeeNumber,
    String? certificate,
    String? experience,
    String? ownerName,
    String? photo,
    String? aadhar,
    String? gstNumber,
    String? firmName,
    String? activity,
    List<dynamic>? products,
    int? iV,
  }) {
    return User(
      sId: sId ?? this.sId,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      role: role ?? this.role,
      email: email ?? this.email,
      address: address ?? this.address,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      certificate: certificate ?? this.certificate,
      experience: experience ?? this.experience,
      ownerName: ownerName ?? this.ownerName,
      photo: photo ?? this.photo,
      aadhar: aadhar ?? this.aadhar,
      gstNumber: gstNumber ?? this.gstNumber,
      firmName: firmName ?? this.firmName,
      activity: activity ?? this.activity,
      products: products ?? this.products,
      iV: iV ?? this.iV,
    );
  }

  User.initial()
      : sId = "",
        mobile = "",
        password = "",
        role = "",
        email = "",
        address = "",
        employeeNumber = "",
        certificate = "",
        experience = "",
        ownerName = "",
        photo = "",
        aadhar = "",
        gstNumber = "",
        firmName = "",
        activity = "",
        products = [],
        iV = 0;
}
