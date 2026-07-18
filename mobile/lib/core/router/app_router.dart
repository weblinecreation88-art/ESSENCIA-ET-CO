import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../widgets/placeholder_screen.dart";
import "../../features/splash/splash_screen.dart";
import "../../features/home/home_screen.dart";
import "../../features/auth/presentation/welcome_screen.dart";
import "../../features/auth/presentation/login_screen.dart";
import "../../features/auth/presentation/signup_screen.dart";
import "../../features/auth/presentation/role_selection_screen.dart";
import "../../features/profile/profile_screen.dart";

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
      path: "/chat",
      builder: (context, state) => const PlaceholderScreen(
        title: "Messagerie",
        icon: Icons.chat_bubble_rounded,
      ),
    ),
    GoRoute(
      path: "/agenda",
      builder: (context, state) => const PlaceholderScreen(
        title: "Agenda",
        icon: Icons.calendar_today_rounded,
      ),
    ),
    GoRoute(
      path: "/services",
      builder: (context, state) => const PlaceholderScreen(
        title: "Services",
        icon: Icons.design_services_rounded,
      ),
    ),
    GoRoute(
      path: "/booking",
      builder: (context, state) => const PlaceholderScreen(
        title: "Réservation",
        icon: Icons.event_available_rounded,
      ),
    ),
    GoRoute(
      path: "/notifications",
      builder: (context, state) => const PlaceholderScreen(
        title: "Notifications",
        icon: Icons.notifications_rounded,
      ),
    ),
  ],
);
