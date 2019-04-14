import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:follow_app/settings.dart';
import 'package:follow_app/user.dart' as user;

class PinScreen extends StatefulWidget {
  final int _pinLength = 4;
  final double _fieldWidth = 40.0;
  //final double _fontSize = 20.0;

  @override
  _PinScreenState createState() => _PinScreenState();
}

enum _PinScreenStateType { generation, entry, loading }

class _PinScreenState extends State<PinScreen> {
  _PinScreenStateType _currentState;
  bool _canNavigatePop = false;
  DocumentSnapshot _patientsPin;

  void _setStateToGeneration() => this.setState(() {_currentState = _PinScreenStateType.generation;});
  void _setStateToEntry() => this.setState(() {_currentState = _PinScreenStateType.entry;});
  void _setStateToLoading() => this.setState(() {_currentState = _PinScreenStateType.loading;});

  String _pin;
  String _generatedPinDocumentId;
  List<String> _pinDigits;
  List<Widget> _textFields;
  List<FocusNode> _focusNodes;
  List<TextEditingController> _textControllers;
  bool _isChatAlreadyExists = false;

  @override
  void initState()  {
    super.initState();
    switch (user.userType) {
      case user.UserType.doctor:
        _setStateToGeneration();

        _pin = _generatePin();
        _isChatAlreadyExists = false;

        // Save to database
        Firestore.instance
          .collection('pin_codes')
          .add({
            'doctor_id': user.id,
            'patiend_id': null,
            'pin_code': _pin,
            'is_used': false,
            'is_acknowledged': false,
            'create_date': Timestamp.now(),
            'used_date': null
          }).then((DocumentReference ref) {
            _generatedPinDocumentId = ref.documentID;
            _setStateToLoading();
          });
            
        break;

      case user.UserType.patient:
      default:
        _setStateToEntry();

        _pinDigits = List<String>(widget._pinLength);
        _focusNodes = List.generate(widget._pinLength, (int i) {
          return FocusNode();
        });
        _textControllers = List.generate(widget._pinLength, (int i) {
          return TextEditingController();
        });
        _textFields = List.generate(widget._pinLength, (int i) {
          return _buildDigitEntryField(i, context);
        });

        for (int i = 0; i < widget._pinLength; i++) {
          _focusNodes[i].addListener(() {
            if (_focusNodes[i].hasFocus) {
              _textControllers[i].clear();
            }
          });
        }

        break;
    }
  }

