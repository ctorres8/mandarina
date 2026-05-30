import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/presentation/widgets/numbersWidget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String name = "profile_screen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return ProfileScreenView();
  }
}

class ProfileScreenView extends StatelessWidget {
  const ProfileScreenView({super.key});

  final double coverHeight = 280;
  final double profileHeight = 180;

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            //MandarinaAppTheme.accentColor,
            //MandarinaAppTheme.primaryColor,
            MandarinaAppTheme.whiteColor,
            MandarinaAppTheme.secondaryColor,
            //MandarinaAppTheme.blueColor,
            //MandarinaAppTheme.darkBlueColor,
          ],
          stops: const [0.8, 1.0],
        ),
      ),
      child: Scaffold(
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
        body: LayoutBuilder( // 1. Usamos LayoutBuilder para medir la pantalla
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  buildTop(),
                  buildContent()
                ]
              ),
            );
          },
        ),
      ),
    );
  }

  /* TOP */

  Widget buildTop() {
    final double topPosition = coverHeight - (profileHeight / 2);
    final double bottomPosition = profileHeight / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottomPosition),
          child: buildCoverImage()
        ),
        Positioned(
          top: topPosition,
          child: buildProfileImage()
        ),
      ],
    );
  } 

  Widget buildCoverImage() => Container(
    child: Image.network(
      'https://www.wonderfulpcb.com/wp-content/uploads/2025/10/a857b4017ca84ce9b695693187675c51.jpg',
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    ),
    /*Image.asset(
      'assets/images/logo_color.png',
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    ),*/

  );

  Widget buildProfileImage() => CircleAvatar(
    radius: profileHeight / 2,
    backgroundColor: const Color(0xFF7A869A),
    backgroundImage: NetworkImage(
      'https://t4.ftcdn.net/jpg/03/76/47/81/360_F_376478182_yPuPo2qi6rYcu9ilwGWR6gQ7QBBC8Isw.jpg',
    ),
    //const Text("Foto", style: TextStyle(color: Colors.white)),
  );

  /* CONTENT */

  Widget buildContent(){
    String text = lorem(paragraphs: 2,words: 60);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Paola Argento',
            style: GoogleFonts.quicksand(
              color: MandarinaAppTheme.blueColor,
              fontSize: 28,
              fontWeight: FontWeight.w700
            ),
          ),
          Text(
            'Ingeniera Electrónica',
            style: GoogleFonts.quicksand(
              color: MandarinaAppTheme.blueColor.withValues(alpha: 0.3),
              fontSize: 20,
              fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSocialIcon(FontAwesomeIcons.linkedin),
              const SizedBox(width: 15,),
              buildSocialIcon(FontAwesomeIcons.instagram),
              const SizedBox(width: 15,),
              buildSocialIcon(FontAwesomeIcons.link),

            ],
          ),
          const SizedBox(height: 20,),
          Divider(color: MandarinaAppTheme.primaryColor.withValues(alpha: 0.1),),
          const SizedBox(height: 20,),
          NumbersWidget(),
          const SizedBox(height: 20,),
          Divider(color: MandarinaAppTheme.primaryColor.withValues(alpha: 0.1),),
          const SizedBox(height: 20,),
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre mí',
                  style: GoogleFonts.quicksand(
                    color: MandarinaAppTheme.accentColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700
                  ),
                ),
                Text(
                  text,
                  style: GoogleFonts.quicksand(
                    color: MandarinaAppTheme.blueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildSocialIcon(FaIconData icon) => CircleAvatar(
    backgroundColor: MandarinaAppTheme.primaryColor,
    radius: 30,
    child: Material(
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: InkWell(
        onTap: (){},
        child: Center(
          child: FaIcon(
            icon,
            size: 35,
            color: MandarinaAppTheme.whiteColor,
          ),
        ),
      )
    ),
  );
}