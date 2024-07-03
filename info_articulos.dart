import 'package:flutter/material.dart';

class Articulo {
  final String urlImagen, articulo, descripcion;
  final int precio, descuento, valoracion, calificaciones;

  Articulo(this.urlImagen, this.articulo, this.descripcion, this.precio, this.descuento, this.valoracion, this.calificaciones);
}

class ArticuloDetails extends StatelessWidget {
  final Articulo articulo;

  const ArticuloDetails({Key? key, required this.articulo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcula el valor del producto antes del descuento
    double precioAntesDescuento = articulo.precio - ((articulo.precio * articulo.descuento) / 100);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del artículo'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 300, // Ancho del contenedor
          padding: EdgeInsets.all(20), // Relleno interno del contenedor
          margin: EdgeInsets.all(20), // Margen externo del contenedor
          decoration: BoxDecoration(
            color: Colors.grey[200], // Color de fondo del contenedor
            borderRadius: BorderRadius.circular(10), // Bordes redondeados del contenedor
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                child: Image(
                  image: NetworkImage(articulo.urlImagen),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Text("Artículo: ${articulo.articulo}"),
              Text("Descripción: ${articulo.descripcion}"),
              Text("Precio: \$${articulo.precio}"), // Agrega el signo de dólar aquí
              if (articulo.descuento > 0)
                Text("Precio aplicando descuento: \$${precioAntesDescuento}"),
              Text("Descuento: ${articulo.descuento}%"),
              Text("Valoración: ${articulo.valoracion}"),
              Text("${articulo.calificaciones} de calificacion"),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('< Regresar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}