import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/features/content/data/models/content_response_model.dart';
import 'package:medicard/features/content/domain/models/content_type.dart';
import 'package:medicard/features/content/domain/repositories/content_repository.dart';
import 'package:medicard/features/content/domain/use_cases/get_content_use_case.dart';
import 'package:medicard/features/content/presentation/cubit/content_cubit.dart';
import 'package:medicard/features/content/presentation/cubit/content_state.dart';
import 'package:medicard/features/content/presentation/utils/content_link_handler.dart';

void main() {
  group('ContentType', () {
    test('maps each type to the correct endpoint slug and title key', () {
      expect(ContentType.privacyPolicy.slug, 'privacy-policy');
      expect(ContentType.privacyPolicy.apiPath, '/Content/privacy-policy');
      expect(ContentType.privacyPolicy.titleKey, 'content.privacy_policy');

      expect(ContentType.refundPolicy.slug, 'refund-policy');
      expect(ContentType.refundPolicy.apiPath, '/Content/refund-policy');
      expect(ContentType.refundPolicy.titleKey, 'content.refund_policy');

      expect(ContentType.termsAndConditions.slug, 'terms-and-conditions');
      expect(
        ContentType.termsAndConditions.apiPath,
        '/Content/terms-and-conditions',
      );
      expect(
        ContentType.termsAndConditions.titleKey,
        'content.terms_and_conditions',
      );
    });
  });

  group('ContentResponseModel', () {
    test('parses id and description safely', () {
      final response = ContentResponseModel.fromJson({
        'httpStatusCode': 200,
        'succeeded': true,
        'data': {'id': '13', 'description': '<h1>Privacy</h1>'},
      });

      expect(response.data?.id, 13);
      expect(response.data?.description, '<h1>Privacy</h1>');
    });

    test('defaults null description to an empty string', () {
      final response = ContentResponseModel.fromJson({
        'succeeded': true,
        'data': {'id': null, 'description': null},
      });

      expect(response.data?.id, isNull);
      expect(response.data?.description, isEmpty);
    });

    test('handles succeeded false with missing data', () {
      final response = ContentResponseModel.fromJson({
        'httpStatusCode': 400,
        'succeeded': false,
        'message': 'Not available',
        'data': null,
      });

      expect(response.succeeded, isFalse);
      expect(response.message, 'Not available');
      expect(response.data, isNull);
    });
  });

  group('ContentCubit', () {
    test('emits loading then success', () async {
      final repository = _FakeContentRepository([
        const ApiResult.success(
          ContentData(id: 1, description: '<p>Hello</p>'),
        ),
      ]);
      final cubit = ContentCubit(GetContentUseCase(repository));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const ContentState.loading(),
          const ContentState.success(
            ContentData(id: 1, description: '<p>Hello</p>'),
          ),
        ]),
      );

      await cubit.loadContent(ContentType.privacyPolicy);
      await cubit.close();
    });

    test('emits loading then error', () async {
      final repository = _FakeContentRepository([
        const ApiResult<ContentData>.failure('content.load_failed'),
      ]);
      final cubit = ContentCubit(GetContentUseCase(repository));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const ContentState.loading(),
          const ContentState.failed('content.load_failed'),
        ]),
      );

      await cubit.loadContent(ContentType.refundPolicy);
      await cubit.close();
    });

    test('retry executes the request again', () async {
      final repository = _FakeContentRepository([
        const ApiResult<ContentData>.failure('content.load_failed'),
        const ApiResult.success(
          ContentData(id: 2, description: '<p>Retry ok</p>'),
        ),
      ]);
      final cubit = ContentCubit(GetContentUseCase(repository));

      await cubit.loadContent(ContentType.termsAndConditions);
      await cubit.retry(ContentType.termsAndConditions);

      expect(repository.calls, 2);
      expect(
        cubit.state,
        const ContentState.success(
          ContentData(id: 2, description: '<p>Retry ok</p>'),
        ),
      );
      await cubit.close();
    });
  });

  group('ContentLinkHandler', () {
    test('relative root link is handled as in-app navigation', () {
      expect(
        ContentLinkHandler.classifyUrl('/'),
        ContentLinkAction.ignoredRelative,
      );
    });

    test('classifies supported external links', () {
      expect(
        ContentLinkHandler.classifyUrl('mailto:info@medicardeg.com'),
        ContentLinkAction.email,
      );
      expect(
        ContentLinkHandler.classifyUrl('tel:+201000000000'),
        ContentLinkAction.phone,
      );
      expect(
        ContentLinkHandler.classifyUrl('https://example.com'),
        ContentLinkAction.web,
      );
      expect(
        ContentLinkHandler.classifyUrl('https://wa.me/201000000000'),
        ContentLinkAction.whatsapp,
      );
    });

    test('rejects unsupported schemes and non-root relative links', () {
      expect(
        ContentLinkHandler.classifyUrl('javascript:alert(1)'),
        ContentLinkAction.unsupported,
      );
      expect(
        ContentLinkHandler.classifyUrl('/privacy'),
        ContentLinkAction.unsupported,
      );
    });
  });
}

class _FakeContentRepository implements ContentRepository {
  final List<ApiResult<ContentData>> _results;
  int calls = 0;

  _FakeContentRepository(this._results);

  @override
  Future<ApiResult<ContentData>> getContent(ContentType contentType) async {
    final index = calls++;
    return _results[index.clamp(0, _results.length - 1)];
  }
}
