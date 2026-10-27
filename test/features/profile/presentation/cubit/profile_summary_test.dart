import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/domain/medicard_repository.dart';
import 'package:medicard/domain/usecases/logout_usecase.dart';
import 'package:medicard/features/profile/data/models/profile_response_model.dart';
import 'package:medicard/features/profile/data/models/profile_summary_response_model.dart';
import 'package:medicard/features/profile/domain/usecases/activate_member_card_usecase.dart';
import 'package:medicard/features/profile/domain/usecases/change_language_usecase.dart';
import 'package:medicard/features/profile/domain/usecases/delete_profile_image_usecase.dart';
import 'package:medicard/features/profile/domain/usecases/get_profile_summary_usecase.dart';
import 'package:medicard/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:medicard/features/profile/domain/usecases/update_profile_v2_usecase.dart';
import 'package:medicard/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:medicard/features/profile/presentation/cubit/profile_state.dart';

class _FakeMedicardRepository implements MedicardRepository {
  ApiResult<ProfileResponseModel> profileResult =
      const ApiResult<ProfileResponseModel>.success(
        ProfileResponseModel(
          succeeded: true,
          data: ProfileData(firstName: 'Sara'),
        ),
      );
  ApiResult<ProfileSummaryResponseModel> summaryResult =
      ApiResult<ProfileSummaryResponseModel>.success(
        ProfileSummaryResponseModel(
          succeeded: true,
          data: const ProfileSummaryData(
            familyMembersCount: 3,
            rewardPoints: 250,
          ),
        ),
      );

  @override
  Future<ApiResult<ProfileResponseModel>> getProfile() async => profileResult;

  @override
  Future<ApiResult<ProfileSummaryResponseModel>> getProfileSummary() async =>
      summaryResult;

  @override
  Future<ApiResult<ProfileResponseModel>> updateProfileV2({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String nationalId,
    String? passportNumber,
    required bool isMale,
    required String birthDate,
    String? imagePath,
    bool removeImage = false,
    String? currentImageUrl,
  }) async => const ApiResult<ProfileResponseModel>.success(
    ProfileResponseModel(succeeded: true),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProfileCubit _cubit(_FakeMedicardRepository repo) => ProfileCubit(
  GetProfileUseCase(repo),
  GetProfileSummaryUseCase(repo),
  UpdateProfileV2UseCase(repo),
  DeleteProfileImageUseCase(repo),
  ChangeLanguageUseCase(repo),
  ActivateMemberCardUseCase(repo),
  const LogoutUseCase(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileCubit profile summary', () {
    late _FakeMedicardRepository repo;
    late ProfileCubit cubit;

    setUp(() {
      repo = _FakeMedicardRepository();
      cubit = _cubit(repo);
    });

    tearDown(() => cubit.close());

    test(
      'attaches summary to the success state when data is present',
      () async {
        await cubit.loadProfile();
        // Summary loads right after profile (unawaited inside the cubit).
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = cubit.state;
        expect(state, isA<ProfileState>());
        state.maybeWhen(
          success: (data, summary) {
            expect(data.firstName, 'Sara');
            expect(summary?.rewardPoints, 250);
            expect(summary?.familyMembersCount, 3);
          },
          orElse: () => fail('expected success state, got $state'),
        );
      },
    );

    test(
      'keeps profile visible with zero defaults when data is null',
      () async {
        repo.summaryResult = ApiResult<ProfileSummaryResponseModel>.success(
          ProfileSummaryResponseModel(
            succeeded: true,
            message: 'Profile summary retrieved successfully.',
            data: null,
          ),
        );

        await cubit.loadProfile();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        cubit.state.maybeWhen(
          success: (data, summary) {
            expect(data.firstName, 'Sara');
            expect(summary, isNull);
          },
          orElse: () => fail('expected success state, got ${cubit.state}'),
        );
      },
    );

    test('summary failure never breaks the visible profile', () async {
      repo.summaryResult = const ApiResult<ProfileSummaryResponseModel>.failure(
        'Offline',
      );

      await cubit.loadProfile();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      cubit.state.maybeWhen(
        success: (data, summary) {
          expect(data.firstName, 'Sara');
          expect(summary, isNull);
        },
        orElse: () => fail('expected success state, got ${cubit.state}'),
      );
    });

    test(
      'refreshSummary picks up new count and points without full reload',
      () async {
        await cubit.loadProfile();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        repo.summaryResult = ApiResult<ProfileSummaryResponseModel>.success(
          ProfileSummaryResponseModel(
            succeeded: true,
            data: const ProfileSummaryData(
              familyMembersCount: 5,
              rewardPoints: 900,
            ),
          ),
        );

        await cubit.refreshSummary();

        cubit.state.maybeWhen(
          success: (data, summary) {
            expect(data.firstName, 'Sara');
            expect(summary?.familyMembersCount, 5);
            expect(summary?.rewardPoints, 900);
          },
          orElse: () => fail('expected success state, got ${cubit.state}'),
        );
      },
    );

    test('keeps summary after profile update and return to profile', () async {
      await cubit.loadProfile();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final didUpdate = await cubit.updateProfile(
        firstName: 'Salma',
        lastName: 'Ali',
        phoneNumber: '01000000000',
        nationalId: '29901010100000',
        isMale: false,
        birthDate: '1999-01-01',
        currentData: const ProfileData(firstName: 'Sara'),
      );

      expect(didUpdate, isTrue);
      cubit.state.maybeWhen(
        success: (data, summary) {
          expect(data.firstName, 'Salma');
          expect(summary?.rewardPoints, 250);
          expect(summary?.familyMembersCount, 3);
        },
        orElse: () => fail('expected success state, got ${cubit.state}'),
      );
    });
  });
}
