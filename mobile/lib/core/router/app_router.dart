import "package:go_router/go_router.dart";

import "../../features/splash/splash_screen.dart";
import "../../features/home/home_screen.dart";
import "../../features/auth/presentation/welcome_screen.dart";
import "../../features/auth/presentation/login_screen.dart";
import "../../features/auth/presentation/signup_screen.dart";
import "../../features/auth/presentation/role_selection_screen.dart";
import "../../features/profile/profile_screen.dart";
import "../../features/profile/family_screen.dart";
import "../../features/profile/preferences_screen.dart";
import "../../features/profile/settings_screen.dart";
import "../../features/profile/help_screen.dart";
import "../../features/chat/presentation/conversations_screen.dart";
import "../../features/chat/presentation/new_conversation_screen.dart";
import "../../features/chat/presentation/chat_screen.dart";
import "../../features/agenda/presentation/agenda_screen.dart";
import "../../features/services/presentation/services_screen.dart";
import "../../features/services/presentation/providers_screen.dart";
import "../../features/services/presentation/booking_screen.dart";
import "../../features/services/domain/service_category.dart";
import "../../features/notifications/presentation/notifications_screen.dart";
import "../../features/photos/presentation/photos_screen.dart";

final GoRouter appRouter = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(path: "/splash", builder: (context, state) => const SplashScreen()),
    GoRoute(path: "/welcome", builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
    GoRoute(path: "/signup", builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: "/role-selection",
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(path: "/home", builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: "/profile",
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: "/profile/family",
      builder: (context, state) => const FamilyScreen(),
    ),
    GoRoute(
      path: "/profile/preferences",
      builder: (context, state) => const PreferencesScreen(),
    ),
    GoRoute(
      path: "/profile/settings",
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: "/profile/help",
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: "/chat",
      builder: (context, state) => const ConversationsScreen(),
    ),
    GoRoute(
      path: "/chat/new",
      builder: (context, state) => const NewConversationScreen(),
    ),
    GoRoute(
      path: "/chat/:chatId",
      builder: (context, state) =>
          ChatScreen(chatId: state.pathParameters["chatId"]!),
    ),
    GoRoute(
      path: "/agenda",
      builder: (context, state) => const AgendaScreen(),
    ),
    GoRoute(
      path: "/services",
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: "/services/:category",
      builder: (context, state) => ProvidersScreen(
        category: ServiceCategory.fromStorage(
          state.pathParameters["category"]!,
        ),
      ),
    ),
    GoRoute(
      path: "/booking",
      builder: (context, state) {
        final params = state.uri.queryParameters;
        return BookingScreen(
          providerId: params["providerId"]!,
          providerName: params["providerName"]!,
          category: ServiceCategory.fromStorage(params["category"]!),
        );
      },
    ),
    GoRoute(
      path: "/notifications",
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: "/photos",
      builder: (context, state) => const PhotosScreen(),
    ),
  ],
);
