import 'package:flutter/material.dart';
import '../theme/win95_theme.dart';

class Win95Window extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? titleBarActions;

  const Win95Window({
    super.key,
    required this.title,
    required this.child,
    this.titleBarActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Win95Theme.windowBackground,
        border: Border(
          top: BorderSide(color: Win95Theme.buttonHighlight, width: 2),
          left: BorderSide(color: Win95Theme.buttonHighlight, width: 2),
          right: BorderSide(color: Win95Theme.buttonDarkShadow, width: 2),
          bottom: BorderSide(color: Win95Theme.buttonDarkShadow, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000080), Color(0xFF1084D0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.wysiwyg, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (titleBarActions != null) ...titleBarActions!,
              ],
            ),
          ),
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}

class Win95Button extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isDefault;

  const Win95Button({
    super.key,
    required this.child,
    this.onPressed,
    this.isDefault = false,
  });

  @override
  State<Win95Button> createState() => _Win95ButtonState();
}

class _Win95ButtonState extends State<Win95Button> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: _isPressed ? win95Inset() : win95Raised(),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Win95Theme.buttonText,
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class Win95TextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const Win95TextField({
    super.key,
    this.controller,
    this.hintText,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: win95Inset(),
      padding: const EdgeInsets.all(4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class Win95Checkbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget? label;

  const Win95Checkbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => onChanged?.call(!value),
          child: Container(
            width: 16,
            height: 16,
            decoration: win95Inset(),
            child: value
                ? const Icon(Icons.check, size: 14, color: Colors.black)
                : null,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          label!,
        ],
      ],
    );
  }
}

class Win95Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool inset;

  const Win95Panel({
    super.key,
    required this.child,
    this.padding,
    this.inset = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(8),
      decoration: inset ? win95Inset() : win95Raised(),
      child: child,
    );
  }
}

// Win95 Date Picker
class Win95DatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const Win95DatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<Win95DatePicker> createState() => _Win95DatePickerState();
}

class _Win95DatePickerState extends State<Win95DatePicker> {
  late DateTime _selectedDate;
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_displayMonth.year, _displayMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Dialog(
      backgroundColor: Win95Theme.windowBackground,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(8),
        decoration: win95Raised(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month/Year header
            Win95Panel(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Win95Button(
                    onPressed: () => _changeMonth(-1),
                    child: const Icon(Icons.chevron_left, size: 20),
                  ),
                  Text(
                    '${_getMonthName(_displayMonth.month)} ${_displayMonth.year}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Win95Button(
                    onPressed: () => _changeMonth(1),
                    child: const Icon(Icons.chevron_right, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Day names
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((day) => SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(day,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            // Calendar grid
            Win95Panel(
              inset: true,
              padding: const EdgeInsets.all(4),
              child: SizedBox(
                height: 252,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    final dayNumber = index - startingWeekday + 1;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const SizedBox();
                    }

                    final date = DateTime(
                        _displayMonth.year, _displayMonth.month, dayNumber);
                    final isSelected = date.year == _selectedDate.year &&
                        date.month == _selectedDate.month &&
                        date.day == _selectedDate.day;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: isSelected ? win95Inset() : null,
                        child: Center(
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Win95Button(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                Win95Button(
                  onPressed: () => Navigator.pop(context, _selectedDate),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

// Win95 Time Picker
class Win95TimePicker extends StatefulWidget {
  final TimeOfDay initialTime;

  const Win95TimePicker({
    super.key,
    required this.initialTime,
  });

  @override
  State<Win95TimePicker> createState() => _Win95TimePickerState();
}

class _Win95TimePickerState extends State<Win95TimePicker> {
  late int _hour;
  late int _minute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = (widget.initialTime.minute / 5).round() * 5; // Round to nearest 5

    // Initialize scroll controllers to start at selected values
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute ~/ 5);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12';
    if (hour > 12) return '${hour - 12}';
    return '$hour';
  }

  String _getAmPm(int hour) {
    return hour >= 12 ? 'PM' : 'AM';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Win95Theme.windowBackground,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: win95Raised(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Time',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hour selector
                Column(
                  children: [
                    const Text('Hour', style: TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    Win95Panel(
                      inset: true,
                      padding: EdgeInsets.zero,
                      child: SizedBox(
                        height: 120,
                        width: 60,
                        child: ListWheelScrollView.useDelegate(
                          controller: _hourController,
                          itemExtent: 40,
                          physics: const FixedExtentScrollPhysics(),
                          diameterRatio: 1.5,
                          perspective: 0.003,
                          onSelectedItemChanged: (index) {
                            setState(() => _hour = index % 24);
                          },
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: List.generate(24, (index) {
                              return Center(
                                child: Text(
                                  _formatHour(index),
                                  style: TextStyle(
                                    fontSize: _hour == index ? 20 : 16,
                                    fontWeight: _hour == index
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(':',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                // Minute selector
                Column(
                  children: [
                    const Text('Minute', style: TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    Win95Panel(
                      inset: true,
                      padding: EdgeInsets.zero,
                      child: SizedBox(
                        height: 120,
                        width: 60,
                        child: ListWheelScrollView.useDelegate(
                          controller: _minuteController,
                          itemExtent: 40,
                          physics: const FixedExtentScrollPhysics(),
                          diameterRatio: 1.5,
                          perspective: 0.003,
                          onSelectedItemChanged: (index) {
                            setState(() => _minute = (index % 12) * 5);
                          },
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: List.generate(12, (index) {
                              final minute = index * 5;
                              return Center(
                                child: Text(
                                  minute.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: _minute == minute ? 20 : 16,
                                    fontWeight: _minute == minute
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // AM/PM indicator
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Win95Panel(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        _getAmPm(_hour),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Win95Button(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                Win95Button(
                  onPressed: () => Navigator.pop(
                      context, TimeOfDay(hour: _hour, minute: _minute)),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Win95 Dropdown
class Win95Dropdown<T> extends StatelessWidget {
  final T? value;
  final List<Win95DropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;

  const Win95Dropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null
          ? null
          : () async {
              final result = await showDialog<T>(
                context: context,
                builder: (context) => Win95DropdownDialog<T>(
                  items: items,
                  currentValue: value,
                ),
              );
              if (result != null || items.any((item) => item.value == null)) {
                onChanged?.call(result);
              }
            },
      child: Win95Panel(
        inset: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? (hint ?? '')
                    : items.firstWhere((item) => item.value == value).child,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }
}

class Win95DropdownItem<T> {
  final T? value;
  final String child;

  const Win95DropdownItem({
    required this.value,
    required this.child,
  });
}

class Win95DropdownDialog<T> extends StatelessWidget {
  final List<Win95DropdownItem<T>> items;
  final T? currentValue;

  const Win95DropdownDialog({
    super.key,
    required this.items,
    this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Win95Theme.windowBackground,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 250),
        decoration: win95Raised(),
        child: Win95Panel(
          inset: true,
          padding: EdgeInsets.zero,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item.value == currentValue;
              return GestureDetector(
                onTap: () => Navigator.pop(context, item.value),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  color: isSelected ? Win95Theme.activeTitle : null,
                  child: Text(
                    item.child,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
