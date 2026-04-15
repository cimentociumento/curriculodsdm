import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const ResumeApp());
}

class ResumeApp extends StatelessWidget {
  const ResumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Curriculo App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B67F1)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: const ResumeFormPage(),
    );
  }
}

class ResumeData {
  const ResumeData({
    required this.fullName,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.location,
    required this.summary,
    required this.education,
    required this.experience,
    this.photoPath,
  });

  final String fullName;
  final String jobTitle;
  final String email;
  final String phone;
  final String location;
  final String summary;
  final String education;
  final String experience;
  final String? photoPath;
}

class ResumeFormPage extends StatefulWidget {
  const ResumeFormPage({super.key});

  @override
  State<ResumeFormPage> createState() => _ResumeFormPageState();
}

class _ResumeFormPageState extends State<ResumeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _fullNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _summaryController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();

  String? _photoPath;

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final extension = p.extension(image.path);
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}$extension';
    final targetPath = p.join(imagesDir.path, fileName);

    await File(image.path).copy(targetPath);

    setState(() {
      _photoPath = targetPath;
    });
  }

  void _openPreview() {
    if (!_formKey.currentState!.validate()) return;

    final data = ResumeData(
      fullName: _fullNameController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      summary: _summaryController.text.trim(),
      education: _educationController.text.trim(),
      experience: _experienceController.text.trim(),
      photoPath: _photoPath,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResumePreviewPage(data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF2F4FF), Color(0xFFE9EEF9)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _Header(
                  title: 'Cadastro de Curriculo',
                  subtitle: 'Preencha suas informacoes para gerar seu perfil.',
                ),
                const SizedBox(height: 18),
                _PhotoPicker(
                  photoPath: _photoPath,
                  onTap: _pickPhoto,
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  children: [
                    _LabeledField(
                      controller: _fullNameController,
                      label: 'Nome completo',
                      icon: Icons.person_outline,
                      validator: _requiredField,
                    ),
                    _LabeledField(
                      controller: _jobTitleController,
                      label: 'Cargo desejado',
                      icon: Icons.work_outline,
                      validator: _requiredField,
                    ),
                    _LabeledField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.mail_outline,
                      validator: _validateEmail,
                    ),
                    _LabeledField(
                      controller: _phoneController,
                      label: 'Telefone',
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone_outlined,
                      validator: _requiredField,
                    ),
                    _LabeledField(
                      controller: _locationController,
                      label: 'Cidade / Estado',
                      icon: Icons.location_on_outlined,
                      validator: _requiredField,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  children: [
                    _LabeledField(
                      controller: _summaryController,
                      label: 'Resumo profissional',
                      icon: Icons.article_outlined,
                      maxLines: 4,
                      validator: _requiredField,
                    ),
                    _LabeledField(
                      controller: _experienceController,
                      label: 'Experiencia',
                      icon: Icons.business_center_outlined,
                      maxLines: 4,
                      validator: _requiredField,
                    ),
                    _LabeledField(
                      controller: _educationController,
                      label: 'Formacao',
                      icon: Icons.school_outlined,
                      maxLines: 3,
                      validator: _requiredField,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _openPreview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Visualizar curriculo'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResumePreviewPage extends StatelessWidget {
  const ResumePreviewPage({super.key, required this.data});

  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curriculo'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F8FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ProfileCard(data: data),
            const SizedBox(height: 14),
            _InfoSection(
              title: 'Resumo',
              icon: Icons.psychology_outlined,
              content: data.summary,
              onTap: () => _openCategory(
                context,
                title: 'Resumo',
                icon: Icons.psychology_outlined,
                content: data.summary,
              ),
            ),
            _InfoSection(
              title: 'Experiencia',
              icon: Icons.work_history_outlined,
              content: data.experience,
              onTap: () => _openCategory(
                context,
                title: 'Experiencia',
                icon: Icons.work_history_outlined,
                content: data.experience,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCategory(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailPage(
          title: title,
          icon: icon,
          content: content,
        ),
      ),
    );
  }
}

class CategoryDetailPage extends StatelessWidget {
  const CategoryDetailPage({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
  });

  final String title;
  final IconData icon;
  final String content;

  @override
  Widget build(BuildContext context) {
    final items = content
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF5B67F1)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$title completo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.circle, size: 10),
                title: Text(item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.photoPath, required this.onTap});

  final String? photoPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: const Color(0xFFE5E8FF),
              backgroundImage: photoPath != null ? FileImage(File(photoPath!)) : null,
              child: photoPath == null
                  ? const Icon(Icons.person, size: 34, color: Color(0xFF5B67F1))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foto de perfil',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Toque para selecionar uma imagem da galeria.'),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Selecionar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children
              .map(
                (widget) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: widget,
                ),
              )
              .toList()
            ..removeLast(),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.data});

  final ResumeData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFEEF1FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              backgroundImage: data.photoPath != null
                  ? FileImage(File(data.photoPath!))
                  : null,
              child: data.photoPath == null
                  ? const Icon(Icons.person, size: 42, color: Color(0xFF5B67F1))
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              data.fullName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.jobTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF4654D6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _ContactChip(icon: Icons.mail_outline, text: data.email),
                _ContactChip(icon: Icons.phone_outlined, text: data.phone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      side: BorderSide.none,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.content,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final previewContent = content.replaceAll('\n', ' ').trim();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF5B67F1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                previewContent,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _requiredField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obrigatorio.';
  }
  return null;
}

String? _validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obrigatorio.';
  }

  const emailPattern = r'^[\w\.-]+@[\w\.-]+\.\w+$';
  final isValid = RegExp(emailPattern).hasMatch(value.trim());
  if (!isValid) {
    return 'Digite um email valido.';
  }

  return null;
}
