import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theming/app_text_styles.dart';

// Sample review model for demo purposes
class Review {
  final String userName;
  final String? userImage;
  final double rating;
  final String date;
  final String text;

  Review({
    required this.userName,
    this.userImage,
    required this.rating,
    required this.date,
    required this.text,
  });
}

class ReviewsScreen extends StatefulWidget {
  final String? providerName;

  const ReviewsScreen({
    super.key,
    this.providerName = 'Alfa',
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  // Which star rating is selected (5 by default as per screenshot)
  int? selectedRating;

  // Sample reviews data
  final List<Review> sampleReviews = [
    Review(
      userName: 'Me',
      rating: 5,
      date: '2 weeks ago',
      text: 'من از زمان تحويل و كيفيت كالا كاملا راضى بودم و خريد اين كالا رو به شما پيشنهاد ميكنم.',
    ),
    Review(
      userName: 'Ahmed Mohamed',
      rating: 4,
      date: '2 weeks ago',
      text: 'من از زمان تحويل و كيفيت كالا كاملا راضى بودم و خريد اين كالا رو به شما پيشنهاد ميكنم.',
    ),
    Review(
      userName: 'Ahmed Mohamed',
      rating: 5,
      date: '2 weeks ago',
      text: 'من از زمان تحويل و كيفيت كالا كاملا راضى بودم و خريد اين كالا رو به شما پيشنهاد ميكنم.',
    ),
    Review(
      userName: 'Ahmed Mohamed',
      rating: 3,
      date: '2 weeks ago',
      text: 'من از زمان تحويل و كيفيت كالا كاملا راضى بودم و خريد اين كالا رو به شما پيشنهاد ميكنم.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedRating = 5; // Default selected is 5 stars as per the screenshot
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildBlueHeader(context),
          _buildShareReviewButton(context),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: sampleReviews.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final review = sampleReviews[index];
                return _ReviewCard(review: review);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build the Share your review button
  Widget _buildShareReviewButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(
            'Share your review',
            style: AppTextStyles.of(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3872B1),
            ),
          ),
        ),
      ),
    );
  }

  // Build the top blue header
  Widget _buildBlueHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF3872B1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(height: 16.h),

              // Breadcrumb (Alfa > Reviews)
              Row(
                children: [
                  Text(
                    widget.providerName ?? '',
                    style: AppTextStyles.of(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white70,
                      size: 12.sp,
                    ),
                  ),
                  Text(
                    'Reviews',
                    style: AppTextStyles.of(
                      color: Colors.white70,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Rating summary section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Large rating display on left
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '4.5',
                              style: AppTextStyles.of(
                                fontSize: 48.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.star_rounded,
                              color: const Color(0xFFF5A623),
                              size: 32.sp,
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '653 reviews',
                            style: AppTextStyles.of(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 24.w),

                  // Star rating bars on right
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar(5, 42, () => _selectRating(5)),
                        SizedBox(height: 6.h),
                        _buildRatingBar(4, 12, () => _selectRating(4)),
                        SizedBox(height: 6.h),
                        _buildRatingBar(3, 5, () => _selectRating(3)),
                        SizedBox(height: 6.h),
                        _buildRatingBar(2, 2, () => _selectRating(2)),
                        SizedBox(height: 6.h),
                        _buildRatingBar(1, 1, () => _selectRating(1)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  // Build individual rating bar
  Widget _buildRatingBar(int stars, int count, VoidCallback onTap) {
    final isSelected = selectedRating == stars;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            '$stars',
            style: AppTextStyles.of(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.star_rounded,
            color: isSelected
                ? const Color(0xFFF5A623)
                : Colors.white.withAlpha(100),
            size: 14.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: count / 42, // 42 is max count as per screenshot
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF5A623)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '$count',
            style: AppTextStyles.of(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Handle star rating selection
  void _selectRating(int rating) {
    setState(() {
      selectedRating = rating;
    });
  }
}

// Individual review card widget
class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // User avatar
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                    child: review.userImage != null
                        ? ClipOval(
                            child: Image.network(
                              review.userImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            color: const Color(0xFF64748B),
                            size: 24.sp,
                          ),
                  ),
                  SizedBox(width: 12.w),
                  // User name and stars
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: AppTextStyles.of(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFF5A623),
                            size: 14.sp,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              // More options button
              Icon(
                Icons.more_vert_rounded,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              review.date,
              style: AppTextStyles.of(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            review.text,
            style: AppTextStyles.of(
              fontSize: 14.sp,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
