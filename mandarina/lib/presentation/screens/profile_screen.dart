import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/domain/user_profile_model.dart';
import 'package:mandarina/presentation/widgets/numbersWidget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String name = "profile_screen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfileModel _profile;
  bool _isEditing = false;

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _professionController;
  late TextEditingController _biographyController;

  // Track social links in a mutable list during editing
  late List<String> _tempSocialLinks;
  
  // Track selected gender during editing
  late String _tempGender;
  
  // Controller for adding a new social link
  late TextEditingController _newSocialLinkController;

  final double coverHeight = 280;
  final double profileHeight = 180;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _profile = UserProfileModel(
      coverImageUrl: 'https://www.wonderfulpcb.com/wp-content/uploads/2025/10/a857b4017ca84ce9b695693187675c51.jpg',
      profileImageUrl: 'https://t4.ftcdn.net/jpg/03/76/47/81/360_F_376478182_yPuPo2qi6rYcu9ilwGWR6gQ7QBBC8Isw.jpg',
      name: 'Paola Argento',
      profession: 'Ingeniera Electrónica',
      socialLinks: [
        'https://linkedin.com/in/paola-argento',
        'https://instagram.com/paola-argento',
        'https://paola-argento.dev',
      ],
      biography: lorem(paragraphs: 2, words: 60),
      gender: 'Femenino',
      completedTasks: 234,
      focusMinutes: 15392,
      affinityLevel: 8,
    );
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: _profile.name);
    _professionController = TextEditingController(text: _profile.profession);
    _biographyController = TextEditingController(text: _profile.biography);
    _tempSocialLinks = List.from(_profile.socialLinks);
    _tempGender = _profile.gender;
    _newSocialLinkController = TextEditingController();
  }

  void _disposeControllers() {
    _nameController.dispose();
    _professionController.dispose();
    _biographyController.dispose();
    _newSocialLinkController.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _cancelEdits() {
    setState(() {
      _initControllers();
      _isEditing = false;
    });
  }

  void _saveEdits() {
    setState(() {
      _profile = _profile.copyWith(
        name: _nameController.text.trim(),
        profession: _professionController.text.trim(),
        biography: _biographyController.text.trim(),
        socialLinks: List.from(_tempSocialLinks),
        gender: _tempGender,
      );
      _isEditing = false;
    });
  }

  Future<void> _pickImage(bool isCover) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          if (isCover) {
            _profile = _profile.copyWith(coverImageUrl: pickedFile.path);
          } else {
            _profile = _profile.copyWith(profileImageUrl: pickedFile.path);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al seleccionar imagen: $e',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: MandarinaAppTheme.whiteColor),
          ),
          backgroundColor: MandarinaAppTheme.accentColor,
        ),
      );
    }
  }

  FaIconData _getSocialIcon(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('linkedin')) {
      return FontAwesomeIcons.linkedin;
    } else if (lower.contains('instagram')) {
      return FontAwesomeIcons.instagram;
    } else if (lower.contains('github')) {
      return FontAwesomeIcons.github;
    } else if (lower.contains('facebook')) {
      return FontAwesomeIcons.facebook;
    } else if (lower.contains('twitter') || lower.contains('x.com')) {
      return FontAwesomeIcons.xTwitter;
    } else if (lower.contains('youtube')) {
      return FontAwesomeIcons.youtube;
    }
    return FontAwesomeIcons.link;
  }

  FaIconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'femenino':
        return FontAwesomeIcons.venus;
      case 'masculino':
        return FontAwesomeIcons.mars;
      case 'transgénero':
      case 'transgenero':
        return FontAwesomeIcons.transgender;
      case 'no binario':
      case 'no-binario':
        return FontAwesomeIcons.genderless;
      case 'género fluido':
      case 'genero fluido':
        return FontAwesomeIcons.venusMars;
      case 'agénero':
      case 'agenero':
        return FontAwesomeIcons.neuter;
      default:
        return FontAwesomeIcons.asterisk;
    }
  }

  Color _getGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'femenino':
        return Colors.pink.shade400;
      case 'masculino':
        return Colors.blue.shade400;
      case 'transgénero':
      case 'transgenero':
        return Colors.purple.shade400;
      case 'no binario':
      case 'no-binario':
        return Colors.amber.shade600;
      case 'género fluido':
      case 'genero fluido':
        return Colors.teal.shade400;
      case 'agénero':
      case 'agenero':
        return Colors.blueGrey.shade400;
      default:
        return MandarinaAppTheme.blueColor.withValues(alpha: 0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            MandarinaAppTheme.whiteColor,
            MandarinaAppTheme.secondaryColor,
          ],
          stops: [0.8, 1.0],
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
            icon: const Icon(CupertinoIcons.arrow_left, color: MandarinaAppTheme.whiteColor),
          ),
          actions: [
            if (!_isEditing)
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: const Icon(Icons.edit, color: MandarinaAppTheme.whiteColor),
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  buildTop(),
                  buildContent(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /* TOP Section */
  Widget buildTop() {
    final double topPosition = coverHeight - (profileHeight / 2);
    final double bottomPosition = profileHeight / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottomPosition),
          child: buildCoverImage(),
        ),
        Positioned(
          top: topPosition,
          child: buildProfileImage(),
        ),
      ],
    );
  }

  Widget buildCoverImage() {
    final bool isNetwork = _profile.coverImageUrl.startsWith('http') || _profile.coverImageUrl.startsWith('https');

    return Stack(
      children: [
        isNetwork
            ? Image.network(
                _profile.coverImageUrl,
                width: double.infinity,
                height: coverHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildCoverPlaceholder(),
              )
            : Image.file(
                File(_profile.coverImageUrl),
                width: double.infinity,
                height: coverHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildCoverPlaceholder(),
              ),
        if (_isEditing)
          Positioned.fill(
            child: Material(
              color: const Color.fromRGBO(0, 0, 0, 0.4),
              child: InkWell(
                onTap: () => _pickImage(true),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt, color: Colors.white, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Cambiar Portada',
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: MandarinaAppTheme.primaryColor,
      width: double.infinity,
      height: coverHeight,
      child: const Icon(Icons.broken_image, color: Colors.white, size: 50),
    );
  }

  Widget buildProfileImage() {
    final bool isNetwork = _profile.profileImageUrl.startsWith('http') || _profile.profileImageUrl.startsWith('https');
    final ImageProvider imageProvider = isNetwork
        ? NetworkImage(_profile.profileImageUrl) as ImageProvider
        : FileImage(File(_profile.profileImageUrl)) as ImageProvider;

    return Stack(
      children: [
        CircleAvatar(
          radius: profileHeight / 2,
          backgroundColor: const Color(0xFF7A869A),
          backgroundImage: imageProvider,
        ),
        if (_isEditing)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: ClipOval(
                child: Material(
                  color: const Color.fromRGBO(0, 0, 0, 0.45),
                  child: InkWell(
                    onTap: () => _pickImage(false),
                    child: SizedBox(
                      width: profileHeight,
                      height: profileHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            'Cambiar Foto',
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /* CONTENT Section */
  Widget buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_isEditing) ...[
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.quicksand(
                color: MandarinaAppTheme.blueColor,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: GoogleFonts.quicksand(color: MandarinaAppTheme.blueColor, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _professionController,
              style: GoogleFonts.quicksand(
                color: MandarinaAppTheme.blueColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'Profesión',
                labelStyle: GoogleFonts.quicksand(color: MandarinaAppTheme.blueColor, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _tempGender,
              items: [
                'Femenino',
                'Masculino',
                'Transgénero',
                'No binario',
                'Género fluido',
                'Agénero',
                'Prefiero no especificar',
              ].map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        _getGenderIcon(val),
                        color: _getGenderColor(val),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        val,
                        style: GoogleFonts.quicksand(
                          color: MandarinaAppTheme.blueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Género',
                labelStyle: GoogleFonts.quicksand(color: MandarinaAppTheme.blueColor, fontWeight: FontWeight.w600),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tempGender = value;
                  });
                }
              },
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _profile.name,
                  style: GoogleFonts.quicksand(
                    color: MandarinaAppTheme.blueColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Género: ${_profile.gender}',
                  child: FaIcon(
                    _getGenderIcon(_profile.gender),
                    color: _getGenderColor(_profile.gender),
                    size: 24,
                  ),
                ),
              ],
            ),
            Text(
              _profile.profession,
              style: GoogleFonts.quicksand(
                color: MandarinaAppTheme.blueColor.withValues(alpha: 0.5),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          
          if (_isEditing)
            buildSocialLinksEditSection()
          else
            buildSocialLinksRow(),

          const SizedBox(height: 20),
          Divider(color: MandarinaAppTheme.primaryColor.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          
          // NumbersWidget is strictly Read-Only
          NumbersWidget(
            completedTasks: _profile.completedTasks,
            focusMinutes: _profile.focusMinutes,
            affinityLevel: _profile.affinityLevel,
          ),
          
          const SizedBox(height: 20),
          Divider(color: MandarinaAppTheme.primaryColor.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre mí',
                  style: GoogleFonts.quicksand(
                    color: MandarinaAppTheme.accentColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                if (_isEditing)
                  TextFormField(
                    controller: _biographyController,
                    maxLines: null,
                    minLines: 3,
                    style: GoogleFonts.quicksand(
                      color: MandarinaAppTheme.blueColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Escribe algo sobre ti...',
                      hintStyle: GoogleFonts.quicksand(
                        color: MandarinaAppTheme.blueColor.withValues(alpha: 0.4),
                      ),
                    ),
                  )
                else
                  Text(
                    _profile.biography,
                    style: GoogleFonts.quicksand(
                      color: MandarinaAppTheme.blueColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          if (_isEditing) ...[
            const SizedBox(height: 30),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _cancelEdits,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveEdits,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MandarinaAppTheme.primaryColor,
                      foregroundColor: MandarinaAppTheme.whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Guardar',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildSocialLinksRow() {
    if (_profile.socialLinks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: _profile.socialLinks.map((url) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7.5),
          child: buildSocialIcon(_getSocialIcon(url), url),
        );
      }).toList(),
    );
  }

  Widget buildSocialIcon(FaIconData icon, String url) => CircleAvatar(
    backgroundColor: MandarinaAppTheme.primaryColor,
    radius: 30,
    child: Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Enlace: $url',
                style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, color: MandarinaAppTheme.whiteColor),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: MandarinaAppTheme.blueColor,
            ),
          );
        },
        child: Center(
          child: FaIcon(
            icon,
            size: 35,
            color: MandarinaAppTheme.whiteColor,
          ),
        ),
      ),
    ),
  );

  Widget buildSocialLinksEditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Redes Sociales',
          style: GoogleFonts.quicksand(
            color: MandarinaAppTheme.accentColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_tempSocialLinks.length, (index) {
            final url = _tempSocialLinks[index];
            final icon = _getSocialIcon(url);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MandarinaAppTheme.whiteColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: MandarinaAppTheme.secondaryColor),
              ),
              child: Row(
                children: [
                  FaIcon(icon, color: MandarinaAppTheme.primaryColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      url,
                      style: GoogleFonts.quicksand(
                        color: MandarinaAppTheme.blueColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: MandarinaAppTheme.accentColor),
                    onPressed: () {
                      setState(() {
                        _tempSocialLinks.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TextFormField(
                controller: _newSocialLinkController,
                style: GoogleFonts.quicksand(
                  color: MandarinaAppTheme.blueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'https://linkedin.com/in/usuario',
                  hintStyle: GoogleFonts.quicksand(
                    color: MandarinaAppTheme.blueColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final url = _newSocialLinkController.text.trim();
                if (url.isNotEmpty) {
                  setState(() {
                    _tempSocialLinks.add(url);
                    _newSocialLinkController.clear();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MandarinaAppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Añadir',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}