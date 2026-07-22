import 'package:flutter/material.dart';

import '../../domain/entities/activity.dart';

class ActivitySelector extends StatelessWidget {
  const ActivitySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Activity selected;
  final ValueChanged<Activity> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Activity>(
      segments: Activity.values
          .map(
            (activity) => ButtonSegment<Activity>(
              value: activity,
              label: Text(activity.label),
            ),
          )
          .toList(),
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
