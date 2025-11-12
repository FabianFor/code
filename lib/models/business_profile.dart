class BusinessProfile {
  String businessName;
  String logoPath;
  String phone;
  String email;
  String address;
  String primaryColor;
  String secondaryColor;

  BusinessProfile({
    this.businessName = 'MiNegocio',
    this.logoPath = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.primaryColor = '#2196F3',
    this.secondaryColor = '#4CAF50',
  });

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'logoPath': logoPath,
        'phone': phone,
        'email': email,
        'address': address,
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
      };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      businessName: json['businessName'] ?? 'MiNegocio',
      logoPath: json['logoPath'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      primaryColor: json['primaryColor'] ?? '#2196F3',
      secondaryColor: json['secondaryColor'] ?? '#4CAF50',
    );
  }
}