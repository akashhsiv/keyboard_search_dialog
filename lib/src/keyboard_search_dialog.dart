import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_search_dialog/src/search_dialog.dart';

class KeyboardControlledAutocomplete<T extends Object> extends StatefulWidget {
  final Iterable<T> options;
  final String Function(T) displayStringForOption;
  final void Function(T) onSelected;
  final TextEditingController controller;
  final FocusNode focusNode;

  // Input decoration params
  final String? label;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsDirectional? contentPadding;
  final bool? canFillColor;
  final Color? focusColor;

  // Focus handling
  final FocusNode? nextFocusNode;
  final FocusNode? nextFocus;
  final FocusNode? fallbackFocusOnCancel;

  // SearchDialog specific params
  final double? height;
  final String? initialText;
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
  final bool barrierDismissible;
  final Color? barrierColor;
  final bool autoFocusSearchField;
  final BoxConstraints? constraints;

  const KeyboardControlledAutocomplete({
    super.key,
    required this.options,
    required this.displayStringForOption,
    required this.onSelected,
    required this.controller,
    required this.focusNode,

    this.height,
    this.initialText,
    this.label,
    this.labelStyle,
    this.hintStyle,
    this.textStyle,
    this.validator,
    this.contentPadding,
    this.canFillColor = false,
    this.focusColor,

    this.nextFocus,
    this.nextFocusNode,
    this.fallbackFocusOnCancel,

    this.backgroundColor,
    this.highlightedTileColor,
    this.dialogTextFieldStyle,
    this.dialogTextFieldCursor,
    this.searchFieldDecoration,
    this.closeButtonIcon,
    this.closeButtonColor,
    this.onClosed,
    this.dialogShape,
    this.maxWidth,
    this.maxHeightFactor,
    this.optionItemHeight,
    this.noResultsText,
    this.noResultsTextStyle,
    this.noResultsBuilder,
    this.optionBuilder,
    this.autoFocusSearchField = false,
    this.barrierColor,
    this.barrierDismissible = false,
    this.constraints,
  });

  @override
  State<KeyboardControlledAutocomplete> createState() =>
      _KeyboardControlledAutocompleteState<T>();
}

class _KeyboardControlledAutocompleteState<T extends Object>
    extends State<KeyboardControlledAutocomplete<T>> {
  late final FocusNode _keyboardFocus;
  bool _isDialogOpen = false;
  bool _suppressNextFocusTrigger = false;

  @override
  void initState() {
    super.initState();
    _keyboardFocus = FocusNode();
  }

  void _openSearchDialog({String initialText = ''}) async {
    if (_isDialogOpen) return;
    widget.focusNode.unfocus();
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    setState(() => _isDialogOpen = true);

    try {
      final selected = await showDialog<T>(
        context: context,
        barrierDismissible: widget.barrierDismissible,
        barrierColor: widget.barrierColor ?? Colors.black54,
        builder: (dialogContext) {
          return SearchDialog<T>(
            options: widget.options,
            displayStringForOption: widget.displayStringForOption,
            onSelected: widget.onSelected,
            initialText: initialText.isNotEmpty
                ? initialText
                : (widget.initialText ?? ''),

            // Forward all SearchDialog params
            height: widget.height,
            nextFocus: widget.nextFocus,
            nextFocusNode: widget.nextFocusNode,
            backgroundColor: widget.backgroundColor,
            highlightedTileColor: widget.highlightedTileColor,
            dialogTextFieldStyle: widget.dialogTextFieldStyle,
            dialogTextFieldCursor: widget.dialogTextFieldCursor,
            searchFieldDecoration: widget.searchFieldDecoration,
            closeButtonIcon: widget.closeButtonIcon,
            closeButtonColor: widget.closeButtonColor,
            onClosed: widget.onClosed,
            dialogShape: widget.dialogShape,
            maxWidth: widget.maxWidth,
            maxHeightFactor: widget.maxHeightFactor,
            optionItemHeight: widget.optionItemHeight,
            noResultsText: widget.noResultsText,
            noResultsTextStyle: widget.noResultsTextStyle,
            noResultsBuilder: widget.noResultsBuilder,
            optionBuilder: widget.optionBuilder,
          );
        },
      );

      if (selected != null) {
        widget.controller.text = widget.displayStringForOption(selected);
        widget.onSelected(selected);

        _suppressNextFocusTrigger = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _moveFocusToNext());
      } else {
        _suppressNextFocusTrigger = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.fallbackFocusOnCancel != null) {
            widget.fallbackFocusOnCancel!.requestFocus();
          } else {
            widget.focusNode.requestFocus();
          }
        });
      }
    } finally {
      setState(() => _isDialogOpen = false);
    }
  }

  void _moveFocusToNext() {
    if (_suppressNextFocusTrigger) return; // skip moving focus
    if (widget.nextFocusNode != null) {
      widget.nextFocusNode!.requestFocus();
    } else if (widget.nextFocus != null) {
      widget.nextFocus!.requestFocus();
    } else {
      FocusScope.of(context).nextFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocus,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;
          final isPrintable =
              event.character != null && event.character!.isNotEmpty;

          if (!_isDialogOpen &&
              widget.focusNode.hasFocus &&
              (key == LogicalKeyboardKey.enter || isPrintable)) {
            final initial = widget.controller.text;
            _openSearchDialog(initialText: initial);
          }
        }
      },
      child: ConstrainedBox(
        constraints:
            widget.constraints ??
            const BoxConstraints(maxWidth: 500, maxHeight: 140),
        child: TextFormField(
          maxLines: 1,
          style:
              widget.textStyle?.copyWith(overflow: TextOverflow.ellipsis) ??
              const TextStyle(overflow: TextOverflow.ellipsis),
          validator: widget.validator,
          cursorColor: widget.focusColor,
          controller: widget.controller,
          autofocus: widget.autoFocusSearchField,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            contentPadding: widget.contentPadding,
            filled: widget.canFillColor,
            fillColor: widget.focusColor,
            hintText: widget.label,
            hintStyle: widget.hintStyle ?? const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _keyboardFocus.dispose();
    super.dispose();
  }
}
