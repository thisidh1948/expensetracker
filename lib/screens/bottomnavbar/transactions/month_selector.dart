import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'monthitem.dart';

class MonthSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onMonthSelected;

  const MonthSelector({
    Key? key,
    required this.selectedDate,
    required this.onMonthSelected,
  }) : super(key: key);

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  late ScrollController _scrollController;
  late int centerIndex;
  final itemWidth = 120.0;

  @override
  void initState() {
    super.initState();
    centerIndex = 12;
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCenter();
    });
  }

  void _scrollToCenter() {
    if (!_scrollController.hasClients) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final offset = (centerIndex * itemWidth) - (screenWidth - itemWidth) / 2;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  DateTime _getDateFromIndex(int index) {
    return DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month + (index - centerIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: 25,
            itemBuilder: (context, index) {
              final date = _getDateFromIndex(index);
              final isSelected = date.year == widget.selectedDate.year &&
                  date.month == widget.selectedDate.month;

              return SizedBox(
                width: itemWidth,
                child: MonthItem(
                  date: date,
                  isSelected: isSelected,
                  onTap: () {
                    widget.onMonthSelected(date);
                    centerIndex = index;
                    _scrollToCenter();
                  },
                ),
              );
            },
          ),
          // Left gradient
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          // Right gradient
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
