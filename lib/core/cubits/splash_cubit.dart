import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movieapp/core/cubits/splash_state.dart';
import 'package:movieapp/features/auth/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String onboardingSeenKey = 'onboarding_seen';


class SplashCubit extends Cubit<SplashState> {
    final AuthRepository _authRepository;

SplashCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(SplashInitial());

        Future <void> decideNavigation() async {
         await Future.delayed(const Duration(seconds: 2));
             final currentUser = _authRepository.getCurrentUser();

             // A signed-in user should always be able to continue to the app,
             // even if the local onboarding flag was lost or reset.
             if (currentUser != null) {
               emit(SplashNavigateToHome());
               return;
             }

             final prefs = await SharedPreferences.getInstance();
             final hasSeenOnboarding =
                 prefs.getBool(onboardingSeenKey) ?? false;

             if (!hasSeenOnboarding) {
               emit(SplashNavigateToOnboarding());
               return;
             }

             emit(SplashNavigateToLogin());





        }
    


}