library countrycodepicker;

import 'package:flutter/material.dart';
import 'sim_country_code/flutter_sim_country_code.dart';

import 'country.dart';
import 'functions.dart';

const TextStyle _defaultItemTextStyle = TextStyle(fontSize: 16);
const TextStyle _defaultSearchInputStyle = TextStyle(fontSize: 16);
const String _kDefaultSearchHintText = 'Search';
const String countryCodePackageName = 'country_calling_code_picker';

class CountryPickerWidget extends StatefulWidget {
  /// This callback will be called on selection of a [Country].
  final ValueChanged<Country>? onSelected;

  /// [itemTextStyle] can be used to change the TextStyle of the Text in ListItem. Default is [_defaultItemTextStyle]
  final TextStyle itemTextStyle;

  /// [searchInputStyle] can be used to change the TextStyle of the Text in SearchBox. Default is [searchInputStyle]
  final TextStyle searchInputStyle;

  /// [searchInputDecoration] can be used to change the decoration for SearchBox.
  final InputDecoration? searchInputDecoration;

  /// Flag icon size (width). Default set to 32.
  final double flagIconSize;

  ///Can be set to `true` for showing the List Separator. Default set to `false`
  final bool showSeparator;

  ///Can be set to `true` for opening the keyboard automatically. Default set to `false`
  final bool focusSearchBox;

  ///This will change the hint of the search box. Alternatively [searchInputDecoration] can be used to change decoration fully.
  final String searchHintText;

  const CountryPickerWidget({
    Key? key,
    this.onSelected,
    this.itemTextStyle = _defaultItemTextStyle,
    this.searchInputStyle = _defaultSearchInputStyle,
    this.searchInputDecoration,
    this.searchHintText = _kDefaultSearchHintText,
    this.flagIconSize = 32,
    this.showSeparator = false,
    this.focusSearchBox = false,
  }) : super(key: key);

  @override
  _CountryPickerWidgetState createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  List<Country> _list = [];
  List<Country> _filteredList = [];
  TextEditingController _controller = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  bool _isLoading = false;
  Country? _currentCountry;

  void _onSearch(text) {
    if (text == null || text.isEmpty) {
      setState(() {
        _filteredList.clear();
        _filteredList.addAll(_list);
      });
    } else {
      setState(() {
        _filteredList = _list
            .where((element) =>
                element.name
                    .toLowerCase()
                    .contains(text.toString().toLowerCase()) ||
                element.callingCode
                    .toLowerCase()
                    .contains(text.toString().toLowerCase()) ||
                element.countryCode
                    .toLowerCase()
                    .startsWith(text.toString().toLowerCase()))
            .map((e) => e)
            .toList();
      });
    }
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
    loadList();
    super.initState();
  }

  void loadList() async {
    setState(() {
      _isLoading = true;
    });
    _list = await getCountries(context);
    try {
      String? code = await FlutterSimCountryCode.simCountryCode;
      _currentCountry =
          _list.firstWhere((element) => element.countryCode == code);
      final country = _currentCountry;
      if (country != null) {
        _list.removeWhere(
            (element) => element.callingCode == country.callingCode);
        _list.insert(0, country);
      }
    } catch (e) {} finally {
      setState(() {
        _filteredList = _list.map((e) => e).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Container(
          child: TextField(
            style: widget.searchInputStyle,
            autofocus: widget.focusSearchBox,
            decoration: widget.searchInputDecoration ??
                InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Visibility(
                    visible: _controller.text.isNotEmpty,
                    child: InkWell(
                      child: Icon(Icons.clear),
                      onTap: () => setState(() {
                        _controller.clear();
                        _filteredList.clear();
                        _filteredList.addAll(_list);
                      }),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8EAAFB), width: 0.0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8EAAFB), width: 0.0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                  hintText: widget.searchHintText,
                  filled: true,
                  fillColor: Color(0xFFB7C8FD),
                ),
            textInputAction: TextInputAction.done,
            controller: _controller,
            onChanged: _onSearch,
          ),
        ),
        SizedBox(
          height: 24,
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.separated(
                  controller: _scrollController,
                  itemCount: _filteredList.length,
                  separatorBuilder: (_, index) =>
                      widget.showSeparator ? Divider() : Container(),
                  itemBuilder: (_, index) {
                    return InkWell(
                      onTap: () {
                        widget.onSelected?.call(_filteredList[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom: 24),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              _filteredList[index].flag,
                              package: countryCodePackageName,
                              width: widget.flagIconSize,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Text(
                                  '${_filteredList[index].callingCode}',
                                  style: widget.itemTextStyle,
                                ),
                            ),
                            Text(
                              '${_filteredList[index].name}',
                              style: widget.itemTextStyle,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
