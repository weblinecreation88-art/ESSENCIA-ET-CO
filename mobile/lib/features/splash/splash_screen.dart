import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:video_player/video_player.dart";

import "../../core/theme/app_colors.dart";
import "../auth/application/auth_providers.dart";

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/logo_reveal.mp4")
      ..setVolume(0);
    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {});
          _controller.play();
          // La navigation se déclenche uniquement sur une durée fixe basée
          // sur la vraie longueur de la vidéo (les évènements "lecture
          // terminée" du plugin sont peu fiables sur le web et coupaient la
          // vidéo trop tôt).
          final duration = _controller.value.duration;
          final waitTime = duration > Duration.zero
              ? duration + const Duration(milliseconds: 300)
              : const Duration(seconds: 10);
          Future.delayed(waitTime, _resolveRoute);
        })
        .catchError((_) {
          _resolveRoute();
        });
    // Filet de sécurité si la vidéo échoue totalement à se charger.
    Future.delayed(const Duration(seconds: 15), _resolveRoute);
  }

  Future<void> _resolveRoute() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      context.go("/welcome");
      return;
    }
    final route = await resolvePostAuthRoute(ref, user.uid);
    if (mounted) context.go(route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