  Widget _pinEnteredByPatientCallback(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.hasError) {
      Fluttertoast.showToast(msg: 'Terrible error!');
      Navigator.pop(context);
    }
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        break;
      default:
        if (snapshot.data.data != null) {
          if (snapshot.data['is_used'] == true) {
            Fluttertoast.showToast(msg: 'Correct PIN by patient!');
            _patientsPin = snapshot.data;
          }
        }
    }
    return Container();
  }

  Widget _pinAcknowledgedByDoctorCallback(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.hasError) {
      Fluttertoast.showToast(msg: 'Terrible error!');
      Navigator.pop(context);
    }
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        break;
      default:
        if (snapshot.data.data != null) {
          if (snapshot.data['is_acknowledged'] == true) {
            Fluttertoast.showToast(msg: 'Acknowledged!');
            _canNavigatePop = true;
            _clearTextFields();
            Firestore.instance
              .collection('pin_codes')
              .document(snapshot.data.documentID)
              .delete();
          }
        }
    } 
    return Container();
  }

  @override
  void dispose() {
    _textControllers.forEach((TextEditingController t) => t.dispose());
    super.dispose();
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);
    // TODO: remove unused PIN
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_canNavigatePop == true) {
      Navigator.pop(context);
      return Container();
    } 
    if (_patientsPin != null) {
      _handlePatientEnteredPin();
      _isChatAlreadyExists = true;
    }
    switch (user.userType) {
      case user.UserType.doctor:
        return _buildPinGenerationField(context);
        break;
      case user.UserType.patient:
      default:
        return _buildPinEntryField(context);
    }
  }

  Widget _buildPinGenerationField(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: onBackPress,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _currentState == _PinScreenStateType.loading ? 
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(LOADING_COLOR),
              ) : Container(),
              Container(height: 30.0),
              Text('Show this PIN to your patient', style: TextStyle(fontSize: 24.0)),
              Container(height: 15.0), // spacer
              Text(_pin, style: TextStyle(fontSize: 48.0)),
              Container(height: 15.0),
              RaisedButton(
                onPressed: onBackPress,
                color: Colors.red,
                child: Text('Cancel', style: TextStyle(color: Colors.white))
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance.collection('pin_codes').document(_generatedPinDocumentId).snapshots(),
                builder: _pinEnteredByPatientCallback
              )
            ],
          )
        )
      )
    );
  }

  Widget _buildPinEntryField(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _currentState == _PinScreenStateType.loading ? 
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(LOADING_COLOR),
              ) : Container(),
              Container(height: 30.0),
              Text('Enter PIN from your doctor', style: TextStyle(fontSize: 24.0)),
              Container(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                verticalDirection: VerticalDirection.down,
                children: _textFields
              ),
              Container(height: 30.0),
              RaisedButton(
                onPressed: onBackPress,
                color: Colors.red,
                child: Text('Cancel', style: TextStyle(color: Colors.white))
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance.collection('pin_codes').document(_generatedPinDocumentId).snapshots(),
                builder: _pinAcknowledgedByDoctorCallback
              )
            ]
          )
        )
      )
    );
  }

  Widget _buildDigitEntryField(int i, BuildContext context) {
    
    return Container(
      width: widget._fieldWidth,
      margin: EdgeInsets.only(right: 10.0),
      child: TextField(
        controller: _textControllers[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        focusNode: _focusNodes[i],
        decoration: InputDecoration(
            counterText: ""
        ),
        onChanged: (String str) {
          _pinDigits[i] = str;
          if (i + 1 != widget._pinLength) {
            FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
          } else {
            //FocusScope.of(context).requestFocus(_focusNodes[0]);
            _handlePinSubmit(str);
          }
        },
        onSubmitted: _handlePinSubmit
      ),
    );
  }

  String _generatePin() {
    // Generate new pin
    var randomNumberGenerator = Random();
    int pinNumber = randomNumberGenerator.nextInt(8999) + 1000;
    return pinNumber.toString();
  }

  void _handlePatientEnteredPin() async {
    // Verify if a chat between patient and doctor already exists
    QuerySnapshot matchingPatients = await Firestore.instance
      .collection('chats')
      .where('patient_id', isEqualTo: _patientsPin.data['patient_id'])
      //.where('doctor_id', isEqualTo: user.id)
      .getDocuments();
    
    // Filter by doctor_id as well
    List<DocumentSnapshot> docs = matchingPatients
      .documents
      .where((snapshot) => snapshot.data.containsValue(user.id)).toList();

    //_isChatAlreadyExists = docs.length > 0;
    if (_isChatAlreadyExists == false) {
      await Firestore.instance
        .collection('chats')
        .document()
        .setData({
          'doctor_id': user.id,
          'patient_id': _patientsPin['patient_id'],
          'create_date': Timestamp.now()
        });
      await Firestore.instance
        .collection('pin_codes')
        .document(_patientsPin.documentID)
        .setData({
          'doctor_id': _patientsPin['doctor_id'],
          'patient_id': _patientsPin['patient_id'],
          'is_used': _patientsPin['is_used'],
          'create_date': _patientsPin['create_date'],
          'used_date': _patientsPin['used_date'],
          'pin_code': _patientsPin['pin_code'],
          'is_acknowledged': true
        });
    } else {
      //await Firestore.instance
      //  .collection('pin_codes')
      //  .document(_patientsPin.documentID)
      //  .delete();
    }
    _canNavigatePop = true;
  }

  void _handlePinSubmit(String str) async {
    _setStateToLoading();
    String pin = _pinDigits.join();

    // Check that such PIN exists in database
    QuerySnapshot result = await Firestore.instance
      .collection('pin_codes')
      .where('pin_code', isEqualTo: pin)
      .getDocuments();

    List<DocumentSnapshot> docs = result.documents;

    assert(docs.length <= 1, 'More than 1 PIN found');

    // If PIN code is found
    if (docs.length > 0) {
      DocumentSnapshot doc = docs[0];

      // Update PIN data in DB for doctor to see
      Firestore.instance
        .collection('pin_codes')
        .document(doc.documentID)
        .setData({
          'doctor_id': doc['doctor_id'],
          'patient_id': user.id,
          'is_used': true,
          'is_acknowledged': false,
          'pin_code': doc['pin_code'],
          'create_date': doc['create_date'],
          'used_date': Timestamp.now() 
        });

      Fluttertoast.showToast(msg: 'Correct PIN');

      // Wait for Doctor to see changes
      _generatedPinDocumentId = doc.documentID;
      
    } else {
      _setStateToEntry();
      _clearTextFields();
      Fluttertoast.showToast(msg: 'Wrong PIN');
    }
  }

  void _clearTextFields() {
    _textControllers.forEach(
      (TextEditingController tEditController) => tEditController.clear()
    );

    for (int i = 0; i < widget._pinLength; i++) {
      _pinDigits[i] = null;
    }

    FocusScope.of(context).requestFocus(_focusNodes[0]);
  }
}