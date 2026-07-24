import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../core/theme/app_colors.dart";
import "../application/voice_assistant_controller.dart";
import "../application/voice_assistant_state.dart";
import "voice_assistant_intro_dialog.dart";
import "voice_confirmation_sheet.dart";

/// Bouton micro flottant "SENSI", point d'entrée de l'assistant vocal.
/// Placé pour l'instant uniquement sur l'écran d'accueil.
class VoiceAssistantButton extends ConsumerStatefulWidget {
  const VoiceAssistantButton({super.key});

  @override
  ConsumerState<VoiceAssistantButton> createState() =>
      _VoiceAssistantButtonState();
}

class _VoiceAssistantButtonState extends ConsumerState<VoiceAssistantButton> {
  late final VoiceAssistantController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VoiceAssistantController(ref)..addListener(_onStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) maybeShowSensiIntro(context, ref);
    });
  }

  void _onStateChanged() {
    if (!mounted) return;
    final state = _controller.state;

    if (state.status == VoiceAssistantStatus.confirming &&
        state.confirmationText != null) {
      showVoiceConfirmationSheet(
        context,
        message: state.confirmationText!,
        onConfirm: _controller.confirmPendingAction,
        onCancel: _controller.cancelPendingAction,
      );
    } else if (state.navigateTo != null) {
      final route = state.navigateTo!;
      _controller.consumeNavigation();
      context.push(route);
    }

    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final isBusy = state.status != VoiceAssistantStatus.idle;
    final icon = switch (state.status) {
      VoiceAssistantStatus.listening => Icons.graphic_eq_rounded,
      VoiceAssistantStatus.processing => Icons.hourglass_top_rounded,
      VoiceAssistantStatus.speaking => Icons.volume_up_rounded,
      VoiceAssistantStatus.confirming => Icons.mic_rounded,
      VoiceAssistantStatus.idle => Icons.mic_none_rounded,
    };

    return Tooltip(
      message: "SENSI, votre assistant vocal",
      child: FloatingActionButton(
        heroTag: "sensi_voice_assistant",
        backgroundColor: isBusy ? AppColors.secondary : AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: isBusy ? _controller.cancel : _controller.startListening,
        child: Icon(icon),
      ),
    );
  }
}
