import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/themes/app_themes.dart';

/// Custom search widget with theming and debouncing
class CustomSearchWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;
  final Duration debounceTime;
  final List<String>? suggestions;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showClearButton;
  final EdgeInsets padding;
  final TextInputType keyboardType;

  const CustomSearchWidget({
    Key? key,
    this.hintText = 'Qidirish...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.controller,
    this.autofocus = false,
    this.debounceTime = const Duration(milliseconds: 300),
    this.suggestions,
    this.leading,
    this.actions,
    this.showClearButton = true,
    this.padding = const EdgeInsets.all(16),
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<CustomSearchWidget> createState() => _CustomSearchWidgetState();
}

class _CustomSearchWidgetState extends State<CustomSearchWidget> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceTime, () {
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text);
      }
    });

    setState(() {
      _showSuggestions = _controller.text.isNotEmpty &&
          widget.suggestions != null &&
          widget.suggestions!.isNotEmpty;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus &&
          _controller.text.isNotEmpty &&
          widget.suggestions != null &&
          widget.suggestions!.isNotEmpty;
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focusNode.hasFocus ? colors.info : colors.border,
              ),
              boxShadow: _focusNode.hasFocus ? [
                BoxShadow(
                  color: colors.info.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                // Leading widget or default search icon
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: widget.leading ?? Icon(
                    Icons.search,
                    color: colors.secondaryText,
                    size: 20,
                  ),
                ),

                // Search input field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    keyboardType: widget.keyboardType,
                    style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: widget.onSubmitted,
                    textInputAction: TextInputAction.search,
                  ),
                ),

                // Clear button
                if (widget.showClearButton && _controller.text.isNotEmpty)
                  IconButton(
                    onPressed: _clearSearch,
                    icon: Icon(
                      Icons.clear,
                      color: colors.secondaryText,
                      size: 20,
                    ),
                    tooltip: 'Tozalash',
                  ),

                // Action buttons
                if (widget.actions != null) ...widget.actions!,
              ],
            ),
          ),

          // Suggestions dropdown
          if (_showSuggestions) ...[
            const SizedBox(height: 8),
            _buildSuggestionsDropdown(colors),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionsDropdown(AppThemeColors colors) {
    final filteredSuggestions = widget.suggestions!
        .where((suggestion) => suggestion
        .toLowerCase()
        .contains(_controller.text.toLowerCase()))
        .take(5)
        .toList();

    if (filteredSuggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: filteredSuggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: colors.divider,
        ),
        itemBuilder: (context, index) {
          final suggestion = filteredSuggestions[index];
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.history,
              color: colors.secondaryText,
              size: 18,
            ),
            title: Text(
              suggestion,
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 14,
              ),
            ),
            onTap: () {
              _controller.text = suggestion;
              widget.onSubmitted?.call(suggestion);
              setState(() {
                _showSuggestions = false;
              });
              _focusNode.unfocus();
            },
          );
        },
      ),
    );
  }
}

/// Compact search bar for app bars
class CompactSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClosed;
  final TextEditingController? controller;
  final bool autofocus;

  const CompactSearchBar({
    Key? key,
    this.hintText = 'Qidirish...',
    this.onChanged,
    this.onSubmitted,
    this.onClosed,
    this.controller,
    this.autofocus = true,
  }) : super(key: key);

  @override
  State<CompactSearchBar> createState() => _CompactSearchBarState();
}

