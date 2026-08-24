import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../pairing/screens/pairing_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nicknameController = TextEditingController();
  final _partnerNicknameController = TextEditingController();
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nicknameController.text = auth.currentUser?['nickname'] ?? '';
    _partnerNicknameController.text = auth.partnerUser?['nickname'] ?? '';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _partnerNicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Foto de perfil seleccionada! 📸')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final couple = Provider.of<CoupleProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    final userName = auth.currentUser?['name'] ?? 'Usuario';
    final partnerName = auth.partnerUser?['name'] ?? 'Mi Amor';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Perfil & Personalización 🎨',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.softAccentColor.withOpacity(0.5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar & Photo Picker Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: theme.mainGradient,
                            image: _avatarFile != null
                                ? DecorationImage(
                                    image: FileImage(_avatarFile!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _avatarFile == null
                              ? Center(
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : '♥',
                                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.primaryColor, width: 2),
                              ),
                              child: Icon(Icons.camera_alt_rounded, size: 18, color: theme.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (auth.isPaired)
                      Text(
                        'Vinculado a: $partnerName 💕',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      )
                    else
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PairingScreen()),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.softAccentColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link_rounded, size: 16, color: theme.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                'Vincular con mi Pareja 💖',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Theme Color Picker Section
              Text(
                '🎨 Colores y Tema de la Aplicación',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.secondaryColor),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: theme.softAccentColor),
                ),
                child: Column(
                  children: [
                    _buildThemeOption(
                      title: '💖 Rose Gold & Pink (Clásico)',
                      palette: AppThemePalette.roseGold,
                      gradient: const [Color(0xFFFF5E7E), Color(0xFFFF8E53)],
                      current: theme.currentPalette,
                      onSelect: () => theme.setPalette(AppThemePalette.roseGold),
                    ),
                    const Divider(),
                    _buildThemeOption(
                      title: '🍷 Wine & Velvet (Vino & Oro)',
                      palette: AppThemePalette.wineVelvet,
                      gradient: const [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
                      current: theme.currentPalette,
                      onSelect: () => theme.setPalette(AppThemePalette.wineVelvet),
                    ),
                    const Divider(),
                    _buildThemeOption(
                      title: '🌌 Midnight Love (Azul & Púrpura)',
                      palette: AppThemePalette.midnightLove,
                      gradient: const [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      current: theme.currentPalette,
                      onSelect: () => theme.setPalette(AppThemePalette.midnightLove),
                    ),
                    const Divider(),
                    _buildThemeOption(
                      title: '🌸 Cherry Blossom (Flor de Cerezo)',
                      palette: AppThemePalette.cherryBlossom,
                      gradient: const [Color(0xFFF48FB1), Color(0xFFFF4081)],
                      current: theme.currentPalette,
                      onSelect: () => theme.setPalette(AppThemePalette.cherryBlossom),
                    ),
                    const Divider(),
                    _buildThemeOption(
                      title: '🌅 Sunset Romance (Atardecer & Coral)',
                      palette: AppThemePalette.sunsetRomance,
                      gradient: const [Color(0xFFFF7043), Color(0xFFFFB74D)],
                      current: theme.currentPalette,
                      onSelect: () => theme.setPalette(AppThemePalette.sunsetRomance),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nicknames Section
              Text(
                '💕 Apodos Cariñosos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.secondaryColor),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: theme.softAccentColor),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Tu Apodo Cariñoso',
                        hintText: 'Ej. Mi Amor, Bebé, Mi Cielo',
                        prefixIcon: Icon(Icons.favorite_border_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _partnerNicknameController,
                      decoration: const InputDecoration(
                        labelText: 'Apodo de tu Pareja',
                        hintText: 'Ej. Mi Princesa, Mi Rey',
                        prefixIcon: Icon(Icons.favorite_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (auth.currentUser != null) {
                            auth.currentUser!['nickname'] = _nicknameController.text.trim();
                          }
                          if (auth.partnerUser != null) {
                            auth.partnerUser!['nickname'] = _partnerNicknameController.text.trim();
                          }
                          auth.notifyListeners();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('¡Apodos guardados con éxito! 💖')),
                          );
                        },
                        child: const Text('Guardar Apodos'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Danger Zone: Delete Account
              Text(
                'Zona de Cuenta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Eliminar Cuenta y Todos los Datos 🗑️',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Borra de forma permanente tu usuario, recuerdos y datos de la base de datos sin dejar registros huérfanos.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          _showDeleteAccountDialog(context, auth);
                        },
                        icon: const Icon(Icons.delete_forever_rounded, size: 18),
                        label: const Text('Eliminar Mi Cuenta Permanentemente'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('¿Eliminar Cuenta? 🗑️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            'Esta acción es definitiva. Se eliminará tu cuenta y se desvinculará a tu pareja limpiamente sin dejar registros huérfanos.',
            style: TextStyle(fontSize: 13, color: Color(0xFF424242)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close Profile screen
                final success = await auth.deleteAccount();
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cuenta eliminada correctamente.')),
                  );
                }
              },
              child: const Text('Sí, Eliminar Permanentemente', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption({
    required String title,
    required AppThemePalette palette,
    required List<Color> gradient,
    required AppThemePalette current,
    required VoidCallback onSelect,
  }) {
    final isSelected = palette == current;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: gradient),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }
}
