import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:huella_qutenticador/tienda/tarjeta_articulos.dart';
import 'package:huella_qutenticador/tienda/info_articulos.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfertaList extends StatefulWidget {
  @override
  _OfertaListState createState() => _OfertaListState();
}

class _OfertaListState extends State<OfertaList> {
  late List<Articulo> articulos = [];
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    String URL = "http://192.168.56.1:3000/product";
    try {
      final String? token = await storage.read(key: 'token');
      final response = await http.get(Uri.parse(URL),
      headers:{
        'Authorization': 'Bearer: $token'
      });
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> articulosData = responseData['articulos'];
        setState(() {
          articulos = articulosData
              .map((data) {
                return Articulo(
                  data['urlimagen'],
                  data['articulo'],
                  data['descripcion'],
                  int.parse(data['precio']),
                  int.parse(data['descuento']),
                  int.parse(data['valoracion']),
                  int.parse(data['calificaciones']),
                );
              })
              .where((articulo) => articulo.descuento > 0) // Filtra los artículos que tienen descuento
              .toList();
        });
      } else {
        throw Exception('Error al enviar o recibir la solicitud');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de artículos en oferta'),
        centerTitle: true,
      ),
      body: articulos.isNotEmpty
          ? ListView.builder(
              itemCount: articulos.length,
              itemBuilder: (context, index) {
                return ArticuloCard(articulo: articulos[index]);
              },
            )
          : Center(child: Text('No hay artículos en oferta')),
    );
  }
}