class _CompactSearchBarState extends State<CompactSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search,
            color: colors.secondaryText,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
              },
              icon: Icon(
                Icons.clear,
                color: colors.secondaryText,
                size: 18,
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// Search filter chips
class SearchFilterChips extends StatefulWidget {
  final List<SearchFilter> filters;
  final ValueChanged<List<SearchFilter>>? onFiltersChanged;
  final EdgeInsets padding;
  final bool isScrollable;

  const SearchFilterChips({
    Key? key,
    required this.filters,
    this.onFiltersChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.isScrollable = true,
  }) : super(key: key);

  @override
  State<SearchFilterChips> createState() => _SearchFilterChipsState();
}

class _SearchFilterChipsState extends State<SearchFilterChips> {
  late List<SearchFilter> _filters;

  @override
  void initState() {
    super.initState();
    _filters = List.from(widget.filters);
  }

  @override
  void didUpdateWidget(SearchFilterChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filters != oldWidget.filters) {
      _filters = List.from(widget.filters);
    }
  }

  void _toggleFilter(int index) {
    setState(() {
      _filters[index] = _filters[index].copyWith(
        isSelected: !_filters[index].isSelected,
      );
    });
    widget.onFiltersChanged?.call(_filters);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget content = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _filters.asMap().entries.map((entry) {
        final index = entry.key;
        final filter = entry.value;

        return FilterChip(
          label: Text(filter.label),
          selected: filter.isSelected,
          onSelected: (_) => _toggleFilter(index),
          backgroundColor: colors.cardBackground,
          selectedColor: colors.info.withOpacity(0.2),
          checkmarkColor: colors.info,
          labelStyle: TextStyle(
            color: filter.isSelected ? colors.info : colors.primaryText,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: filter.isSelected ? colors.info : colors.border,
            ),
          ),
        );
      }).toList(),
    );

    if (widget.isScrollable) {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;

            return Padding(
              padding: EdgeInsets.only(right: index < _filters.length - 1 ? 8 : 0),
              child: FilterChip(
                label: Text(filter.label),
                selected: filter.isSelected,
                onSelected: (_) => _toggleFilter(index),
                backgroundColor: colors.cardBackground,
                selectedColor: colors.info.withOpacity(0.2),
                checkmarkColor: colors.info,
                labelStyle: TextStyle(
                  color: filter.isSelected ? colors.info : colors.primaryText,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: filter.isSelected ? colors.info : colors.border,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Padding(
      padding: widget.padding,
      child: content,
    );
  }
}

/// Search filter model
class SearchFilter {
  final String label;
  final String value;
  final bool isSelected;
  final IconData? icon;

  const SearchFilter({
    required this.label,
    required this.value,
    this.isSelected = false,
    this.icon,
  });

  SearchFilter copyWith({
    String? label,
    String? value,
    bool? isSelected,
    IconData? icon,
  }) {
    return SearchFilter(
      label: label ?? this.label,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
      icon: icon ?? this.icon,
    );
  }
}

/// Search results widget
class SearchResultsWidget<T> extends StatelessWidget {
  final List<T> results;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final String? emptyMessage;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final ScrollController? scrollController;

  const SearchResultsWidget({
    Key? key,
    required this.results,
    required this.itemBuilder,
    this.emptyMessage,
    this.isLoading = false,
    this.onLoadMore,
    this.hasMore = false,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isLoading && results.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  fontSize: 16,
                  color: colors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: results.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length) {
          // Load more indicator
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : TextButton(
                onPressed: onLoadMore,
                child: const Text('Ko\'proq yuklash'),
              ),
            ),
          );
        }

        return itemBuilder(context, results[index], index);
      },
    );
  }
}

/// Advanced search dialog
class AdvancedSearchDialog extends StatefulWidget {
  final List<SearchField> fields;
  final Map<String, dynamic>? initialValues;
  final ValueChanged<Map<String, dynamic>>? onSearch;

  const AdvancedSearchDialog({
    Key? key,
    required this.fields,
    this.initialValues,
    this.onSearch,
  }) : super(key: key);

  @override
  State<AdvancedSearchDialog> createState() => _AdvancedSearchDialogState();
}

class _AdvancedSearchDialogState extends State<AdvancedSearchDialog> {
  late Map<String, dynamic> _values;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _values = Map.from(widget.initialValues ?? {});

