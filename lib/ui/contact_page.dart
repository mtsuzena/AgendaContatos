import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isMan = false;
  bool _isWoman = false;

  final _formKey = GlobalKey<FormState>();

  final _nameFocus = FocusNode();

  bool _userEdited = false;
  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
      _isMan = toBoolean(_editedContact.man);
      _isWoman = toBoolean(_editedContact.woman);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.img != null
                              ? FileImage(File(_editedContact.img))
                              : _editedContact.man == "true"
                                  ? AssetImage("images/man.png")
                                  : AssetImage("images/woman.png"),
                          fit: BoxFit.cover)),
                ),
                onTap: () {
                  _showOptionsImage();
                },
              ),
              Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      decoration: InputDecoration(labelText: "Nome"),
                      onChanged: (text) {
                        _userEdited = true;
                        setState(() {
                          _editedContact.name = text;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "O nome não pode estar em branco";
                        }

                        if (value.isEmpty) {
                          return "O nome não pode estar em branco";
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: "Email"),
                      onChanged: (text) {
                        _userEdited = true;
                        _editedContact.email = text;
                      },
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (!validateEmail(value) && value.isNotEmpty) {
                          return "E-mail inválido";
                        }

                        return null;
                      },
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: "Telefone"),
                      onChanged: (text) {
                        _userEdited = true;
                        _editedContact.phone = text;
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text("Masculino"),
                        Checkbox(
                          value: _isMan,
                          onChanged: (bool value) {
                            setState(() {
                              if (value) {
                                _isMan = true;
                                _isWoman = false;
                              } else {
                                _isMan = false;
                              }

                              _editedContact.man = toString(_isMan);
                              _editedContact.woman = toString(_isWoman);
                            });
                          },
                        ),
                        SizedBox(
                          height: 70,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text("Feminino"),
                        Checkbox(
                          value: _isWoman,
                          onChanged: (bool value) {
                            setState(() {
                              if (value) {
                                _isWoman = true;
                                _isMan = false;
                              } else {
                                _isWoman = false;
                              }

                              _editedContact.man = toString(_isMan);
                              _editedContact.woman = toString(_isWoman);
                            });
                          },
                        ),
                      ],
                    ),
                  ])),
            ],
          ),
        ),
      ),
    );
  }

  bool validateEmail(String email) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
  }

  void _showOptionsImage() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          "Camera",
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                        onPressed: () {
                          ImagePicker.pickImage(source: ImageSource.camera)
                              .then((file) {
                            if (file == null) return;
                            print('Printando path imagem: $file.path');
                            setState(() {
                              _editedContact.img = file.path;
                            });
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          "Galeria",
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                        onPressed: () {
                          ImagePicker.pickImage(source: ImageSource.gallery)
                              .then((file) {
                            if (file == null) return;
                            print('Printando path imagem: $file.path');
                            setState(() {
                              _editedContact.img = file.path;
                            });
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}

String toString(bool b) {
  if (b) {
    return "true";
  }
  return "false";
}

bool toBoolean(String str) {
  if (str == "true") {
    return true;
  }
  return false;
}
