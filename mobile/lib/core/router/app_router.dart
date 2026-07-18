import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../widgets/placeholder_screen.dart";
import "../../features/splash/splash_screen.dart";
import "../../features/home/home_screen.dart";

final GoRouter appRouter = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(path: "/splash", builder: (context, state) => const SplashScreen()),
    GoRoute(path: "/home", builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: "/profile",
      builder: (context, state) =>
          const PlaceholderScreen(title: "Mon profil", icon: Icons.person_rounded),
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
