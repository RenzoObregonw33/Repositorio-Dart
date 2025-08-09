import 'package:flutter/material.dart';
import 'package:login/screens/dashboard_screen.dart';
import 'package:login/screens/tabs_dashboard_screen.dart';
//import 'package:login/screens/dashboard_screen.dart';  //Importa el paquete principal de Flutter con todos los widgets visuales.


class HomeScreem extends StatelessWidget {

//Parametros
  final String nombre;
  final String apellido;
  final String token;
  final List<Map<String, dynamic>> organizaciones;
  final String rolNombre; // Nuevo
  final int rolId; // Nuevo
  final String fotoUrl; // Nuevo

//Constructor
  const HomeScreem({  
    super.key,
    required this.nombre,
    required this.apellido,
    required this.organizaciones, 
    required this.token, 
    required this.rolNombre, 
    required this.rolId, 
    required this.fotoUrl,
  });

//Metodo que construye el UI widget
  @override
  Widget build(BuildContext context) {

    //estructura base
    return Scaffold(
      appBar: AppBar(                               //Muestra la barra superior
        title: Text('Organización', style: TextStyle(fontFamily: '-apple-system'),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.0,),             //Icono flecha atras
          onPressed: () {
            Navigator.pop(context, 'logout');
          },
        ),
      ),
      body: Padding(                                //Cuerpo redondeado en un padding de 16px del box
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(                                   //organiza en una fila horizontal   
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300], // Color de fondo si no hay imagen
                      child: fotoUrl != null && fotoUrl.isNotEmpty && fotoUrl != 'null'
                          ? ClipOval(
                              child: Image.network(
                                fotoUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.white,
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(
                        '$nombre $apellido',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                      ),
                      Text(
                        'ADMINISTRADOR',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                      ),
                    ]
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),                  //texto 
            Text(
              'Mis Organizaciones:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            ),
            SizedBox(height: 20),
            Expanded(                               //esto crea una lista 
              child: ListView.separated(              //crea Listas Dinamicas jala datos de una BD o una API
                itemCount: organizaciones.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {

                  final org = organizaciones[index];

                  // Validación básica
                  final razonSocial = org['razonSocial'];
                  final ruc = org['ruc'];
                  final tipo = org['tipo'];


                  //final id = org['id'];
                  
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TabsDashboardScreen(
                            organiId: int.parse(org['id'].toString()),
                            token: token,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Color(0xFFF8A835),
                      shadowColor: Colors.black, // Color de sombra
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Tarjeta cuadrada
                        
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [ Color(0xFFFFA528), Color(0xFFF77B09),],
                            stops: [0.1, 0.9],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          color: Color(0xFFF8A835),
                          borderRadius: BorderRadius.circular(20), // Tarjeta cuadrada
                        ),
                        
                        padding: const EdgeInsets.all(16),
                        constraints: BoxConstraints(minHeight: 140), // Altura mínima aumentada
                        child: SingleChildScrollView( // Permite scroll si el contenido es muy largo
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // Ocupa solo el espacio necesario
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.domain, color: Colors.black, size: 28),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      razonSocial ?? 'Sin razón social',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18, // Reducido ligeramente
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8), // Espacio reducido
                              Text(
                                'RUC: $ruc',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              SizedBox(height: 8), // Espacio reducido
                              Text(
                                'Tipo: $tipo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 2), // Espacio reducido
                              Text(
                                'Cantidad de empleados: ${org['cantidad_empleados_lumina'] ?? '0'}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )  
                      ),
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