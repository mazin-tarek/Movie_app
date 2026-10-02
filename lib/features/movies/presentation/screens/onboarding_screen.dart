import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movieapp/core/cubits/splash_cubit.dart';
import 'package:movieapp/core/theme/app_colors.dart';
import 'package:movieapp/core/widgets/custom_button.dart';
import 'package:movieapp/features/onboarding/data/onboarding_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
 const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
   @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLastPage = _currentPage == onboardingItems.length - 1;
    final isFirstPage = _currentPage == 0;
    final isSecondPage = _currentPage == 1;
    final currentItem = onboardingItems[_currentPage];

    return Scaffold(
      body: Stack(
        children: [
          // الصور (قابلة للسحب)
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _OnboardingPageContent(item: onboardingItems[index]);
            },
          ),

          // الصفحة الأولى: من غير كارت، النص حاط على التدريج بتاع الصورة نفسه
          if (isFirstPage)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  size.height * 0.05,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      currentItem.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentItem.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Explore Now',
                      onPressed: _onNextPressed,
                    ),
                  ],
                ),
              ),
            )
          else
            // الكارت السفلي (النصوص + النقط + الأزرار) - لباقي الصفحات
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // العنوان
                    Text(
                      currentItem.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // الوصف
                    Text(
                      currentItem.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // النقط
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingItems.length,
                        (index) => _buildDot(isActive: index == _currentPage),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // زرار Next / Finish
                    CustomButton(
                      text: isLastPage ? 'Finish' : 'Next',
                      onPressed: _onNextPressed,
                    ),

                    // زرار Back (في كل الصفحات ما عدا الأولى والتانية)
                    if (!isSecondPage) ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Back',
                        isOutlined: true,
                        onPressed: _onBackPressed,
                      ),
                    ],

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

    Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryButton : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
    Future<void> _onNextPressed() async {
    final isLastPage = _currentPage == onboardingItems.length - 1;

    if (isLastPage) {
      // آخر صفحة: نحفظ إن المستخدم خلّص الأونبوردنج، ونروح Login
      await _finishOnboarding();
    } else {
      // مش آخر صفحة: نروح للصفحة اللي بعدها
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
    void _onBackPressed() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

    Future<void> _finishOnboarding() async {
    // نحفظ إن المستخدم شاف الأونبوردنج (عشان ما يظهرش تاني)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingSeenKey, true);

    // نروح Login (mounted check مهم بعد await)
    if (mounted) {
      context.go('/login');
    }
  }
}

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingItem item;
  const _OnboardingPageContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // الصورة (خلفية تملأ الشاشة)
        Image.asset(
          item.image,
          fit: BoxFit.cover,
        ),

        // الطبقة الشفافة (gradient)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black87,
                Colors.black,
              ],
              stops: [0.3, 0.75, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}