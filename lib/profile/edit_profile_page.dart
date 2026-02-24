import 'package:flutter/material.dart';
import '../home/home_models.dart';
import 'profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _institutionCtrl;
  late int _studentClass;
  late String _division;
  late String _district;

  // Class 6-12 only
  static const List<int> _classes = [6, 7, 8, 9, 10, 11, 12];

  static const List<String> _divisions = [
    'Dhaka', 'Chittagong', 'Rajshahi', 'Khulna',
    'Barisal', 'Sylhet', 'Rangpur', 'Mymensingh',
  ];

  static const Map<String, List<String>> _districtsByDivision = {
    'Dhaka': ['Dhaka', 'Gazipur', 'Narayanganj', 'Narsingdi', 'Manikganj',
      'Munshiganj', 'Faridpur', 'Madaripur', 'Gopalganj', 'Shariatpur',
      'Kishoreganj', 'Tangail', 'Rajbari'],
    'Chittagong': ['Chittagong', "Cox's Bazar", 'Comilla', 'Brahmanbaria',
      'Chandpur', 'Lakshmipur', 'Noakhali', 'Feni', 'Khagrachari',
      'Rangamati', 'Bandarban'],
    'Rajshahi': ['Rajshahi', 'Bogra', 'Joypurhat', 'Chapai Nawabganj',
      'Naogaon', 'Natore', 'Pabna', 'Sirajganj'],
    'Khulna': ['Khulna', 'Bagerhat', 'Satkhira', 'Jessore', 'Magura',
      'Jhenaidah', 'Narail', 'Chuadanga', 'Kushtia', 'Meherpur'],
    'Barisal': ['Barisal', 'Bhola', 'Patuakhali', 'Pirojpur',
      'Jhalokati', 'Barguna'],
    'Sylhet': ['Sylhet', 'Moulvibazar', 'Habiganj', 'Sunamganj'],
    'Rangpur': ['Rangpur', 'Dinajpur', 'Gaibandha', 'Kurigram',
      'Lalmonirhat', 'Nilphamari', 'Panchagarh', 'Thakurgaon'],
    'Mymensingh': ['Mymensingh', 'Jamalpur', 'Netrokona', 'Sherpur'],
  };

  // Auto-derive category from class
  static String _categoryFromClass(int cls) {
    if (cls <= 8) return 'Junior';
    if (cls <= 10) return 'Secondary';
    return 'Higher Sec';
  }

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _fullNameCtrl = TextEditingController(text: p.fullName);
    _institutionCtrl = TextEditingController(text: p.institution);
    // Clamp class to valid range 6-12
    _studentClass = p.studentClass.clamp(6, 12);
    _division = _divisions.contains(p.division) ? p.division : _divisions[0];
    _district = _getDistricts(_division).contains(p.district)
        ? p.district
        : _getDistricts(_division)[0];
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _institutionCtrl.dispose();
    super.dispose();
  }

  List<String> _getDistricts(String division) =>
      _districtsByDivision[division] ?? [];

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ProfileService.updateProfile(
        fullName: _fullNameCtrl.text.trim(),
        studentClass: _studentClass,
        category: _categoryFromClass(_studentClass),
        division: _division,
        district: _district,
        institution: _institutionCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final category = _categoryFromClass(_studentClass);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Text('Save',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Locked notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Username and email cannot be changed.',
                        style: TextStyle(
                            color: Colors.orange.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Personal
              _sectionCard('Personal Information', [
                _buildTextField(
                  label: 'Full Name',
                  controller: _fullNameCtrl,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildClassPicker(),
                const SizedBox(height: 16),
                // Auto-filled category (read-only)
                _buildReadOnly(
                  label: 'Category',
                  value: category,
                  hint: 'Auto-filled from class',
                ),
              ]),

              const SizedBox(height: 12),

              // Location
              _sectionCard('Location', [
                _buildDropdown(
                  label: 'Division',
                  value: _division,
                  items: _divisions,
                  onChanged: (v) => setState(() {
                    _division = v!;
                    _district = _getDistricts(_division)[0];
                  }),
                ),
                const SizedBox(height: 14),
                _buildDropdown(
                  label: 'District',
                  value: _district,
                  items: _getDistricts(_division),
                  onChanged: (v) => setState(() => _district = v!),
                ),
              ]),

              const SizedBox(height: 12),

              // Institution
              _sectionCard('Institution', [
                _buildTextField(
                  label: 'Institution Name',
                  controller: _institutionCtrl,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ]),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1E88E5))),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEF0F5)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnly({
    required String label,
    required String value,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E88E5))),
              const Spacer(),
              if (hint != null)
                Text(hint,
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Class',
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: _classes.map((cls) {
            final selected = cls == _studentClass;
            // Group label
            String groupLabel = '';
            if (cls == 6) groupLabel = 'Junior';
            if (cls == 9) groupLabel = 'Secondary';
            if (cls == 11) groupLabel = 'Higher Sec';

            return Expanded(
              child: Column(
                children: [
                  if (groupLabel.isNotEmpty) ...[
                    Text(groupLabel,
                        style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                  ] else
                    const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => setState(() => _studentClass = cls),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1E88E5)
                            : const Color(0xFFF4F6FB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF1E88E5)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        '$cls',
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        // Group indicator bar
        Row(
          children: [
            _groupBar('Junior\n6–8', 3, const Color(0xFF43A047)),
            const SizedBox(width: 4),
            _groupBar('Secondary\n9–10', 2, const Color(0xFFFFA726)),
            const SizedBox(width: 4),
            _groupBar('Higher Sec\n11–12', 2, const Color(0xFFE53935)),
          ],
        ),
      ],
    );
  }

  Widget _groupBar(String label, int flex, Color color) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w600,
              height: 1.4),
        ),
      ),
    );
  }
}