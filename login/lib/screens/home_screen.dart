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
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green, // Color del borde
                      width: 3.0,          // Grosor del borde
                    ),
                  ),
                  child:  CircleAvatar(                      //Icono circular del Usuario 
                    radius: 30,
                    backgroundColor:  Colors.transparent,
                    //child: Text('V', style: TextStyle(color: Colors.black, fontSize: 30,fontWeight: FontWeight.bold)),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/MG.jpeg', // Asegúrate de que la imagen esté en la carpeta assets
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover, // Ajusta la imagen para que ocupe todo el círculo
                      ),
                    ),
                  ),
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
                        width: double.infinity,
                        height: 120,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.domain, color: Colors.black, size: 28),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    razonSocial,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'ID: $id',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 14,
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