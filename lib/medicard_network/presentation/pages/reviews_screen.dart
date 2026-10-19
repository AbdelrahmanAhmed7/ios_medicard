import 'package:medicard/core/widgets/app_simple_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/error_state_widget.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import '../widgets/provider_review_card.dart';

/// Standalone reviews page. Shares the provider page cubit (passed via
/// route extra) so cart/selection state stays in sync.
class ReviewsScreen extends StatefulWidget {
  final int providerId;
  final String? providerName;

  const ReviewsScreen({super.key, required this.providerId, this.providerName});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProviderPageCubit>().loadReviews(reset: true);
    });
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
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<ProviderPageCubit>().loadMoreReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppSimpleHeader(
            title: 'provider_page.reviews'.tr(),
            inlineTitleWithSubtitle: true,
            subtitle: (widget.providerName ?? '').isNotEmpty
                ? widget.providerName
                : null,
          ),
          Expanded(
            child: BlocBuilder<ProviderPageCubit, ProviderPageState>(
              buildWhen: (previous, current) =>
                  previous.reviews != current.reviews ||
                  previous.isReviewsLoading != current.isReviewsLoading ||
                  previous.isReviewsLoadingMore !=
                      current.isReviewsLoadingMore ||
                  previous.reviewsError != current.reviewsError,
              builder: (context, state) {
                if (state.isReviewsLoading && state.reviews.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3872B1)),
                  );
                }
                if (state.reviewsError != null && state.reviews.isEmpty) {
                  return ErrorStateWidget(
                    error: state.reviewsError!,
                    onRetry: () => context
                        .read<ProviderPageCubit>()
                        .loadReviews(reset: true),
                  );
                }
                if (state.reviews.isEmpty) {
                  return Center(
                    child: Text(
                      'provider_page.no_reviews_found'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  itemCount:
                      state.reviews.length +
                      (state.isReviewsLoadingMore ? 1 : 0),
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    if (index >= state.reviews.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3872B1),
                          ),
                        ),
                      );
                    }
                    return ProviderReviewCard(review: state.reviews[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
