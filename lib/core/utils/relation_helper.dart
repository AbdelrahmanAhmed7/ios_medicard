import 'package:easy_localization/easy_localization.dart';

class RelationHelper {
  static String getLocalizedRelation(int? relation) {
    switch (relation) {
      case 1:
        return 'family_members.relation_father'.tr();
      case 2:
        return 'family_members.relation_mother'.tr();
      case 3:
        return 'family_members.relation_son'.tr();
      case 4:
        return 'family_members.relation_daughter'.tr();
      case 5:
        return 'family_members.relation_brother'.tr();
      case 6:
        return 'family_members.relation_sister'.tr();
      case 7:
        return 'family_members.relation_husband'.tr();
      case 8:
        return 'family_members.relation_wife'.tr();
      case 9:
        return 'family_members.relation_grandfather'.tr();
      case 10:
        return 'family_members.relation_grandmother'.tr();
      case 11:
        return 'family_members.relation_uncle'.tr();
      case 12:
        return 'family_members.relation_aunt'.tr();
      case 13:
        return 'family_members.relation_cousin'.tr();
      default:
        return 'family_members.relation_other'.tr();
    }
  }

  static List<Map<String, dynamic>> getRelationsList() {
    return [
      {'id': 1, 'name': 'family_members.relation_father'.tr()},
      {'id': 2, 'name': 'family_members.relation_mother'.tr()},
      {'id': 3, 'name': 'family_members.relation_son'.tr()},
      {'id': 4, 'name': 'family_members.relation_daughter'.tr()},
      {'id': 5, 'name': 'family_members.relation_brother'.tr()},
      {'id': 6, 'name': 'family_members.relation_sister'.tr()},
      {'id': 7, 'name': 'family_members.relation_husband'.tr()},
      {'id': 8, 'name': 'family_members.relation_wife'.tr()},
      {'id': 9, 'name': 'family_members.relation_grandfather'.tr()},
      {'id': 10, 'name': 'family_members.relation_grandmother'.tr()},
      {'id': 11, 'name': 'family_members.relation_uncle'.tr()},
      {'id': 12, 'name': 'family_members.relation_aunt'.tr()},
      {'id': 13, 'name': 'family_members.relation_cousin'.tr()},
    ];
  }
}
