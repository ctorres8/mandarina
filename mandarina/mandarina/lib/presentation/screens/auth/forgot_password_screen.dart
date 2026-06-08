import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/screens/auth/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  static const name = 'forgot_password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Para mostrar el Spinner de carga

  Future<void> _sendResetEmail() async {

    // valido el formulario
    if (!_formKey.currentState!.validate()) {
      return; // Si hay error (ej: campo vacío), cortamos la ejecución aquí
    }

    // Spinner cargando
    setState(() {
      _isLoading = true;
    });

    // Simulo la demora de red (2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    // Quitamos el estado de carga
    setState(() {
      _isLoading = false;
    });

    // Si el widget sigue "vivo" en pantalla, mostramos el diálogo
    if (!mounted) return;
    _showMyDialog();
  }

  @override
  void dispose(){
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MandarinaAppTheme.primaryColor,//colors.primary,
      appBar: AppBar(
        leading: IconButton( 
          onPressed: ()=> context.pop(), 
          icon: const Icon(Icons.arrow_back)),
        iconTheme: const IconThemeData(color: MandarinaAppTheme.whiteColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Restablecer contraseña',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 35,
                  color: MandarinaAppTheme.whiteColor, //colors.onPrimary,
                  fontWeight: FontWeight.w600
                ),
              ),
              const SizedBox(height: 15,),
              Text(
                'Ingresa tu casilla de email debajo y te envíaremos un correo para restablecer tu contraseña.',
                style: TextStyle(
                  fontSize: 15,
                  color:MandarinaAppTheme.whiteColor,//colors.onPrimary
                ),
              ),

              const SizedBox(height: 30,),

              Form(
                key: _formKey,
                child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      cursorColor: MandarinaAppTheme.accentColor,//colors.tertiary,
                      style: TextStyle(
                        color: MandarinaAppTheme.accentColor,//colors.tertiary,
                        fontWeight: FontWeight.w700
                      ),
                      //style: GoogleFonts.openSans(color:MandarinaAppTheme.fontBlueColor,),
                      decoration: InputDecoration(
                        hintText: 'Email',
                      ),
                      validator: (value){
                        if (value==null || value.isEmpty){
                          return 'Por favor ingrese un email válido.';
                        }
                        return null;
                      },
                  ),
              ),

              const SizedBox(height: 20,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.5,
                  backgroundColor: MandarinaAppTheme.secondaryColor,
                  foregroundColor: MandarinaAppTheme.accentColor,
                  disabledBackgroundColor: MandarinaAppTheme.secondaryColor.withValues(alpha: 0.8),
                  disabledForegroundColor: MandarinaAppTheme.accentColor,
                  // Definimos el tamaño aquí. El double.infinity lo hace ancho completo.
                  minimumSize: const Size(double.infinity, 60), 
                  // Al resetear el padding, el botón usa su lógica interna de centrado
                  padding: EdgeInsets.zero, 
                  //shape: RoundedRectangleBorder(
                  //  borderRadius: BorderRadius.circular(15),
                  //),
                ),
                onPressed: _isLoading ? null : _sendResetEmail,
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(
                        color: MandarinaAppTheme.accentColor,
                        strokeWidth: 2,
                      ),
                    ) 
                  : const Text(
                      'Enviar correo',
                      style: TextStyle(
                        fontSize: 25, // Un pelín más chico para que respire mejor
                        fontWeight: FontWeight.w700,
                        // El height: 1.0 es clave para quitar espacios extra de la fuente Quicksand
                        height: 1.0, 
                      ),
                    ),
              )
            ]
          ),
        )
      )
    );
  }

  void _showMyDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: MandarinaAppTheme.secondaryColor, // Tu crema de Mandarina
        title: Column(
          children: [
            //Center(child: Image.asset('assets/images/logo_naranja.png',scale:15,)),
            const Text(
              '¡Mail enviado!', 
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MandarinaAppTheme.accentColor,
                fontSize: 26,
                fontWeight: FontWeight.w900
              ),
            ),
          ],
        ),
        content: const Text(
          'Revisa tu casilla para cambiar la contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MandarinaAppTheme.accentColor,
            fontSize: 15,
            fontWeight: FontWeight.w800
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el dialog
              // Aquí podrías usar context.pop() de GoRouter para volver al login
            },
            //style: ElevatedButton.styleFrom(
            //  backgroundColor: MandarinaAppTheme.accentColor,
            //),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                color: MandarinaAppTheme.blueColor,
                fontSize: 18,
                fontWeight: FontWeight.w900
              ),
            ),
          ),
        ],
      );
    },
  );
}
}


