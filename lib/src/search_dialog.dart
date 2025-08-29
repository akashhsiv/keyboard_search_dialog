import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchDialog<T> extends StatefulWidget {
  final Iterable<T> options;
  final String Function(T) displayStringForOption;
  final String initialText;
  final double? height;
  final FocusNode? nextFocus;
  final FocusNode? nextFocusNode;
  final Color? backgroundColor;
  final Color? highlightedTileColor;
  final TextStyle? dialogTextFieldStyle;
  final Color? dialogTextFieldCursor;
  final InputDecoration? searchFieldDecoration;
  final Widget? closeButtonIcon;
  final Color? closeButtonColor;
  final VoidCallback? onClosed;
  final ShapeBorder? dialogShape;
  final double? maxWidth;
  final double? maxHeightFactor;
  final double? optionItemHeight;
  final String? noResultsText;
  final TextStyle? noResultsTextStyle;
  final WidgetBuilder? noResultsBuilder;
  final Widget Function(BuildContext, T, bool isHighlighted)? optionBuilder;
  final ValueChanged<T>? onSelected;

  const SearchDialog({super.key, 
    required this.options,
    required this.displayStringForOption,
    required this.initialText,
    this.nextFocus,
    this.nextFocusNode,
    this.height,
    this.backgroundColor,
    this.dialogTextFieldCursor,
    this.dialogTextFieldStyle,
    this.highlightedTileColor,
    this.searchFieldDecoration,
    this.closeButtonColor,
    this.closeButtonIcon,
    this.dialogShape,
    this.maxHeightFactor,
    this.maxWidth,
    this.noResultsBuilder,
    this.noResultsText,
    this.noResultsTextStyle,
    this.onClosed,
    this.onSelected,
    this.optionBuilder,
    this.optionItemHeight,
  });

  @override
  State<SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<SearchDialog<T>> {
  late TextEditingController _controller;
  late List<T> _filteredOptions;
  int _highlightedIndex = -1;
  final ScrollController _scrollController = ScrollController();

  final FocusNode _dialogFocusNode = FocusNode();
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _filteredOptions = _filterOptions(widget.initialText);
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_textFieldFocusNode);
      }
    });
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        _filteredOptions = _filterOptions(_controller.text);
        _highlightedIndex = -1;
      });
    }
  }

  List<T> _filterOptions(String text) {
    return widget.options
        .where(
          (o) => widget
              .displayStringForOption(o)
              .toLowerCase()
              .contains(text.toLowerCase()),
        )
        .toList();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.escape) {
      _closeDialog();
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_wasClosedManually) {
        return;
      }

      if (_filteredOptions.isNotEmpty &&
          _highlightedIndex >= 0 &&
          _highlightedIndex < _filteredOptions.length) {
        _closeDialog(_filteredOptions[_highlightedIndex]);
      } else {
        // No selection, close with null
        _closeDialog();
      }
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (_filteredOptions.isEmpty) return;
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1) % _filteredOptions.length;
        _scrollToHighlighted();
      });
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (_filteredOptions.isEmpty) return;
      setState(() {
        _highlightedIndex =
            (_highlightedIndex - 1 + _filteredOptions.length) %
            _filteredOptions.length;
        _scrollToHighlighted();
      });
    }
  }

  _closeDialog([T? selectedOption]) {

    if (mounted) {

      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop(selectedOption);
      } else {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(selectedOption);
        } 
      }
    } 
  }

  void _scrollToHighlighted() {
    if (_highlightedIndex < 0 || _filteredOptions.isEmpty) return;

    const itemHeight = 48.0;
    final scrollOffset = _highlightedIndex * itemHeight;

    final viewportHeight = _scrollController.position.viewportDimension;

    if (scrollOffset < _scrollController.offset) {
      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else if (scrollOffset + itemHeight >
        _scrollController.offset + viewportHeight) {
      _scrollController.animateTo(
        scrollOffset + itemHeight - viewportHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _wasClosedManually = false;
  @override
  void dispose() {
    _dialogFocusNode.dispose();
    _textFieldFocusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.backgroundColor ?? Colors.white,
      shape: widget.dialogShape ?? RoundedRectangleBorder(),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth ?? 600,
          maxHeight:
              widget.maxHeightFactor ??
              MediaQuery.of(context).size.height * 0.8,
        ),
        child: KeyboardListener(
          focusNode: _dialogFocusNode,
          onKeyEvent: (event) {
            _handleKeyEvent(event);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon:
                      widget.closeButtonIcon ??
                      Icon(
                        Icons.close,
                        color: widget.closeButtonColor ?? Colors.white,
                      ),
                  onPressed: () {
                    _wasClosedManually = true;

                    widget.onClosed ?? _closeDialog();
                  },
                  focusColor:
                      widget.highlightedTileColor ??
                      Colors.grey.withValues(alpha: 0.01),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  focusNode: _textFieldFocusNode,
                  controller: _controller,
                  cursorColor: widget.dialogTextFieldCursor ?? Colors.blue,
                  autofocus: true,
                  style: widget.dialogTextFieldStyle,
                  decoration:
                      widget.searchFieldDecoration ??
                      InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                ),
              ),
              _filteredOptions.isNotEmpty
                  ? SizedBox(
                      height: widget.height ?? 48.0 * 5.5,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _filteredOptions.length,
                        itemBuilder: (_, index) {
                          final option = _filteredOptions[index];
                          final isHighlighted = index == _highlightedIndex;
                          return InkWell(
                            onTap: () {
                              widget.onSelected?.call(option);
                              _closeDialog(option);
                            },
                            child: Container(
                              height: widget.optionItemHeight,
                              color: isHighlighted
                                  ? Theme.of(context).highlightColor
                                  : Colors.white,
                              child:
                                  widget.optionBuilder?.call(
                                    context,
                                    option,
                                    isHighlighted,
                                  ) ??
                                  ListTile(
                                    title: Text(
                                      widget.displayStringForOption(option),
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox(
                      height: widget.optionItemHeight,
                      child: Center(
                        child: widget.noResultsBuilder != null
                            ? widget.noResultsBuilder!(context)
                            : Text(
                                widget.noResultsText ?? 'No results found',
                                style:
                                    widget.noResultsTextStyle ??
                                    const TextStyle(color: Colors.grey),
                              ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
