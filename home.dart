import 'package:flutter/material.dart';
import 'package:huella_qutenticador/tienda/articulos/lista_articulos.dart';
import 'package:huella_qutenticador/tienda/ofertas/lista_ofertas.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArticuloList()),
                );
              },
              child: Text('Ver todos los artículos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OfertaList()),
                );
              },
              child: Text('Ver artículos en oferta'),
            ),
          ],
        ),
      ),
    );
  }
}
