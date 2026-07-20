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
import "../../features/services/presentation/provider_bookings_screen.dart";
import "../../features/services/domain/service_category.dart";
import "../../features/notifications/presentation/notifications_screen.dart";
import "../../features/photos/presentation/photos_screen.dart";
import "../../features/feedback/presentation/staff_screen.dart";
import "../../features/feedback/presentation/staff_feedback_screen.dart";
import "../../features/feedback/presentation/admin_staff_screen.dart";
import "../../features/feedback/presentation/admin_dashboard_screen.dart";
import "../../features/satisfaction/presentation/satisfaction_screen.dart";
import "../../features/satisfaction/presentation/admin_satisfaction_screen.dart";
import "../../features/guardian/presentation/guardian_wards_screen.dart";
import "../../features/guardian/presentation/guardian_dossier_screen.dart";
import "../../features/second_life/presentation/second_life_screen.dart";
import "../../features/second_life/presentation/create_listing_screen.dart";
import "../../features/journal/presentation/journal_screen.dart";
import "../../features/journal/presentation/journal_detail_screen.dart";

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
      path: "/provider/bookings",
      builder: (context, state) => const ProviderBookingsScreen(),
    ),
    GoRoute(
      path: "/notifications",
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: "/photos",
      builder: (context, state) => const PhotosScreen(),
    ),
    GoRoute(
      path: "/staff",
      builder: (context, state) => const StaffScreen(),
    ),
    GoRoute(
      path: "/staff/feedback",
      builder: (context, state) {
        final params = state.uri.queryParameters;
        return StaffFeedbackScreen(
          staffId: params["staffId"]!,
          staffName: params["staffName"]!,
        );
      },
    ),
    GoRoute(
      path: "/admin",
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: "/admin/staff",
      builder: (context, state) => const AdminStaffScreen(),
    ),
    GoRoute(
      path: "/admin/satisfaction",
      builder: (context, state) => const AdminSatisfactionScreen(),
    ),
    GoRoute(
      path: "/satisfaction",
      builder: (context, state) => const SatisfactionScreen(),
    ),
    GoRoute(
      path: "/guardian",
      builder: (context, state) => const GuardianWardsScreen(),
    ),
    GoRoute(
      path: "/guardian/dossier",
      builder: (context, state) {
        final params = state.uri.queryParameters;
        return GuardianDossierScreen(
          residentId: params["residentId"]!,
          residentName: params["residentName"]!,
        );
      },
    ),
    GoRoute(
      path: "/second-life",
      builder: (context, state) => const SecondLifeScreen(),
    ),
    GoRoute(
      path: "/second-life/new",
      builder: (context, state) => const CreateListingScreen(),
    ),
    GoRoute(
      path: "/journal",
      builder: (context, state) => const JournalScreen(),
    ),
    GoRoute(
      path: "/journal/detail",
      builder: (context, state) {
        final params = state.uri.queryParameters;
        return JournalDetailScreen(
          residentId: params["residentId"]!,
          title: params["title"]!,
        );
      },
    ),
  ],
);
