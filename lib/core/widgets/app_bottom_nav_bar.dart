import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movieapp/core/constants/app_assets.dart';
import 'package:movieapp/core/theme/app_colors.dart';
import 'package:movieapp/l10n/app_localizations.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: MediaQuery.sizeOf(context).width * 0.80,
      height: 70,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF282A28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF282A28),
          elevation: 0,
          selectedItemColor: AppColors.primaryButton,
          unselectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 30,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppAssets.homeTab,
                width: 30,
                height: 30,
              ),
              activeIcon: SvgPicture.asset(
                AppAssets.homeTab,
                width: 30,
                height: 30,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryButton,
                  BlendMode.srcIn,
                ),
              ),
              label: l10n.home,
            ),

            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppAssets.searchTab,
                width: 30,
                height: 30,
              ),
              activeIcon: SvgPicture.asset(
                AppAssets.searchTab,
                width: 30,
                height: 30,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryButton,
                  BlendMode.srcIn,
                ),
              ),
              label: l10n.search,
            ),

            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppAssets.browseTab,
                width: 30,
                height: 30,
              ),
              activeIcon: SvgPicture.asset(
                AppAssets.browseTab,
                width: 30,
                height: 30,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryButton,
                  BlendMode.srcIn,
                ),
              ),
              label: l10n.browse,
            ),

            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppAssets.profileTab,
                width: 30,
                height: 30,
              ),
              activeIcon: SvgPicture.asset(
                AppAssets.profileTab,
                width: 30,
                height: 30,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryButton,
                  BlendMode.srcIn,
                ),
              ),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}