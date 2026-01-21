// lib/widgets/nutrition_progress.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

// Circular Progress with Label - for main calorie display
class CircularProgressWithLabel extends StatelessWidget {
  final double current;
  final double goal;
  final String label;
  final Color? color;
  final double size;
  final double strokeWidth;

  const CircularProgressWithLabel({
    super.key,
    required this.current,
    required this.goal,
    required this.label,
    this.color,
    this.size = 180,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (goal - current).clamp(0, goal);
    final isOver = current > goal;
    final progressColor =
        color ?? Theme.of(context).colorScheme.primary;
    final overColor = Colors.red;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(Colors.grey[200]!),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                isOver ? overColor : progressColor,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                current.toInt().toString(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOver ? overColor : null,
                    ),
              ),
              Text(
                'of ${goal.toInt()} $label',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                isOver
                    ? '${(current - goal).toInt()} over'
                    : '${remaining.toInt()} left',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOver ? overColor : progressColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Macro Progress Bar - for protein/carbs/fat display
class MacroProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;
  final String unit;
  final bool showPercentage;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    this.unit = 'g',
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            Text(
              showPercentage
                  ? '$percentage%'
                  : '${current.toStringAsFixed(1)}/${goal.toInt()}$unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// Mini Progress Bar for ProductCard
class MiniMacroBar extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final double? maxValue;

  const MiniMacroBar({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final max = maxValue ?? math.max(math.max(protein, carbs), fat);
    if (max <= 0) return const SizedBox.shrink();

    return Row(
      children: [
        _buildMiniBar(context, 'P', protein, max, Colors.blue),
        const SizedBox(width: 8),
        _buildMiniBar(context, 'C', carbs, max, Colors.orange),
        const SizedBox(width: 8),
        _buildMiniBar(context, 'F', fat, max, Colors.purple),
      ],
    );
  }

  Widget _buildMiniBar(
    BuildContext context,
    String label,
    double value,
    double max,
    Color color,
  ) {
    final progress = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;

    return Expanded(
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Water Intake Widget
class WaterIntakeWidget extends StatelessWidget {
  final double current;
  final double goal;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const WaterIntakeWidget({
    super.key,
    required this.current,
    required this.goal,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final glasses = (current / 250).floor(); // 250ml per glass
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: Colors.blue[400],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Water Intake',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Text(
                  '${current.toInt()}ml / ${goal.toInt()}ml',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.blue[100],
                valueColor: AlwaysStoppedAnimation(Colors.blue[400]!),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Glass indicators
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(8, (index) {
                      final isFilled = index < glasses;
                      return Icon(
                        isFilled ? Icons.local_drink : Icons.local_drink_outlined,
                        size: 24,
                        color: isFilled ? Colors.blue[400] : Colors.grey[300],
                      );
                    }),
                  ),
                ),
                // Control buttons
                Row(
                  children: [
                    IconButton(
                      onPressed: current >= 250 ? onRemove : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.grey[600],
                    ),
                    IconButton(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_circle),
                      color: Colors.blue[400],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
