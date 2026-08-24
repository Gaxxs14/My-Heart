import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HeartAnimationOverlay extends StatelessWidget {
  final String senderName;
  final String pattern; // 'heartbeat', 'rain', 'fireworks', 'kiss'
  final VoidCallback onDismiss;

  const HeartAnimationOverlay({
    super.key,
    required this.senderName,
    this.pattern = 'rain',
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Stack(
            children: [
              // Floating Hearts Particle Rain
              ...List.generate(15, (index) {
                final random = Random(index);
                final left = random.nextDouble() * MediaQuery.of(context).size.width;
                final size = 20.0 + random.nextDouble() * 30;
                final delay = (random.nextDouble() * 400).toInt();

                return Positioned(
                  left: left,
                  bottom: -50,
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Colors.pinkAccent.shade200.withOpacity(0.8),
                    size: size,
                  )
                      .animate()
                      .fadeIn(delay: delay.ms)
                      .moveY(begin: 0, end: -MediaQuery.of(context).size.height * 0.9, duration: 1800.ms, curve: Curves.easeOutQuad)
                      .fadeOut(delay: 1200.ms),
                );
              }),

              // Central Celebration Banner
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFF5E7E),
                        size: 70,
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.25, 1.25),
                          duration: 500.ms,
                        ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '💓 ¡Latido de $senderName! 💓',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF880E4F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pensando en ti en este instante 💕',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
