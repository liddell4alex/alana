import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
  
final autenticador = LocalAuthentication();

Future<void> accederConHuella(BuildContext context, Widget pantalla) async {
  try {
    final autenticado = await autenticador.authenticate(
      localizedReason: 'Lector de huellas para ALANA',
      biometricOnly: false,
    );

    if(!context.mounted) return;

    if(autenticado) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => pantalla,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autenticación cancelada o fallida'),
        ),
      );
    }
  } catch(e) {
    if(!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo realizar la autenticación biométrica'),
      ),
    );

    
  }
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final controlador = TextEditingController();

  bool passwdObscure = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alana gestor de contraseñas'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bienvenido'),
              //Text('Introduce tu contraseña'),
              //SizedBox(
              //  width: 200,
              //  child: TextField(
              //    controller: controlador,
              //    obscureText: passwdObscure,  // Pa que no se vea la contraseña
              //    decoration: InputDecoration(
              //      labelText: 'Contraseña',
              //      border: OutlineInputBorder(),
              //      suffixIcon: IconButton(
              //        
              //        icon: Icon(
              //          passwdObscure ? Icons.visibility : Icons.visibility_off,
              //        ),

              //        onPressed: () {
              //          setState(() {
              //            passwdObscure = !passwdObscure;
              //          });
              //        },

              //      ),
              //    ),
              //  )
              //),
              Builder(
                builder: (context) {
                  return ElevatedButton (
                    onPressed: () {
                      accederConHuella(context, const PantallaPrincipal());
                    }, 
                    child: const Text('Acceder'),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // Temporal: Lista de cuentas almacenadas 
  final List<Cuenta> cuentas = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Mis credenciales'),
      ),

      body: Column(
        children: [ 
          ElevatedButton(
            onPressed: () async {
              final cuenta = await Navigator.push<Cuenta>(
                context,
                MaterialPageRoute(
                  builder: (context) => const AgregarCuenta()
                ),
              );

              if(cuenta != null) {
                setState(() {
                  cuentas.add(cuenta);
                });
              }
 
            }, 
            
            child: const Text('Agregar cuenta'),            
          
          ),

          Expanded(
            child: ListView.builder(
              itemCount: cuentas.length,
              itemBuilder: (context, indice) {
                final cuenta = cuentas[indice];

                return Card(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),

                  child: ListTile(
                    title: Text(cuenta.service),
                    subtitle: Text(cuenta.user),
                    
                    onTap: () {
                      accederConHuella(context, PantallaDetalles(cuenta: cuenta));
                    },
                  ), 
                );    
              },
            ),
          ) 
        ],

      ),

    );
  }
}

class AgregarCuenta extends StatefulWidget {
  // Para reutilizar al editar
  final Cuenta ? cuenta;  // Si la clase se llama con una cuenta se almacena si no es null

  const AgregarCuenta({
    super.key,
    this.cuenta
  });

  @override
  State<AgregarCuenta> createState() => _AgregarCuentaState();
}

class _AgregarCuentaState extends State<AgregarCuenta> {
  final serviceControlador = TextEditingController();
  final userControlador = TextEditingController();
  final passwdControlador = TextEditingController();

  bool passwdObscure = true;