    for (final field in widget.fields) {
      if (field.type == SearchFieldType.text) {
        _controllers[field.key] = TextEditingController(
          text: _values[field.key]?.toString() ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSearch() {
    for (final entry in _controllers.entries) {
      _values[entry.key] = entry.value.text;
    }
    widget.onSearch?.call(_values);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      title: const Text('Qo\'shimcha qidiruv'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields.map((field) => _buildField(field, colors)).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: _handleSearch,
          child: const Text('Qidirish'),
        ),
      ],
    );
  }

  Widget _buildField(SearchField field, AppThemeColors colors) {
    switch (field.type) {
      case SearchFieldType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextField(
            controller: _controllers[field.key],
            decoration: InputDecoration(
              labelText: field.label,
              hintText: field.hint,
              border: const OutlineInputBorder(),
            ),
          ),
        );

      case SearchFieldType.dropdown:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            value: _values[field.key],
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            items: field.options?.map((option) {
              return DropdownMenuItem<String>(
                value: option.value,
                child: Text(option.label),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _values[field.key] = value;
              });
            },
          ),
        );

      case SearchFieldType.dateRange:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _values['${field.key}_start'] = date;
                      });
                    }
                  },
                  child: Text(
                    _values['${field.key}_start'] != null
                        ? _formatDate(_values['${field.key}_start'])
                        : 'Boshlanish sanasi',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _values['${field.key}_end'] = date;
                      });
                    }
                  },
                  child: Text(
                    _values['${field.key}_end'] != null
                        ? _formatDate(_values['${field.key}_end'])
                        : 'Tugash sanasi',
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}

/// Search field model
class SearchField {
  final String key;
  final String label;
  final String? hint;
  final SearchFieldType type;
  final List<SearchOption>? options;

  const SearchField({
    required this.key,
    required this.label,
    this.hint,
    required this.type,
    this.options,
  });
}

/// Search field types
enum SearchFieldType {
  text,
  dropdown,
  dateRange,
}

/// Search option model
class SearchOption {
  final String label;
  final String value;

  const SearchOption({
    required this.label,
    required this.value,
  });
}

/// Predefined search configurations
class SearchConfigurations {
  /// Student search filters
  static List<SearchFilter> studentFilters = [
    const SearchFilter(label: 'Vazifalar', value: 'homework'),
    const SearchFilter(label: 'Imtihonlar', value: 'exams'),
    const SearchFilter(label: 'Baholar', value: 'grades'),
    const SearchFilter(label: 'Davomat', value: 'attendance'),
  ];

  /// Teacher search filters
  static List<SearchFilter> teacherFilters = [
    const SearchFilter(label: 'Talabalar', value: 'students'),
    const SearchFilter(label: 'Vazifalar', value: 'homework'),
    const SearchFilter(label: 'Imtihonlar', value: 'exams'),
    const SearchFilter(label: 'Guruhlar', value: 'groups'),
  ];

  /// Parent search filters
  static List<SearchFilter> parentFilters = [
    const SearchFilter(label: 'Bolalarim', value: 'children'),
    const SearchFilter(label: 'Baholar', value: 'grades'),
    const SearchFilter(label: 'To\'lovlar', value: 'payments'),
    const SearchFilter(label: 'Hisobotlar', value: 'reports'),
  ];

  /// Advanced search fields for students
  static List<SearchField> studentSearchFields = [
    const SearchField(
      key: 'subject',
      label: 'Fan',
      type: SearchFieldType.dropdown,
      options: [
        SearchOption(label: 'Matematika', value: 'math'),
        SearchOption(label: 'Fizika', value: 'physics'),
        SearchOption(label: 'Ingliz tili', value: 'english'),
      ],
    ),
    const SearchField(
      key: 'grade_range',
      label: 'Baho oralig\'i',
      type: SearchFieldType.text,
      hint: 'Masalan: 80-100',
    ),
    const SearchField(
      key: 'date_range',
      label: 'Sana oralig\'i',
      type: SearchFieldType.dateRange,
    ),
  ];
}