import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../../stores/auth_store.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late final AuthStore _store;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _store = AuthStore();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final success =
        await _store.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (success && mounted) {
      context.go('/admin/dashboard');
    }
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: Stack(
        children: [
          // Gradiente base
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D1225),
                    Color(0xFF080D1A),
                    Color(0xFF0A0F1E)
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Blobs decorativos
          Positioned(
              top: -100,
              left: -100,
              child: _blob(420, const Color(0xFF915EFF), 0.15)),
          Positioned(
              bottom: -80,
              right: -80,
              child: _blob(380, const Color(0xFF00D4AA), 0.12)),
          Positioned(
              top: 60,
              right: 80,
              child: _blob(240, const Color(0xFF6366F1), 0.08)),
          Positioned(
              bottom: 80,
              left: 60,
              child: _blob(200, const Color(0xFF915EFF), 0.07)),
          // Grid de pontos
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter()),
          ),
          // Linha decorativa superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFF915EFF),
                    Color(0xFF00D4AA),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Card de login
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1224).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF915EFF).withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF915EFF).withValues(alpha: 0.15),
                    blurRadius: 60,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: const Color(0xFF00D4AA).withValues(alpha: 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF915EFF), Color(0xFF00D4AA)],
                    ).createShader(bounds),
                    child: const Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Faça login para acessar o painel',
                    style:
                        TextStyle(color: Color(0xFF8892A4), fontSize: 14),
                  ),
                  const SizedBox(height: 36),
                  Observer(
                    builder: (_) {
                      final error = _store.error.value;
                      if (error == null) return const SizedBox.shrink();
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFFF6B6B)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Color(0xFFFF6B6B), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(error,
                                      style: const TextStyle(
                                          color: Color(0xFFFF6B6B),
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                  _buildField('E-mail', _emailCtrl,
                      Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  Observer(
                    builder: (_) => _buildField(
                      'Senha',
                      _passCtrl,
                      Icons.lock_outline_rounded,
                      obscure: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: const Color(0xFF8892A4),
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Observer(
                    builder: (_) {
                      final loading = _store.loading.value;
                      return SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: loading ? null : _login,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF915EFF),
                                  Color(0xFF00D4AA)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF915EFF)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF8892A4),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFFF3F4F6), fontSize: 14),
          onSubmitted: (_) => _login(),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF8892A4), size: 18),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF080D1A).withValues(alpha: 0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E2D4A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E2D4A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF915EFF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 28.0;
    final paint = Paint()
      ..color = const Color(0xFF915EFF).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
