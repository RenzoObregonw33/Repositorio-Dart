import 'package:flutter/material.dart';
import 'package:login/screens/dashboad_main_screen.dart';
//import 'package:login/screens/dashboard_screen.dart';  //Importa el paquete principal de Flutter con todos los widgets visuales.


class HomeScreem extends StatelessWidget {

//Parametros
  final String nombre;
  final String apellido;
  final String token;
  final List<Map<String, dynamic>> organizaciones;

//Constructor
  const HomeScreem({  
    super.key,
    required this.nombre,
    required this.apellido,
    required this.organizaciones, 
    required this.token,
  });

//Metodo que construye el UI widget
  @override
  Widget build(BuildContext context) {

    //estructura base
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EB),
      appBar: AppBar(                               //Muestra la barra superior
        title: Text('Organización', style: TextStyle(fontFamily: '-apple-system'),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.0,),             //Icono flecha atras
          onPressed: () {
            Navigator.pop(context, 'logout');
          },
        ),
        /*actions: [
          IconButton(
            icon: Icon(Icons.logout),               //icono de salida
            onPressed: () {
              Navigator.pop(context, 'logout');    //Regresa al usuario a la pantalla anterior
            },
            tooltip: 'Cerrar sesión',             //muestra un mensaje flotante
          ),
        ],*/
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
                  backgroundColor:  Color(0xFFF3C86C),
                  child: Text('V', style: TextStyle(color: Colors.white, fontSize: 30,fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '$nombre $apellido',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),                  //texto 
            Text(
              'Mis Organizaciones:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            ),
            SizedBox(height: 10),
            Expanded(                               //esto crea una lista 
              child: ListView.builder(              //crea Listas Dinamicas jala datos de una BD o una API
                itemCount: organizaciones.length,
                itemBuilder: (context, index) {

                  final org = organizaciones[index];

                  // Accediendo a los datos de la organización
                  final razonSocial = org['razonSocial'];
                  final ruc = org['ruc'];
                  final id = org['id'];
                  
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardMainScreen(
                            organiId: int.parse(org['id'].toString()),
                            token: token,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shadowColor: Color(0xFFF3B83C),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Tarjeta cuadrada
                        side: BorderSide(color: const Color(0xFFFFF8EB),width: 2),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.domain, color: Color(0xFFF3B83C), size: 28),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    razonSocial,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              'RUC: $ruc',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              'ID: $id',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
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