class ActivateCardRequestModel {
  final String firstName;
  final String lastName;
  final String cardNumber;
  final bool isMale;
  final String phoneNumber;
  final String? nationalId;
  final String? passportNumber;
  final String birthDate;
  final String password;
  final String confirmPassword;

  const ActivateCardRequestModel({
    required this.firstName, required this.lastName, required this.cardNumber, required this.isMale, required this.phoneNumber, required this.birthDate, required this.password, required this.confirmPassword, this.nationalId, this.passportNumber,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'cardNumber': cardNumber,
    'isMale': isMale,
    'phoneNumber': phoneNumber,
    'nationalId': nationalId,
    'passportNumber': passportNumber,
    'birthDate': birthDate,
    'password': password,
    'confirmPassword': confirmPassword,
  };
}