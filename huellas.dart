import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:huella_qutenticador/tienda/home.dart';

class UserProfilePage extends StatefulWidget {
  final String userName;
  final VoidCallback onLogout;

  const UserProfilePage({
    Key? key,
    required this.userName,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  String _authorized = 'Not Authorized';
  bool? habilitarAutenticacion;

  @override
  void initState() {
    super.initState();
    _estaHabilitado();
  }

  Future<void> _estaHabilitado() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      habilitarAutenticacion = prefs.getBool('habilitado') ?? false;
    });
  }

  Future<void> _habilitar() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool('habilitado', true);
    setState(() {
      habilitarAutenticacion = true;
    });
  }

  Future<void> _authenticate() async {
    bool isAuthenticated = false;
    try {
      setState(() {
        _authorized = 'Authenticating';
      });
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'autenticacion login',
      );
    } on PlatformException catch (e) {
      print('Error: $e');
      setState(() {
        _authorized = 'Error: ${e.message}';
        isAuthenticated = false;
      });
      return;
    }
    if (!mounted) return;
    setState(
        () => _authorized = isAuthenticated ? 'Authorized' : 'Not Authorized');
    if (_authorized == 'Authorized') {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 500,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Email",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ingrese email';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Password",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ingrese password';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16.0),
                        child: Center(
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final token = await authenticate(
                                      emailController.text,
                                      passwordController.text,
                                    );
                                    if (token != null) {
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('credenciales invalidas')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('complete')),
                                    );
                                  }
                                },
                                child: const Text('entrar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falla de autenticacion biometrica')),
      );
    }
  }

  Future<void> _deshabilitar() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'autenticacion login',
      );
    } catch (e) {
      print('Error: $e');
    }

    if (isAuthenticated) {
       await storage.delete(key: 'tokenBiometric');
       final SharedPreferences prefs = await _prefs;
      prefs.setBool('habilitado', false);
      setState(() {
        habilitarAutenticacion = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falla de autenticacion biometrica')),
      );
    }
  }

  Future<String?> authenticate(String email, String password) async {
    final Uri url = Uri.parse('http://192.168.56.1:3000/login/biometricLogin');

    try {
      final response = await http.post(
        url,
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.body;

        // final Map<String, dynamic> jsonToken = jsonDecode(token);

        // final String accessToken = jsonToken['accessToken'];

        print('Token: $token');
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('token', token);
        await storage.write(key: 'tokenBiometric', value: token);
        setState(() {
          _habilitar();
        });
        return token;
      } else {
        print('Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('habilitar huella'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${widget.userName}'),
            habilitarAutenticacion == false
                ? Column(
                    children: <Widget>[
                      Text('habilitar login con datos biometricos'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await _authenticate();
                        },
                        child: Text('Habilitar'),
                      )
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Text('Deshabilitar login con datos biometricos'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {_deshabilitar();},
                        child: Text('Deshabilitar'),
                      ),
                    ],
                  ),
                                    ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: Text('Ver tienda'),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await storage.delete(key: 'tokenBiometric');
                        widget.onLogout();
                      },
                      child: const Text('Salir')
                  ),
          ],
        ),
      ),
    );
  }
}