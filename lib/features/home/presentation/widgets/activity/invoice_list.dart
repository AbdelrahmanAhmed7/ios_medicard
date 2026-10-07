import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/auth_shared_widgets.dart';
import '../../../../../features/activity/domain/models/invoice_item.dart';
import '../../../../../features/activity/presentation/cubit/activity_cubit.dart';
import 'activity_empty_view.dart';
import 'invoice_card.dart';

class InvoiceList extends StatefulWidget {
  final List<InvoiceItem> items;
  final String emptyTitleKey;
  final String emptyMessageKey;
  final IconData emptyIcon;
  final bool isLoadingMore;
  final bool hasMore;

  const InvoiceList({
    super.key,
    required this.items,
    required this.emptyTitleKey,
    required this.emptyMessageKey,
    required this.emptyIcon,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  State<InvoiceList> createState() => InvoiceListState();
}

class InvoiceListState extends State<InvoiceList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant InvoiceList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.hasMore != widget.hasMore ||
        oldWidget.isLoadingMore != widget.isLoadingMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrefetchMore());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160.h) {
      context.read<ActivityCubit>().loadMore();
    }
  }

  void _maybePrefetchMore() {
    if (!mounted || !widget.hasMore || widget.isLoadingMore) return;
    if (!_scrollController.hasClients) {
      if (widget.items.isEmpty) {
        context.read<ActivityCubit>().loadMore();
      }
      return;
    }
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    if (position.maxScrollExtent <= 0 ||
        position.pixels >= position.maxScrollExtent - 160.h) {
      context.read<ActivityCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoadingMore && !widget.hasMore) {
      return ActivityEmptyView(
        title: widget.emptyTitleKey.tr(),
        message: widget.emptyMessageKey.tr(),
        icon: widget.emptyIcon,
      );
    }

    if (widget.items.isEmpty && (widget.isLoadingMore || widget.hasMore)) {
      return const Center(
        child: CircularProgressIndicator(color: kAuthBlue),
      );
    }

    final itemCount =
        widget.items.length + (widget.isLoadingMore || widget.hasMore ? 1 : 0);

    return RefreshIndicator(
      color: kAuthBlue,
      onRefresh: () => context
          .read<ActivityCubit>()
          .loadInvoices(tab: TabScope.of(context)),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: widget.isLoadingMore
                    ? const CircularProgressIndicator(color: kAuthBlue)
                    : const SizedBox.shrink(),
              ),
            );
          }
          return InvoiceCard(item: widget.items[index]);
        },
      ),
    );
  }
}

class TabScope extends InheritedWidget {
  final int tab;
  const TabScope({super.key, required this.tab, required super.child});

  static int of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabScope>()!.tab;
  }

  @override
  bool updateShouldNotify(TabScope oldWidget) => tab != oldWidget.tab;
}
