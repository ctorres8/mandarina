import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mandarina/core/theme/app_theme.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});
  static const String name = "pet_screen";

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  @override
  Widget build(BuildContext context) {
    return PetScreenView();
  }
}

class PetScreenView extends StatelessWidget {
  const PetScreenView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            //MandarinaAppTheme.accentColor,
            MandarinaAppTheme.primaryColor,
            //MandarinaAppTheme.accentColor,
            //MandarinaAppTheme.accentColor,
            MandarinaAppTheme.secondaryColor,
            //MandarinaAppTheme.secondaryColor,
            //MandarinaAppTheme.primaryColor,
            //MandarinaAppTheme.whiteColor,
            //MandarinaAppTheme.blueColor,
            //MandarinaAppTheme.blueColor,
            //MandarinaAppTheme.darkBlueColor,
          ],
          stops: const [0.1, 0.7],
        ),
      ),
      child: _MainPetScreen(),//_OnboardingPetScreen(),
    );
  }
}

class _OnboardingPetScreen extends StatelessWidget {
  const _OnboardingPetScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(CupertinoIcons.arrow_left, color: MandarinaAppTheme.whiteColor,),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //SizedBox(height: 50),
            Container(
              width: 300,
              height: 300,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: MandarinaAppTheme.whiteColor,
                  width: 2.0,
                )
              ),
              child: Transform.scale(
                scale: 1.2,
                child: Center(child: FlutterLogo(size: 300,))
              ),
            ),
            //SizedBox(height: 100,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'Soy tu nuevo compañero de estudio.\n¡Cuidar de tu tiempo es cuidar de mi!',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  color: MandarinaAppTheme.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700
                )
              ),
            ),
    
            //SizedBox(height: 20,),
    
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0.5,
                backgroundColor: MandarinaAppTheme.whiteColor,//colors.tertiary,
                foregroundColor: MandarinaAppTheme.primaryColor,//colors.onTertiary,
                minimumSize: const Size(double.infinity, 60), 
                padding: EdgeInsets.zero, 
              ),
              onPressed: () {}, // TODO: Ir a registrarse
              child: Text(
                'Continuar',
                style: GoogleFonts.quicksand(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
                          ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainPetScreen extends StatelessWidget {
  const _MainPetScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const FaIcon(
            FontAwesomeIcons.circleChevronLeft, 
            color: MandarinaAppTheme.primaryColor,
            size: 30,
          ),
        ),
        title: Text(
          'Mandarina PET',
          style: GoogleFonts.quicksand(
            color: MandarinaAppTheme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                      width: 300,
                      height: 300,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: MandarinaAppTheme.whiteColor.withValues(alpha: 0.2),
                          width: 1.0,
                        )
                      ),
                      child: Transform.scale(
                        scale: 1.4,
                        child: Transform.translate(
                          offset: const Offset(0, 24),
                          child: Center(
                            child: Lottie.asset(
                              'assets/lotties/pet_robot.json',
                              fit: BoxFit.cover,
                              alignment: Alignment.center
                            ),
                          ),
                        )
                      ),
                  ),
                  Bubble(top:-60,right:-25,icon: FontAwesomeIcons.paw),
                  Bubble(bottom:-40,right: -30,icon:FontAwesomeIcons.solidHeart),
                  Bubble(top:-40,left: -35,icon:FontAwesomeIcons.bolt),
                  Bubble(bottom:-50,left: -20,icon:FontAwesomeIcons.gear),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'Conecta para que empecemos a trabajar juntos.',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  color: MandarinaAppTheme.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700
                )
              ),
            ),
    
            //SizedBox(height: 30,),
    
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.5,
                  backgroundColor: MandarinaAppTheme.whiteColor,//colors.tertiary,
                  foregroundColor: MandarinaAppTheme.primaryColor,//colors.onTertiary,
                  minimumSize: const Size(double.infinity, 60), 
                  padding: EdgeInsets.zero, 
                ),
                onPressed: () {}, // TODO: Ir a registrarse
                child: Text(
                  'Conectar',
                  style: GoogleFonts.quicksand(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  const Bubble({
    super.key,
    this.top,
    this.bottom,
    this.right,
    this.left,
    required this.icon,
  });

  final double? top;
  final double? bottom;
  final double? right;
  final double? left;
  final FaIconData icon;


  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,//-70,
      bottom:bottom,
      right: right,//-25,
      left:left,
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: MandarinaAppTheme.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: MandarinaAppTheme.darkBlueColor,
              blurRadius: 1,
              spreadRadius: 0,
              blurStyle: BlurStyle.solid,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: MandarinaAppTheme.darkBlueColor.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
        ),
        child: FaIcon(
          icon,
          color: MandarinaAppTheme.whiteColor,
          size: 40,
        ),
      ),
    );
  }
}