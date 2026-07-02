import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mandarina/core/theme/app_theme.dart';
import 'package:mandarina/domain/user_profile_model.dart';
import 'package:mandarina/presentation/widgets/drawerMenu.dart';
import 'package:mandarina/presentation/widgets/numbersWidget.dart';
import 'package:mandarina/presentation/viewmodel/providers.dart';
import 'package:mandarina/presentation/viewmodel/state/profile_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  static const String name = "profile_screen";

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late UserProfileModel _profile;
  bool _isEditing = false;
  bool _isInitialized = false;

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
    _nameController = TextEditingController();
    _professionController = TextEditingController();
    _biographyController = TextEditingController();
    _newSocialLinkController = TextEditingController();
    _tempSocialLinks = [];
    _tempGender = '';
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
      _isInitialized = false;
      _isEditing = false;
    });
  }

  void _saveEdits() {
    final name = _nameController.text.trim();
    final profession = _professionController.text.trim();
    final biography = _biographyController.text.trim();
    final gender = _tempGender;
    final socialLinks = List<String>.from(_tempSocialLinks);

    ref
        .read(profileProvider.notifier)
        .updateProfile(
          name: name,
          profession: profession,
          biography: biography,
          gender: gender,
          coverImageUrl: _profile.coverImageUrl,
          profileImageUrl: _profile.profileImageUrl,
          socialLinks: socialLinks,
        );

    setState(() {
      _isEditing = false;
      _isInitialized = false;
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
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              color: MandarinaAppTheme.whiteColor,
            ),
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
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    ref.listen<ProfileState>(profileProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.errorMessage!,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600,
                color: MandarinaAppTheme.whiteColor,
              ),
            ),
            backgroundColor: MandarinaAppTheme.accentColor,
          ),
        );
      }
    });

    if (profileState.isLoading || profile == null) {
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
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(
              color: MandarinaAppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      _profile = profile;
      _nameController.text = profile.name;
      _professionController.text = profile.profession;
      _biographyController.text = profile.biography;
      _tempSocialLinks = List.from(profile.socialLinks);
      _tempGender = profile.gender;
      _isInitialized = true;
    }

    final activeProfile = _isEditing ? _profile : profile;

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
        drawer: const DrawerMenu(currentScreen: 'Mi Perfil'),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Icons.menu,
                color: MandarinaAppTheme.whiteColor,
              ),
            ),
          ),
          actions: [
            if (!_isEditing)
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: const Icon(
                  Icons.edit,
                  color: MandarinaAppTheme.whiteColor,
                ),
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  buildTop(activeProfile),
                  buildContent(activeProfile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /* TOP Section */
  Widget buildTop(UserProfileModel activeProfile) {
    final double topPosition = coverHeight - (profileHeight / 2);
    final double bottomPosition = profileHeight / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottomPosition),
          child: buildCoverImage(activeProfile),
        ),
        Positioned(top: topPosition, child: buildProfileImage(activeProfile)),
      ],
    );
  }

  Widget buildCoverImage(UserProfileModel activeProfile) {
    final bool hasCover = activeProfile.coverImageUrl.isNotEmpty;
    final bool isNetwork =
        hasCover &&
        (activeProfile.coverImageUrl.startsWith('http') ||
            activeProfile.coverImageUrl.startsWith('https'));

    Widget coverWidget;
    if (!hasCover) {
      coverWidget = Image.asset(
        'assets/images/logo_color.png',
        width: double.infinity,
        height: coverHeight,
        fit: BoxFit.cover,
      );
    } else if (isNetwork) {
      coverWidget = CachedNetworkImage(
        imageUrl: activeProfile.coverImageUrl,
        width: double.infinity,
        height: coverHeight,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: MandarinaAppTheme.secondaryColor.withValues(alpha: 0.5),
          child: const Center(
            child: CircularProgressIndicator(
              color: MandarinaAppTheme.primaryColor,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildCoverPlaceholder(),
      );
    } else {
      coverWidget = Image.file(
        File(activeProfile.coverImageUrl),
        width: double.infinity,
        height: coverHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildCoverPlaceholder(),
      );
    }

    return Stack(
      children: [
        coverWidget,
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
                      const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 40,
                      ),
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

  Widget buildProfileImage(UserProfileModel activeProfile) {
    final bool hasImage = activeProfile.profileImageUrl.isNotEmpty;
    final bool isNetwork =
        hasImage &&
        (activeProfile.profileImageUrl.startsWith('http') ||
            activeProfile.profileImageUrl.startsWith('https'));

    final ImageProvider? imageProvider = hasImage
        ? (isNetwork
              ? CachedNetworkImageProvider(activeProfile.profileImageUrl)
                    as ImageProvider
              : FileImage(File(activeProfile.profileImageUrl)) as ImageProvider)
        : null;

    return Stack(
      children: [
        CircleAvatar(
          radius: profileHeight / 2,
          backgroundColor: MandarinaAppTheme.blueColor,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Icon(
                  Icons.person,
                  size: profileHeight * 0.8,
                  color: MandarinaAppTheme.whiteColor,
                )
              : null,
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
                          const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 32,
                          ),
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
  Widget buildContent(UserProfileModel activeProfile) {
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
                labelStyle: GoogleFonts.quicksand(
                  color: MandarinaAppTheme.blueColor,
                  fontWeight: FontWeight.w600,
                ),
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
                labelStyle: GoogleFonts.quicksand(
                  color: MandarinaAppTheme.blueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _tempGender,
              items:
                  [
                    'Femenino',
                    'Masculino',
                    'Transgénero',
                    'No binario',
                    'Género fluido',
                    'Agénero',
                    'No especificado',
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
                labelStyle: GoogleFonts.quicksand(
                  color: MandarinaAppTheme.blueColor,
                  fontWeight: FontWeight.w600,
                ),
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
                  activeProfile.name,
                  style: GoogleFonts.quicksand(
                    color: MandarinaAppTheme.blueColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Género: ${activeProfile.gender}',
                  child: FaIcon(
                    _getGenderIcon(activeProfile.gender),
                    color: _getGenderColor(activeProfile.gender),
                    size: 24,
                  ),
                ),
              ],
            ),
            Text(
              activeProfile.profession,
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
            buildSocialLinksRow(activeProfile),

          const SizedBox(height: 20),
          Divider(color: MandarinaAppTheme.primaryColor.withValues(alpha: 0.1)),
          const SizedBox(height: 20),

          // NumbersWidget is strictly Read-Only
          NumbersWidget(
            completedTasks: activeProfile.completedTasks,
            focusMinutes: activeProfile.focusMinutes,
            affinityLevel: activeProfile.affinityLevel,
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
                        color: MandarinaAppTheme.blueColor.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    activeProfile.biography,
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
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
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
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
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

  Widget buildSocialLinksRow(UserProfileModel activeProfile) {
    if (activeProfile.socialLinks.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: activeProfile.socialLinks.map((url) {
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
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  color: MandarinaAppTheme.whiteColor,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: MandarinaAppTheme.blueColor,
            ),
          );
        },
        child: Center(
          child: FaIcon(icon, size: 35, color: MandarinaAppTheme.whiteColor),
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
                    icon: const Icon(
                      Icons.remove_circle,
                      color: MandarinaAppTheme.accentColor,
                    ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
