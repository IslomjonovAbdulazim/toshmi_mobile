import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_themes.dart';

/// Custom search bar widget with enhanced features
class CustomSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<String>? suggestions;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const CustomSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.controller,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.suggestions,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12.0,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.textStyle,
    this.hintStyle,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateClearButton);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _updateClearButton() {
    final showClear = _controller.text.isNotEmpty;
    if (showClear != _showClearButton) {
      setState(() {
        _showClearButton = showClear;
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colors.cardBackground,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor ?? colors.secondaryText.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        style: widget.textStyle ?? TextStyle(
          color: colors.primaryText,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Qidirish...',
          hintStyle: widget.hintStyle ?? TextStyle(
            color: colors.secondaryText,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: widget.contentPadding,
          prefixIcon: widget.prefixIcon ?? Icon(
            Icons.search,
            color: colors.secondaryText,
          ),
          suffixIcon: widget.suffixIcon ?? (_showClearButton
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: colors.secondaryText,
            ),
            onPressed: _clearSearch,
          )
              : null),
        ),
      ),
    );
  }
}

/// Search bar with suggestions dropdown
class SearchBarWithSuggestions extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onSuggestionSelected;
  final TextEditingController? controller;
  final List<String> suggestions;
  final int maxSuggestions;
  final bool showSuggestionsOnFocus;
  final Widget Function(String suggestion)? suggestionBuilder;

  const SearchBarWithSuggestions({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onSuggestionSelected,
    this.controller,
    required this.suggestions,
    this.maxSuggestions = 5,
    this.showSuggestionsOnFocus = false,
    this.suggestionBuilder,
  });

  @override
  State<SearchBarWithSuggestions> createState() => _SearchBarWithSuggestionsState();
}

class _SearchBarWithSuggestionsState extends State<SearchBarWithSuggestions> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _controller.text.toLowerCase();

    if (query.isEmpty) {
      if (widget.showSuggestionsOnFocus && _focusNode.hasFocus) {
        _updateSuggestions(widget.suggestions);
      } else {
        _removeOverlay();
      }
    } else {
      final filtered = widget.suggestions
          .where((suggestion) => suggestion.toLowerCase().contains(query))
          .take(widget.maxSuggestions)
          .toList();
      _updateSuggestions(filtered);
    }

    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (widget.showSuggestionsOnFocus || _controller.text.isNotEmpty) {
        _onTextChanged();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 150), () {
        _removeOverlay();
      });
    }
  }

  void _updateSuggestions(List<String> suggestions) {
    _filteredSuggestions = suggestions;

    if (suggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildSuggestionOverlay(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSuggestionOverlay() {
    final colors = context.colors;

    return Positioned(
      width: context.width - 32, // Account for padding
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 60),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: colors.cardBackground,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return widget.suggestionBuilder?.call(suggestion) ??
                    _buildDefaultSuggestionTile(suggestion, colors);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultSuggestionTile(String suggestion, AppThemeColors colors) {
    return ListTile(
      dense: true,
      title: Text(
        suggestion,
        style: TextStyle(color: colors.primaryText),
      ),
      leading: Icon(
        Icons.search,
        color: colors.secondaryText,
        size: 20,
      ),
      onTap: () {
        _controller.text = suggestion;
        _removeOverlay();
        _focusNode.unfocus();
        widget.onSuggestionSelected?.call(suggestion);
        widget.onSubmitted?.call(suggestion);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomSearchBar(
        controller: _controller,
        // focusNode: _focusNode,
        hintText: widget.hintText,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}

/// Expandable search bar
class ExpandableSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClosed;
  final TextEditingController? controller;
  final IconData? searchIcon;
  final IconData? closeIcon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Duration animationDuration;

  const ExpandableSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClosed,
    this.controller,
    this.searchIcon,
    this.closeIcon,
    this.backgroundColor,
    this.iconColor,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
      Future.delayed(widget.animationDuration, () {
        _focusNode.requestFocus();
      });
    } else {
      _animationController.reverse();
      _focusNode.unfocus();
      _controller.clear();
      widget.onClosed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _isExpanded ? double.infinity : 48,
          height: 48,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? colors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.secondaryText.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _isExpanded
                      ? (widget.closeIcon ?? Icons.arrow_back)
                      : (widget.searchIcon ?? Icons.search),
                  color: widget.iconColor ?? colors.primaryText,
                ),
                onPressed: _toggleSearch,
              ),
              if (_isExpanded)
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: TextStyle(color: colors.primaryText),
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? 'Qidirish...',
                      hintStyle: TextStyle(color: colors.secondaryText),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Search results widget
class SearchResultsWidget<T> extends StatelessWidget {
  final String query;
  final List<T> results;
  final Widget Function(T item) itemBuilder;
  final VoidCallback? onClearSearch;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final bool isLoading;
  final String? emptyMessage;

  const SearchResultsWidget({
    super.key,
    required this.query,
    required this.results,
    required this.itemBuilder,
    this.onClearSearch,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isLoading) {
      return loadingWidget ?? const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (results.isEmpty) {
      return emptyWidget ?? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colors.secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'Qidiruv natijalari topilmadi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '"$query" bo\'yicha hech narsa topilmadi',
              style: TextStyle(
                color: colors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            if (onClearSearch != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onClearSearch,
                child: const Text('Qidiruvni tozalash'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => itemBuilder(results[index]),
    );
  }
}

/// Search filter chip
class SearchFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final Color? selectedColor;
  final Color? backgroundColor;

  const SearchFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onSelected,
    this.selectedColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected != null ? (_) => onSelected!() : null,
      selectedColor: selectedColor ?? colors.info.withOpacity(0.2),
      backgroundColor: backgroundColor ?? colors.cardBackground,
      checkmarkColor: colors.info,
      labelStyle: TextStyle(
        color: isSelected ? colors.info : colors.primaryText,
      ),
      side: BorderSide(
        color: isSelected ? colors.info : colors.secondaryText.withOpacity(0.2),
      ),
    );
  }
}