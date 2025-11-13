class Application {
  final String id;
  final String uuid;
  final String positionName;
  final String companyName;
  final String applicantId;
  final String applicantUuid;
  final String applicantName;
  final String applicantAddress;
  final String applicantPhone;
  final String applicantGender;
  final String status;
  final DateTime appliedAt;

  Application({
    required this.id,
    required this.uuid,
    required this.positionName,
    required this.companyName,
    required this.applicantId,
    required this.applicantUuid,
    required this.applicantName,
    required this.applicantAddress,
    required this.applicantPhone,
    required this.applicantGender,
    required this.status,
    required this.appliedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    final society = json['society'] ?? {};
    final position = json['available_position'] ?? {};
    final company = position['company'] ?? {};

    return Application(
      id: json['id'].toString(),
      uuid: json['uuid'] ?? '',
      positionName: position['position_name'] ?? '-',
      companyName: company['name'] ?? '-',
      applicantId: society['id']?.toString() ?? '',
      applicantUuid: society['uuid'] ?? '',
      applicantName: society['name'] ?? '-',
      applicantAddress: society['address'] ?? '-',
      applicantPhone: society['phone'] ?? '-',
      applicantGender: society['gender'] ?? '-',
      status: json['status'] ?? 'PENDING',
      appliedAt: DateTime.tryParse(json['apply_date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'position_name': positionName,
      'company_name': companyName,
      'applicant_id': applicantId,
      'applicant_uuid': applicantUuid,
      'applicant_name': applicantName,
      'applicant_address': applicantAddress,
      'applicant_phone': applicantPhone,
      'applicant_gender': applicantGender,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
    };
  }

  Application copyWith({
    String? id,
    String? uuid,
    String? positionName,
    String? companyName,
    String? applicantId,
    String? applicantUuid,
    String? applicantName,
    String? applicantAddress,
    String? applicantPhone,
    String? applicantGender,
    String? status,
    DateTime? appliedAt,
  }) {
    return Application(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      positionName: positionName ?? this.positionName,
      companyName: companyName ?? this.companyName,
      applicantId: applicantId ?? this.applicantId,
      applicantUuid: applicantUuid ?? this.applicantUuid,
      applicantName: applicantName ?? this.applicantName,
      applicantAddress: applicantAddress ?? this.applicantAddress,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      applicantGender: applicantGender ?? this.applicantGender,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }
}
