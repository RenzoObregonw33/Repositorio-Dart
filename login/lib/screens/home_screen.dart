import 'package:flutter/material.dart';  //Importa el paquete principal de Flutter con todos los widgets visuales.

class HomeScreem extends StatelessWidget {

//Parametros
  final String nombre;
  final String apellido;
  final String ruc;

//Constructor
  const HomeScreem({  
    super.key,
    required this.nombre,
    required this.apellido,
    required this.ruc,
  });

//Metodo que construye el UI widget
  @override
  Widget build(BuildContext context) {

    //Convierte la cadena ruc en una lista de organizaciones, elimina vacio
    final List<String> organizaciones = ruc.split(',').where((e) => e.trim().isNotEmpty).toList();  //trim se usa para eliminar espacios vacios

    //estructura base
    return Scaffold(
      appBar: AppBar(                               //Muestra la barra superior
        title: Text('Organizacion'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),             //Icono flecha atras
          onPressed: () {
            Navigator.pop(context, 'logout');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),               //icono de salida
            onPressed: () {
              Navigator.pop(context, 'logout');    //Regresa al usuario a la pantalla anterior
            },
            tooltip: 'Cerrar sesión',             //muestra un mensaje flotante
          ),
        ],
      ),
      body: Padding(                                //Cuerpo redondeado en un padding de 16px del box
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(                                   //organiza en una fila horizontal   
              children: [
                CircleAvatar(                      //Icono circular del Usuario 
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 30, color: Colors.grey.shade700),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Hola, $nombre $apellido',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),                  //texto 
            Text(
              'Organizaciones vinculadas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(                               //esto crea una lista 
              child: ListView.builder(              //crea Listas Dinamicas jala datos de una BD o una API
                itemCount: organizaciones.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(Icons.business, color: Colors.blueAccent),
                      title: Text(organizaciones[index]),
                      onTap: () {
                        // Acción cuando el usuario selecciona una organización
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}