import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/driver.dart';
import '../l10n/app_localizations.dart';
import '../constants.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedLanguage;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final driver = profileProvider.driver;
    if (driver != null) {
      _nameController.text = driver.name;
      _surnameController.text =
          driver.companyName; // Використовуємо companyName як призвіще
      _phoneController.text = driver.phone;
      _selectedLanguage = driver.avatar.isNotEmpty ? driver.avatar : null;
    }
    // Якщо не вибрано, беремо локаль мобільного або defaultLanguage
    _selectedLanguage ??= Localizations.localeOf(context).languageCode;
    if (!Constants.supportedLanguages.contains(_selectedLanguage)) {
      _selectedLanguage = Constants.defaultLanguage;
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final driver = Driver(
      id: profileProvider.driver?.id ?? 0,
      name: _nameController.text,
      email: profileProvider.driver?.email ?? '',
      phone: _phoneController.text,
      companyName: _surnameController.text,
      avatar: _avatarFile?.path ?? profileProvider.driver?.avatar ?? '',
      isPending: true,
      isDeleted: false,
    );
    await profileProvider.update(driver);
    // Зберігаємо вибір мови
    // Можна додати збереження в SharedPreferences якщо потрібно
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('progressUpdated'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('profile')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundImage:
                        _avatarFile != null ? FileImage(_avatarFile!) : null,
                    child: _avatarFile == null
                        ? const Icon(Icons.person, size: 56)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.camera_alt, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: loc.translate('firstName'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _surnameController,
              decoration: InputDecoration(
                labelText: loc.translate('lastName'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: loc.translate('phone'),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: loc.translate('language'),
                border: const OutlineInputBorder(),
              ),
              value: _selectedLanguage,
              items: Constants.supportedLanguages
                  .map((lang) => DropdownMenuItem(
                        value: lang,
                        child: Text(Constants.languageNames[lang]!),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedLanguage = val;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: Text(loc.translate('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
