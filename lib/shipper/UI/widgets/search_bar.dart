import "dart:convert";
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import "package:tdlogistic_v2/core/constant.dart";

class MySearchBar extends StatefulWidget {
  final Icon icon;
  final Function() onChanged;
  final Function() onTap;
  final Function() onDelete;
  final TextEditingController controller;
  final String labelText;

  const MySearchBar({
    super.key,
    required this.onChanged,
    required this.icon,
    required this.controller,
    required this.onTap,
    required this.labelText,
    required this.onDelete,
  });

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  List<dynamic> _searchSuggestions = [];
  final String _apiKey = ggApiKey;
  bool _isLoading = false;

  Future<void> _getSearchSuggestions(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey&language=vi');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchSuggestions = data['predictions'];
        });
      } else {
        print("Error fetching suggestions: ${response.body}");
      }
    } catch (error) {
      print("Error fetching location: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: "Nhập địa điểm",
            filled: true,
            fillColor: Colors.white,
            labelText: widget.labelText,
            prefixIcon: widget.icon,
            suffixIcon: IconButton(
              onPressed: () {
                widget.controller.clear();
                setState(() {
                  _searchSuggestions.clear();
                });
                widget.onDelete();
              },
              icon: const Icon(Icons.clear),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: secondColor, width: 3),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          ),
          onChanged: (query) {
            if (query.isNotEmpty) {
              _getSearchSuggestions(query);
            } else {
              setState(() {
                _searchSuggestions = [];
              });
            }
            widget.onChanged();
          },
        ),
        const SizedBox(height: 5),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              color: Colors.white,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              itemCount: _searchSuggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchSuggestions[index]['description']),
                  onTap: () {
                    widget.onTap();
                    setState(() {
                      widget.controller.text =
                          _searchSuggestions[index]['description'];
                      _searchSuggestions = [];
                    });
                    widget.onChanged();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
