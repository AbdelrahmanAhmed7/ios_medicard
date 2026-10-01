import 'package:flutter_test/flutter_test.dart';
import 'package:medicard/medicard_network/logic/provider_page_state.dart';
import 'package:medicard/medicard_network/presentation/widgets/provider_rebuild_scopes.dart';
import 'package:medicard/network/data/provider_services_response_model.dart';

ProviderService _service(int id, {bool selected = false}) => ProviderService(
  id: id,
  serviceName: 'Service $id',
  priceAfter: 100,
  isSelected: selected,
);

void main() {
  group('ProviderRebuildScopes', () {
    const base = ProviderPageState();

    group('search query change (every keystroke, debounced)', () {
      final changed = base.copyWith(searchQuery: 'lab');

      test('does not rebuild header, search row, or cart bar', () {
        expect(
          ProviderRebuildScopes.isHeaderSliceChanged(base, changed),
          isFalse,
        );
        expect(
          ProviderRebuildScopes.isSearchRowSliceChanged(base, changed),
          isFalse,
        );
        expect(
          ProviderRebuildScopes.isCartBarSliceChanged(base, changed),
          isFalse,
        );
      });

      test('rebuilds content (it filters by the query)', () {
        expect(
          ProviderRebuildScopes.isContentSliceChanged(base, changed),
          isTrue,
        );
      });
    });

    group('pending cart-action churn (every +/- tap)', () {
      final changed = base.copyWith(
        pendingCartActionIds: const {7},
      );

      test('does not rebuild header, search row, or cart bar', () {
        expect(
          ProviderRebuildScopes.isHeaderSliceChanged(base, changed),
          isFalse,
        );
        expect(
          ProviderRebuildScopes.isSearchRowSliceChanged(base, changed),
          isFalse,
        );
        expect(
          ProviderRebuildScopes.isCartBarSliceChanged(base, changed),
          isFalse,
        );
      });

      test('rebuilds content (spinners live there)', () {
        expect(
          ProviderRebuildScopes.isContentSliceChanged(base, changed),
          isTrue,
        );
      });
    });

    group('cart membership change', () {
      final changed = base.copyWith(
        fullServices: [_service(1, selected: true)],
      );

      test('rebuilds cart bar and content, not header or search row', () {
        expect(
          ProviderRebuildScopes.isCartBarSliceChanged(base, changed),
          isTrue,
        );
        expect(
          ProviderRebuildScopes.isContentSliceChanged(base, changed),
          isTrue,
        );
        expect(
          ProviderRebuildScopes.isHeaderSliceChanged(base, changed),
          isFalse,
        );
        expect(
          ProviderRebuildScopes.isSearchRowSliceChanged(base, changed),
          isFalse,
        );
      });
    });

    group('header-only change (initial provider load)', () {
      test('does not rebuild content', () {
        final changed = base.copyWith(isProviderLoading: true);
        expect(
          ProviderRebuildScopes.isHeaderSliceChanged(base, changed),
          isTrue,
        );
        expect(
          ProviderRebuildScopes.isContentSliceChanged(base, changed),
          isFalse,
        );
        expect(
          ProviderRebuildScopes.isCartBarSliceChanged(base, changed),
          isFalse,
        );
      });
    });

    group('view switch', () {
      final changed = base.copyWith(
        currentView: ProviderViewType.packages,
      );

      test('rebuilds header, search row, and content', () {
        expect(
          ProviderRebuildScopes.isHeaderSliceChanged(base, changed),
          isTrue,
        );
        expect(
          ProviderRebuildScopes.isSearchRowSliceChanged(base, changed),
          isTrue,
        );
        expect(
          ProviderRebuildScopes.isContentSliceChanged(base, changed),
          isTrue,
        );
      });
    });

    group('package details slice', () {
      test('only the opened package sheet rebuilds', () {
        final changed = base.copyWith(
          loadingPackageDetailsIds: const {42},
        );
        expect(
          ProviderRebuildScopes.isPackageSheetSliceChanged(42, base, changed),
          isTrue,
        );
        expect(
          ProviderRebuildScopes.isPackageSheetSliceChanged(43, base, changed),
          isFalse,
        );
        // And the screen sections ignore it entirely.
        expect(
          ProviderRebuildScopes.isContentSliceChanged(base, changed),
          isFalse,
        );
        expect(
          ProviderRebuildScopes.isHeaderSliceChanged(base, changed),
          isFalse,
        );
      });
    });
  });
}
