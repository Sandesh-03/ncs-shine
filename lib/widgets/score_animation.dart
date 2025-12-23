// lib/presentation/animations/score_animation.dart
import 'package:flutter/material.dart';

class AnimatedLeaderboardItem extends StatelessWidget {
  final AnimationController animationController;
  final int delay;
  final int rank;
  final String userName;
  final int points;
  final bool isTopThree;

  const AnimatedLeaderboardItem({
    Key? key,
    required this.animationController,
    required this.delay,
    required this.rank,
    required this.userName,
    required this.points,
    required this.isTopThree,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          delay / 1000,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 20),
            child: child,
          ),
        );
      },
      child: _buildListItem(context),
    );
  }

  Widget _buildListItem(BuildContext context) {
    Color? rankColor;
    IconData? rankIcon;

    if (rank == 1) {
      rankColor = Colors.amber;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey;
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = Colors.brown;
      rankIcon = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isTopThree ? rankColor?.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (isTopThree)
            BoxShadow(
              color: rankColor!.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rankColor,
          child: rankIcon != null
              ? Icon(rankIcon, color: Colors.white)
              : Text(
                  rank.toString(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: NumberAnimatedCounter(
          value: points,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: rankColor ?? Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class NumberAnimatedCounter extends ImplicitlyAnimatedWidget {
  final int value;
  final TextStyle style;

  const NumberAnimatedCounter({
    Key? key,
    required this.value,
    required this.style,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOut,
  }) : super(key: key, duration: duration, curve: curve);

  @override
  ImplicitlyAnimatedWidgetState<NumberAnimatedCounter> createState() =>
      _NumberAnimatedCounterState();
}

class _NumberAnimatedCounterState
    extends AnimatedWidgetBaseState<NumberAnimatedCounter> {
  IntTween? _valueTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _valueTween = visitor(
      _valueTween,
      widget.value,
      (dynamic value) => IntTween(begin: value as int),
    ) as IntTween?;
  }

  @override
  Widget build(BuildContext context) {
    final value = _valueTween?.evaluate(animation) ?? 0;
    return Text(
      value.toString(),
      style: widget.style,
    );
  }
}
