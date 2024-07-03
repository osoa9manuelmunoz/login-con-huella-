import 'package:flutter/material.dart';
import 'package:huella_qutenticador/huella.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  final storage = const FlutterSecureStorage();
  bool habilitarAutenticacion = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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

  Future<String?> authenticate(String email, String password) async {
    final Uri url = Uri.parse('http://192.168.56.1:3000/login');

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
        await storage.write(key: 'token', value: token);
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

  Future<void> _authenticate() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'autenticacion login',
      );
    } catch (e) {
      print('Error: $e');
    }

    if (isAuthenticated) {
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('token');
      final token = await storage.read(key: 'token');

      if (token != null) {
        final Uri url = Uri.parse('http://192.168.56.1:3000/login/verify');

        try {
          final response = await http.get(
            url,
            headers: {'Authorization': '$token'},
          );

          if (response.statusCode == 200) {
            print('Response: ${response.body}');
            final userName = emailController.text;
            _showUserProfile(userName);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Error en la solicitud: ${response.reasonPhrase}')),
            );
          }
        } catch (e) {
          print('Error en la solicitud: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error en la solicitud')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token no encontrado')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falla de autenticacion biometrica')),
      );
    }
  }

  void _showUserProfile(String userName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(
          userName: userName,
          onLogout: () async {
            // final prefs = await SharedPreferences.getInstance();
            // await prefs.remove('token');
            // await storage.delete(key: 'token');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Login(title: 'Flutter Demo Home Page'),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
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
                              final userName = emailController.text;
                              _showUserProfile(userName);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('credenciales invalidas')),
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
                      habilitarAutenticacion == true
                          ? ElevatedButton(
                              onPressed: _authenticate,
                              child: const Text('entrar con huella'),
                            )
                          : SizedBox(
                              height: 20,
                            )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
