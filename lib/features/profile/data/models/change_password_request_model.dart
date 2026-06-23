class ChangePasswordRequestModel {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  const ChangePasswordRequestModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
    'confirmNewPassword': confirmNewPassword,
  };
}
