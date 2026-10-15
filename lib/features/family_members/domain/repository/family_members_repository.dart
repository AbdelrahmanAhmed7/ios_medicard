import 'package:medicard/features/family_members/data/models/family_member_model.dart';

abstract class FamilyMembersRepository {
  Future<List<FamilyMemberModel>> getFamilyMembers();
  Future<FamilyMemberModel> getFamilyMember(int id);
  Future<void> createFamilyMember(
    String firstName,
    String lastName,
    int relation,
    String? imageUrl,
  );
  Future<void> updateFamilyMember(
    int id,
    String firstName,
    String lastName,
    int relation,
    String? imageUrl,
  );
  Future<void> deleteFamilyMember(int id);
}