  @override
  void initState() {
    super.initState();

    if(widget.cuenta != null) {
      serviceControlador.text = widget.cuenta!.service;
      userControlador.text = widget.cuenta!.user;
      passwdControlador.text = widget.cuenta!.passwd;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(widget.cuenta == null ? "Agregar cuenta" : "Editar credenciales"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            
            // Primera caja para recibir nombre del servicio
            const SizedBox(
              height: 15,
            ), 
            TextField(
              controller: serviceControlador,
              decoration: InputDecoration(
                labelText: widget.cuenta == null ? 'Servicio' : widget.cuenta!.service,
                border: OutlineInputBorder(),
              ),
            ),

            // Segunda caja para recibir nombre de usuario o correo del servicio
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: userControlador,
              decoration: InputDecoration(
                labelText: widget.cuenta == null ? 'Usuario o E-mail' : widget.cuenta!.user,
                border: OutlineInputBorder(),
              ),
            ),

            // Tercera caja para recibir la contraseña
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: passwdControlador,
              obscureText: passwdObscure,
              decoration: InputDecoration(
                labelText: widget.cuenta == null ? 'Contraseña' : widget.cuenta!.passwd,
                border: OutlineInputBorder(),
                suffixIcon: IconButton(

                  // Icono de ocular y desocultar contraseña
                  icon: Icon(
                    passwdObscure ? Icons.visibility : Icons.visibility_off,
                  ),

                  // Ocultar y desocultar contraseña
                  onPressed: () {
                    setState(() {
                      passwdObscure = !passwdObscure;
                    });
                  },

                
                ),
              ),
            ),

            // Boton de agregar
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () {
                
                final cuenta = Cuenta(
                  service: serviceControlador.text,
                  user: userControlador.text,
                  passwd: passwdControlador.text,
                );

                // Cierra la pantalla actual y manda la cuenta a la pantalla anterior
                Navigator.pop(context, cuenta); // Navigator maneja pantallas

              },
              
              child: Text(widget.cuenta == null ? 'Guardar credenciales' : 'Guardar cambios'),
            ),
          ],
        ),
      ),

    );
  }

  @override
  void dispose() {
    serviceControlador.dispose();
    userControlador.dispose();
    passwdControlador.dispose();
    super.dispose();
  }

}

class Cuenta {
  final String service;
  final String user;
  final String passwd;

  Cuenta({
    required this.service,
    required this.user,
    required this.passwd,
  });
}

class PantallaDetalles extends StatefulWidget {
  final Cuenta cuenta;

  const PantallaDetalles({
    super.key,
    required this.cuenta,
  });

  @override
  State<PantallaDetalles> createState() => _PantallaDetallesState();
}

class _PantallaDetallesState extends State<PantallaDetalles> {

  bool passwdObscure = true;

  Future<void> copiarText(String texto) async {
    await Clipboard.setData(
      ClipboardData(text: texto),
    );

    if(!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cuenta = widget.cuenta;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la cuenta'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Nombre del servicio
                    Row(
                      children: [
                        const Icon(Icons.miscellaneous_services_outlined, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(cuenta.service,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                    textAlign: TextAlign.start),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nombre de usuario/email
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(cuenta.user,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                    textAlign: TextAlign.start),
                        ),
                        IconButton(
                          tooltip: 'Copiar al portapapeles',
                          icon: Icon(Icons.copy),
                          onPressed: () { copiarText(cuenta.user); },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Contraseña
                    Row(
                      children: [
                        const Icon(Icons.key, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(passwdObscure ? '•'*cuenta.passwd.length : cuenta.passwd,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                    textAlign: TextAlign.start),
                        ),
                        IconButton(
                          tooltip: passwdObscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                          icon: Icon(passwdObscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              passwdObscure = !passwdObscure;
                            });
                          },
                        ),
                        IconButton(
                          tooltip: 'Copiar al portapapeles',
                          icon: const Icon(Icons.copy),
                          onPressed: () { copiarText(widget.cuenta.passwd); },
                        ),

                      ],
                    ),

                  ],
                ),
              ), 
            ),
              
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, 'eliminar');
              },
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar Cuenta'),
            ),

            ElevatedButton.icon(
              onPressed: () async {
                final cuentaEditada = await Navigator.push<Cuenta>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgregarCuenta(
                      cuenta: widget.cuenta,
                    ),
                  ),
                );

                if(cuentaEditada != null && context.mounted) {
                  Navigator.pop(context, cuentaEditada);
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar credenciales') 
            ),
          ],
        ),
      ),


    );
  }

}