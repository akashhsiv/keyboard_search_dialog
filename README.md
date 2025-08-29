# keyboard_search_dialog

A Flutter package that provides a keyboard-controlled autocomplete widget with a search dialog. Perfect for creating searchable dropdowns and autocomplete fields that open a search dialog on keyboard input.

## Features

- **Keyboard Controlled**: Automatically opens search dialog on Enter key or printable character input
- **Customizable Search Dialog**: Fully customizable search dialog with filtering capabilities
- **Focus Management**: Built-in focus handling with support for next focus nodes
- **Flexible Styling**: Customizable appearance for both input field and search dialog
- **Type Safe**: Generic implementation supporting any data type
- **Accessibility**: Built with accessibility in mind

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  keyboard_search_dialog: ^1.0.0
```

## Usage

### Basic Usage

```dart
import 'package:keyboard_search_dialog/keyboard_search_dialog.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return KeyboardControlledAutocomplete<String>(
      options: const ['Apple', 'Banana', 'Cherry', 'Date'],
      displayStringForOption: (item) => item,
      onSelected: (value) {
        print('Selected: $value');
      },
      controller: _controller,
      focusNode: _focusNode,
      label: 'Select a fruit',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
```

### Advanced Usage with Custom Styling

```dart
KeyboardControlledAutocomplete<String>(
  options: const ['Red', 'Green', 'Blue', 'Yellow'],
  displayStringForOption: (color) => color,
  onSelected: (color) {
    setState(() {
      selectedColor = color;
    });
  },
  controller: _controller,
  focusNode: _focusNode,
  
  // Input field styling
  label: 'Choose a color',
  labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  textStyle: TextStyle(fontSize: 18),
  focusColor: Colors.blue,
  
  // Search dialog styling
  backgroundColor: Colors.white,
  highlightedTileColor: Colors.blue.shade50,
  maxWidth: 400,
  height: 500,
  
  // Custom search field decoration
  searchFieldDecoration: InputDecoration(
    hintText: 'Search colors...',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.search),
  ),
  
  // Custom option builder
  optionBuilder: (context, color, isHighlighted) {
    return ListTile(
      title: Text(color),
      tileColor: isHighlighted ? Colors.blue.shade100 : null,
      leading: Icon(Icons.circle, color: _getColorValue(color)),
    );
  },
);
```

## API Reference

### KeyboardControlledAutocomplete

The main widget that provides keyboard-controlled autocomplete functionality.

#### Required Parameters

- `options`: The list of available options
- `displayStringForOption`: Function to convert option to display string
- `onSelected`: Callback when an option is selected
- `controller`: TextEditingController for the input field
- `focusNode`: FocusNode for the input field

#### Optional Parameters

##### Input Field Styling
- `label`: Label text for the input field
- `labelStyle`: TextStyle for the label
- `hintStyle`: TextStyle for the hint text
- `textStyle`: TextStyle for the input text
- `validator`: Form validation function
- `contentPadding`: Padding for the input field
- `canFillColor`: Whether to fill the input field with color
- `focusColor`: Color when the field is focused

##### Focus Management
- `nextFocusNode`: FocusNode to focus after selection
- `nextFocus`: Alternative focus node
- `fallbackFocusOnCancel`: Focus node when dialog is cancelled

##### Search Dialog Styling
- `height`: Height of the search dialog
- `backgroundColor`: Background color of the dialog
- `highlightedTileColor`: Color for highlighted options
- `dialogTextFieldStyle`: TextStyle for dialog search field
- `searchFieldDecoration`: InputDecoration for dialog search field
- `closeButtonIcon`: Icon for the close button
- `closeButtonColor`: Color for the close button
- `dialogShape`: Shape border for the dialog
- `maxWidth`: Maximum width of the dialog
- `maxHeightFactor`: Maximum height factor relative to screen
- `optionItemHeight`: Height of each option item

##### Content Customization
- `noResultsText`: Text to show when no results found
- `noResultsTextStyle`: TextStyle for no results text
- `noResultsBuilder`: Custom builder for no results state
- `optionBuilder`: Custom builder for option items
- `barrierDismissible`: Whether dialog can be dismissed by tapping outside
- `barrierColor`: Color of the barrier behind the dialog
- `autoFocusSearchField`: Whether to auto-focus the search field in dialog

## Example

Check out the example app in the `example/` directory to see the widget in action.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
