import 'package:flutter/material.dart';
import 'package:keyboard_search_dialog/keyboard_search_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Dialog Demo',
      home: const SearchDemoPage(),
    );
  }
}

class SearchDemoPage extends StatefulWidget {
  const SearchDemoPage({super.key});

  @override
  State<SearchDemoPage> createState() => _SearchDemoPageState();
}

class _SearchDemoPageState extends State<SearchDemoPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Dialog Example')),
      body: Center(
        child: KeyboardControlledAutocomplete<String>(
        label: "search",
                  controller: _controller,
          focusNode: _focusNode,
          options: const ['Apple', 'Banana', 'Mango', 'Grapes'],
          displayStringForOption: (item) => item,
          onSelected: (value) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('You selected: $value')));
          },
          initialText: '',
          highlightedTileColor: Colors.blue.shade50,
          searchFieldDecoration: const InputDecoration(
            hintText: 'Search fruits...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
