import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:login_screen/screens/home_page_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: _formKey,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (email) {
                  if (email == null || email.isEmpty) {
                    return 'Por favor, digite seu e-mail';
                  } else if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(_emailController.text)) {
                    return 'Por favor, digite um e-mail correto';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha'),
                controller: _passwordController,
                obscureText: true,
                keyboardType: TextInputType.text,
                validator: (password) {
                  if (password == null || password.isEmpty) {
                    return 'Por favor, digite sua senha';
                  } else if (password.length < 6) {
                    return 'Por favor, digite uma senha maior que 6 caracteres';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                  onPressed: () async {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (_formKey.currentState!.validate()) {
                      bool itWorkedOut = await login();
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (itWorkedOut) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      } else {
                        _passwordController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  },
                  child: Text('Entrar')),
            ],
          ),
        ),
      ),
    ));
  }

  final snackBar = SnackBar(
      content: Text(
        'E-mail ou senha são inválidos',
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.redAccent);

  Future<bool> login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var url = Uri.parse('https://mockapi.io/login/');
    var response = await http.post(
      url,
      body: {
        'username': _emailController.text,
        'password': _passwordController.text,
      },
    );
    if (response.statusCode == 200) {
      await sharedPreferences.setString(
          'token', "token ${jsonDecode(response.body)['token']}");
      return true;
    } else {
      print(jsonDecode(response.body));
      return false;
    }
  }
}
