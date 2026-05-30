import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/screens/auth/forgot_password_screen.dart';
import 'package:mandarina/presentation/screens/home_screen.dart';
import 'package:mandarina/presentation/screens/landing_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const name = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  bool obscText = false;

  @override
  Widget build(BuildContext context) {
    //final colors = Theme.of(context).colorScheme;
    //final textStyles = Theme.of(context).textTheme;

    @override
    void dispose(){
      _emailController.dispose();
      _passwordController.dispose();

      super.dispose();
    }

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
                '¡Hola de nuevo!',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 35,
                  color: MandarinaAppTheme.whiteColor, //colors.onPrimary,
                  fontWeight: FontWeight.w600
                ),
              ),
              Text(
                'Estamos contentos de verte otra vez.',
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
                    const SizedBox(height: 20,),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      autocorrect: false,
                      cursorColor: MandarinaAppTheme.accentColor,//colors.tertiary,
                      style: TextStyle(
                        color: MandarinaAppTheme.accentColor,//colors.tertiary,
                        fontWeight: FontWeight.w700
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
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: (){
                    //dispose();
                    FocusManager.instance.primaryFocus?.unfocus();
                    context.pushNamed(ForgotPasswordScreen.name);
                  },
                  child: Text(
                    'Olvidé mi contraseña',
                    style: TextStyle(
                      color: MandarinaAppTheme.blueColor,//colors.onSurface
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,                      
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.5,
                  backgroundColor: MandarinaAppTheme.secondaryColor,//colors.tertiary,
                  foregroundColor: MandarinaAppTheme.accentColor,//colors.onTertiary,
                  minimumSize: const Size(double.infinity, 60), 
                  padding: EdgeInsets.zero, 
                ),
                onPressed: (){}, // TODO: Ingresar al Home
                child: const Text(
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
                onPressed: (){ context.goNamed(HomeScreen.name);}, // TODO: Ingresar con Google
                child: const Text(
                  'Ingresar con Google',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),

              const SizedBox(height: 70,),

              Center(child: Image.asset('assets/images/logo_blanco.png',scale:3,)),

            ],
          ),
        ),
      )
    );
  }
}