import 'package:flutter/material.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import '/models/item_suggestion.dart';
import '/utils/icons/food_icons_map.dart';

/// Widget that displays smart item suggestions in a horizontal scrollable list
class SmartSuggestionsWidget extends StatelessWidget {
  final List<ItemSuggestion> suggestions;
  final Function(ItemSuggestion) onSuggestionTapped;
  final bool isLoading;

  const SmartSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onSuggestionTapped,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.purple[800],
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Smart Suggestions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: CustomLoadingSpinner(),
              ),
            ],
          ),
        ),
      );
    }

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.purple[800],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smart Suggestions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Based on your shopping patterns',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: Colors.purple[800],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return _SuggestionChip(
                    suggestion: suggestion,
                    onTap: () => onSuggestionTapped(suggestion),
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final ItemSuggestion suggestion;
  final VoidCallback onTap;
  final bool isDark;

  const _SuggestionChip({
    required this.suggestion,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isAdded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Fade in "Added" overlay
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _isAdded = true);
    _controller.forward().then((_) {
      widget.onTap();
      // Reset after a delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _isAdded = false);
          _controller.reset();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get icon if available
    Widget? iconWidget;
    if (widget.suggestion.iconIdentifier != null) {
      final foodIcon = FoodIconMap.getIcon(widget.suggestion.iconIdentifier!);
      if (foodIcon != null) {
        iconWidget = foodIcon.buildIcon(
          width: 24,
          height: 24,
          color: Colors.purple[700],
        );
      }
    }

    // Confidence indicator color
    Color confidenceColor;
    if (widget.suggestion.confidence >= 0.7) {
      confidenceColor = Colors.green;
    } else if (widget.suggestion.confidence >= 0.5) {
      confidenceColor = Colors.orange;
    } else {
      confidenceColor = Colors.grey;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 130,
          margin: const EdgeInsets.only(right: 12),
          child: Material(
            color: _isAdded
                ? (widget.isDark ? Colors.green[900] : Colors.green[50])
                : (widget.isDark ? Colors.grey[850] : Colors.white),
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isAdded ? Colors.green[400]! : Colors.purple[200]!,
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Original content - fades out
                    Opacity(
                      opacity: 1.0 - _controller.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon or placeholder
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _isAdded
                                  ? Colors.green[50]
                                  : Colors.purple[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: iconWidget != null
                                ? Center(child: iconWidget)
                                : Center(
                                    child: Icon(
                                      Icons.shopping_bag,
                                      color: Colors.purple[700],
                                      size: 18,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 6),
                          // Item name - capitalized first letter
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                widget.suggestion.name.isEmpty
                                    ? ''
                                    : '${widget.suggestion.name[0].toUpperCase()}${widget.suggestion.name.substring(1)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Confidence indicator
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: confidenceColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.suggestion.frequency}x',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // "Added" overlay with checkmark - fades in
                    if (_isAdded)
                      Opacity(
                        opacity: _fadeAnimation.value,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: widget.isDark
                                    ? Colors.green[400]
                                    : Colors.green[700],
                                size: 40,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Added',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDark
                                      ? Colors.green[300]
                                      : Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
