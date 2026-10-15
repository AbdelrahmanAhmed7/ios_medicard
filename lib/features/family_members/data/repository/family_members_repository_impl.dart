import 'package:medicard/features/family_members/data/models/family_member_model.dart';
import 'package:medicard/service/medicard_api_service.dart';
import '../../domain/repository/family_members_repository.dart';
import '../models/create_family_member_request_model.dart';
import '../models/get_family_members_response_model.dart';
import '../models/get_family_member_response_model.dart';
import '../models/family_member_operation_response_model.dart';

class FamilyMembersRepositoryImpl implements FamilyMembersRepository {
  final MedicardApiService apiService;

  FamilyMembersRepositoryImpl(this.apiService);

  @override
  Future<List<FamilyMemberModel>> getFamilyMembers() async {
    // Token is injected automatically by AuthInterceptor.
    final GetFamilyMembersResponseModel response = await apiService
        .getFamilyMembers();
    if (response.succeeded == true) {
      // data can be null or empty after deleting the last member — treat as []
      return response.data ?? [];
    } else {
      throw Exception(
        response.errors?.join(', ') ?? 'Failed to get family members',
      );
    }
  }

  @override
  Future<FamilyMemberModel> getFamilyMember(int id) async {
    final GetFamilyMemberResponseModel response = await apiService
        .getFamilyMember(id);
    if (response.succeeded == true && response.data != null) {
      return response.data!;
    } else {
      throw Exception(
        response.errors?.join(', ') ?? 'Failed to get family member',
      );
    }
  }

  @override
  Future<void> createFamilyMember(
    String firstName,
    String lastName,
    int relation,
    String? imageUrl,
  ) async {
    final CreateFamilyMemberRequestModel request =
        CreateFamilyMemberRequestModel(
          firstName: firstName,
          lastName: lastName,
          relation: relation,
          imageUrl: imageUrl,
        );
    final FamilyMemberOperationResponseModel response = await apiService
        .createFamilyMember(request);
    if (response.succeeded != true) {
      throw Exception(
        response.errors?.join(', ') ?? 'Failed to create family member',
      );
    }
  }

  @override
  Future<void> updateFamilyMember(
    int id,
    String firstName,
    String lastName,
    int relation,
    String? imageUrl,
  ) async {
    final CreateFamilyMemberRequestModel request =
        CreateFamilyMemberRequestModel(
          firstName: firstName,
          lastName: lastName,
          relation: relation,
          imageUrl: imageUrl,
        );
    final FamilyMemberOperationResponseModel response = await apiService
        .updateFamilyMember(id, request);
    if (response.succeeded != true) {
      throw Exception(
        response.errors?.join(', ') ?? 'Failed to update family member',
      );
    }
  }

  @override
  Future<void> deleteFamilyMember(int id) async {
    final FamilyMemberOperationResponseModel response = await apiService
        .deleteFamilyMember(id);
    if (response.succeeded != true) {
      throw Exception(
        response.errors?.join(', ') ?? 'Failed to delete family member',
      );
    }
  }
}
