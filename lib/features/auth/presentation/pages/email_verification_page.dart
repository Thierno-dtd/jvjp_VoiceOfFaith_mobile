import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/email_verification_provider.dart';
import '../../../../core/navigation/app_router.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  final String email;
  final String verificationToken;

  const EmailVerificationPage({
    super.key,
    required this.email,
    required this.verificationToken,
  });

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  bool _isChecking = false;
  bool _canResend = true;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    // Vérifier automatiquement toutes les 3 secondes
    _startAutoCheck();
  }

  void _startAutoCheck() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkVerificationStatus();
        _startAutoCheck();
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final isVerified = await ref
          .read(emailVerificationProvider.notifier)
          .checkEmailVerification();

      if (mounted) {
        if (isVerified) {
          // Email vérifié, naviguer vers la page d'accueil
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email vérifié avec succès ! 🎉'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Attendre un peu pour que l'utilisateur voie le message
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            AppRouter.navigateAndRemoveUntil(context, AppRoutes.home);
          }
        }
      }
    } catch (e) {
      // Ne rien faire, on continue à vérifier
      print('Vérification: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    try {
      await ref
          .read(emailVerificationProvider.notifier)
          .resendVerificationEmail(widget.verificationToken);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de vérification renvoyé !'),
            backgroundColor: Colors.green,
          ),
        );

        // Démarrer le compte à rebours
        _startResendCountdown();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _canResend = true;
          _resendCountdown = 0;
        });
      }
    }
  }

  void _startResendCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        if (_resendCountdown > 0) {
          _startResendCountdown();
        } else {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône email
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E4FE8).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 60,
                  color: Color(0xFF2E4FE8),
                ),
              ),
              const SizedBox(height: 32),

              // Titre
              const Text(
                'Vérifiez votre email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                'Nous avons envoyé un email de vérification à',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E4FE8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Cliquez sur le lien dans l\'email pour activer votre compte.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Indicateur de vérification
              if (_isChecking)
                Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vérification en cours...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Bouton "J'ai vérifié mon email"
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkVerificationStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E4FE8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'J\'ai vérifié mon email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Renvoyer l'email
              TextButton(
                onPressed: _canResend ? _resendVerificationEmail : null,
                child: Text(
                  _canResend
                      ? 'Renvoyer l\'email de vérification'
                      : 'Renvoyer dans ${_resendCountdown}s',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _canResend
                        ? const Color(0xFF2E4FE8)
                        : Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Aide
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFFFC107),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vérifiez aussi votre dossier spam si vous ne voyez pas l\'email.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Retour à la connexion
              TextButton(
                onPressed: () {
                  AppRouter.navigateAndRemoveUntil(
                    context,
                    AppRoutes.login,
                  );
                },
                child: const Text(
                  'Retour à la connexion',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}