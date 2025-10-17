import 'package:flutter/material.dart';
import 'package:login/screens/tabs_dashboard_screen.dart';


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

  // Método para cerrar sesión 
  void _cerrarSesion(BuildContext context) async { 
    //Mostrar diálogo de confirmación 
    final confirmar = await showDialog( 
      context: context, 
      builder: (BuildContext context) { 
        return AlertDialog( 
          title: Text('Cerrar sesión', style: TextStyle(fontFamily: '-apple-system')), 
          content: Text('¿Estás seguro de que quieres cerrar sesión?', style: TextStyle(fontFamily: '-apple-system')), 
          actions: [ 
            TextButton( 
              onPressed: () => Navigator.of(context).pop(false), child: Text('Cancelar', style: TextStyle(color: Color(0xFF3E2B6A))), 
            ), 
            TextButton( 
              onPressed: () => Navigator.of(context).pop(true), child: Text('Cerrar sesión', style: TextStyle(color: Colors.red)), 
            ), 
          ], 
        );
      }, 
    ); 
    if (confirmar == true) { 
      // ✅ NO eliminar las credenciales - SOLO CERRAR SESIÓN 
      print('🚪 Cerrando sesión (credenciales se mantienen guardadas)');
      // Regresar al login con el mensaje de logout 
      Navigator.pop(context, 'logout');
    }
  }

//Metodo que construye el UI widget
  @override
  Widget build(BuildContext context) {

    //estructura base
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3E2B6A),   
        automaticallyImplyLeading: false, // Elimina la flecha de retroceso
        // BOTÓN DE CERRAR SESIÓN A LA IZQUIERDA 
        leading: IconButton( 
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), 
          onPressed: () => _cerrarSesion(context), 
          tooltip: 'Cerrar sesión', 
        ), // TÍTULO CENTRADO 
        title: Text( 
          'Organización',
          style: TextStyle(
            color: Colors.white, 
            fontFamily: '-apple-system', 
            fontSize: 20, 
            fontWeight: FontWeight.w500 
          ), 
        ), 
        centerTitle: true, // ✅ Centra el título 
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
                      child: fotoUrl.isNotEmpty && fotoUrl != 'null'
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
                  ],
                ),
                
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                          decoration: BoxDecoration(
                            color: Color(0xFF72C8C0),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Color(0xFF72C8C0),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '$nombre $apellido',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                        ),
                        Text(
                          'ADMINISTRADOR',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                        ),
                      ]
                    ),
                  ),
                ],
              ),
            SizedBox(height: 24),                  //texto 
            Text(
              'Mis organizaciones:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
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
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4), // Tarjeta cuadrada
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
                                  Icon(Icons.domain, color: Color(0xFF3E2B6A), size: 28),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      razonSocial ?? 'Sin razón social',
                                      style: TextStyle(
                                        color: Colors.black,
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
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400
                                ),
                              ),
                              SizedBox(height: 8), // Espacio reducido
                              Text(
                                'Tipo: $tipo',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 2), // Espacio reducido
                              Text(
                                'Cantidad de empleados: ${org['cantidad_empleados_lumina'] ?? '0'}',
                                style: TextStyle(
                                  color: Colors.black,
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