import 'package:country_calling_code_picker/picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Country? _selectedCountry;
  late bool _isButtonDisabled;
  final fieldText  = TextEditingController();

  @override
  void initState() {
    initCountry();
    super.initState();
    _isButtonDisabled = true;
  }

  void initCountry() async {
    final country = await getDefaultCountry(context);
    setState(() {
      _selectedCountry = country;
    });
  }

  void _sendNumber() {
    print("Number sent");
    fieldText.clear();

    setState(() {
      _isButtonDisabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final country = _selectedCountry;
    final heightScreen = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF8EAAFB),
      body: Container(
        margin: const EdgeInsets.fromLTRB(20, 80, 20, 20),
        child: Column(
            children: [
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(bottom: heightScreen * 0.30),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.inter(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  country == null
                      ? Container()
                      : Container(
                        margin: EdgeInsets.only(bottom: heightScreen * 0.35),
                        child: Row(
                        children: <Widget>[

                        FloatingActionButton.extended(

                          onPressed: _onPressedShowBottomSheet,
                          label: Container(  //You can use EdgeInsets like above
                            margin: EdgeInsets.all(0),
                            child: Text(
                              '${country.callingCode}',
                            ),
                          ),
                          icon: Image.asset(
                            country.flag,
                            package: countryCodePackageName,
                            width: 28,
                            height: 38,
                          ),
                          backgroundColor: Color.fromRGBO(183, 200, 253, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 0,
                          hoverElevation: 0,
                          focusElevation: 0,
                          highlightElevation: 0,
                        ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          SizedBox(
                            width: width * 0.55,
                            child: TextFormField(
                              controller: fieldText,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                CardNumberFormatter(),
                              ],
                              decoration: const InputDecoration(
                                hintText: "(123) 123-1234",
                                filled: true,
                                fillColor: Color.fromRGBO(183, 200, 253, 1),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(color: Color(0xFF8EAAFB), width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(color: Color(0xFF8EAAFB), width: 1.0),
                                ),
                                counterText: "",
                              ),
                              keyboardType: TextInputType.phone,
                              maxLength: 14,
                              onChanged: (text) => setState(() {
                                if(text.length == 14) {
                                  _isButtonDisabled = false;
                                }
                              }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(183, 200, 253, 1),
                          fixedSize: const Size(48, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        onPressed: _isButtonDisabled ? null : _sendNumber,

                        child: Icon(Icons.arrow_right),
                    ),
                  )
                ],
              ),
            ]
        ),
      )
    );
  }

  void _onPressedShowBottomSheet() async {
    final country = await showCountryPickerSheet(
      context,
    );
    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
    }
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue previousValue,
      TextEditingValue nextValue,
      ) {
    var inputText = nextValue.text;

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    var bufferString = StringBuffer();

    bufferString.write('(');
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;

      if (nonZeroIndexValue == 3 && nonZeroIndexValue != inputText.length) {
        bufferString.write(') ');
      }

      if (nonZeroIndexValue == 6 && nonZeroIndexValue != inputText.length) {
        bufferString.write('-');
      }
    }

    var string = bufferString.toString();
    return nextValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}