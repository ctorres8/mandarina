import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/screens/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static const name = "signup_screen";

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  bool obscText = false;

  Future<void> _goToHome() async {

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
    context.goNamed(HomeScreen.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MandarinaAppTheme.primaryColor,
      appBar: AppBar(
        leading: IconButton( 
          onPressed: ()=> context.pop(), 
          icon: const Icon(Icons.arrow_back)),
        iconTheme: const IconThemeData(color: MandarinaAppTheme.whiteColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsGeometry.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido/a!',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 35,
                  color: MandarinaAppTheme.whiteColor, //colors.onPrimary,
                  fontWeight: FontWeight.w600
                ),
              ),
              Text(
                'Te pedimos un mail para registrarte.',
                style: TextStyle(
                  fontSize: 18,
                  color:MandarinaAppTheme.whiteColor,//colors.onPrimary
                ),
              ),

              const SizedBox(height: 40,),

              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      //const SizedBox(height: 10,),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      cursorColor: MandarinaAppTheme.accentColor,//colors.tertiary,
                      style: TextStyle(
                        //color: MandarinaAppTheme.accentColor,//colors.tertiary,
                        //fontWeight: FontWeight.w700
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

                    const SizedBox(height: 20,),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      autocorrect: false,
                      cursorColor: MandarinaAppTheme.accentColor,//colors.tertiary,
                      style: TextStyle(
                        //color: MandarinaAppTheme.accentColor,//colors.tertiary,
                        //fontWeight: FontWeight.w700
                      ),
                      decoration:InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Contraseña',
                        suffixIcon: IconButton(
                          onPressed: (){
                            setState(() {
                              _isPasswordVisible= !_isPasswordVisible;
                            });
                          }, 
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: MandarinaAppTheme.accentColor,//colors.tertiary,
                          ),
                        ),
                      ),
                      validator: (value){
                        if (value==null || value.isEmpty){
                          return 'Por favor, ingrese una contraseña.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20,),
                    
                    TextFormField(
                      controller: _passwordConfirmController,
                      obscureText: !_isPasswordConfirmVisible,
                      autocorrect: false,
                      cursorColor: MandarinaAppTheme.accentColor,//colors.tertiary,
                      style: TextStyle(
                        //color: MandarinaAppTheme.blueColor,//colors.tertiary,
                        //fontWeight: FontWeight.w700
                      ),
                      decoration:InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Confirmar Contraseña',
                        suffixIcon: IconButton(
                          onPressed: (){
                            setState(() {
                              _isPasswordConfirmVisible= !_isPasswordConfirmVisible;
                            });
                          }, 
                          icon: Icon(
                            _isPasswordConfirmVisible ? Icons.visibility : Icons.visibility_off,
                            color: MandarinaAppTheme.accentColor,//colors.tertiary,
                          ),
                        ),
                      ),
                      validator: (value){
                        if (value==null || value.isEmpty){
                          return 'Por favor, ingrese una contraseña.';
                        }else if (value != _passwordController.text){
                          return 'Las contraseñas no coinciden.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30,),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.5,
                        backgroundColor: MandarinaAppTheme.secondaryColor,//colors.tertiary,
                        foregroundColor: MandarinaAppTheme.accentColor,//colors.onTertiary,
                        disabledBackgroundColor: MandarinaAppTheme.secondaryColor.withValues(alpha: 0.8),
                        disabledForegroundColor: MandarinaAppTheme.accentColor,
                        minimumSize: const Size(double.infinity, 60), 
                        padding: EdgeInsets.zero, 
                      ),
                      onPressed: _isLoading ? null : _goToHome, // TODO: Ingresar al Home
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
                          'Ingresar',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                    ),

                    const SizedBox(height: 15,),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.5,
                        backgroundColor: MandarinaAppTheme.secondaryColor,//colors.tertiary,
                        foregroundColor: MandarinaAppTheme.accentColor,//colors.onTertiary,
                        minimumSize: const Size(double.infinity, 60), 
                        padding: EdgeInsets.zero, 
                      ),
                      onPressed: (){context.goNamed(HomeScreen.name);}, // TODO: Ingresar con Google
                      child: const Text(
                        'Ingresar con Google',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40,),

                    Center(child: Image.asset('assets/images/logo_blanco.png',scale:3,)),
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