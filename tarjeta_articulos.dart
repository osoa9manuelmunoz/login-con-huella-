import 'package:flutter/material.dart';
import 'package:huella_qutenticador/tienda/info_articulos.dart';

class ArticuloCard extends StatelessWidget {
  final Articulo articulo;

  const ArticuloCard({Key? key, required this.articulo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticuloDetails(articulo: articulo),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image(
                  image: NetworkImage(articulo.urlImagen),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Artículo: ${articulo.articulo}"),
                    Text("Precio: ${articulo.descuento > 0 ? articulo.precio - (articulo.precio * articulo.descuento / 100) : articulo.precio}"),
                    Text("Descuento: ${articulo.descuento}%"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}