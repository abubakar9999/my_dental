import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../data/local/database.dart';

class PatientFormScreen extends ConsumerStatefulWidget {
  final int? patientId;

  const PatientFormScreen({super.key, this.patientId});

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;
  bool _isInit = true;

  bool get isEditMode => widget.patientId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit && isEditMode) {
      _loadPatientData();
      _isInit = false;
    }
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);
    try {
      final patient = await ref.read(databaseProvider).getPatient(widget.patientId!);
      _nameController.text = patient.name;
      _phoneController.text = patient.phone;
      if (patient.age != null) _ageController.text = patient.age.toString();
      _addressController.text = patient.address ?? '';
      _medicalHistoryController.text = patient.medicalHistory ?? '';
      _allergiesController.text = patient.allergies ?? '';
      _selectedGender = patient.gender;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('রোগীর তথ্য লোড করতে সমস্যা হয়েছে: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final age = int.tryParse(_ageController.text.trim());

      if (isEditMode) {
        await db.updatePatient(
          PatientsCompanion(
            id: drift.Value(widget.patientId!),
            name: drift.Value(_nameController.text.trim()),
            phone: drift.Value(_phoneController.text.trim()),
            age: drift.Value(age),
            gender: drift.Value(_selectedGender),
            address: drift.Value(_addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim()),
            medicalHistory: drift.Value(_medicalHistoryController.text.trim().isEmpty
                ? null
                : _medicalHistoryController.text.trim()),
            allergies: drift.Value(_allergiesController.text.trim().isEmpty
                ? null
                : _allergiesController.text.trim()),
          ),
        );
        ref.invalidate(patientProvider(widget.patientId!));
      } else {
        await db.insertPatient(
          PatientsCompanion.insert(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            age: drift.Value(age),
            gender: drift.Value(_selectedGender),
            address: drift.Value(_addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim()),
            medicalHistory: drift.Value(_medicalHistoryController.text.trim().isEmpty
                ? null
                : _medicalHistoryController.text.trim()),
            allergies: drift.Value(_allergiesController.text.trim().isEmpty
                ? null
                : _allergiesController.text.trim()),
          ),
        );
      }

      ref.invalidate(patientCountProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? 'রোগীর তথ্য সফলভাবে আপডেট হয়েছে'
                : 'নতুন রোগী সফলভাবে যোগ হয়েছে'),
            backgroundColor: Colors.teal,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('সংরক্ষণে ত্রুটি: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'রোগী তথ্য সম্পাদনা' : 'নতুন রোগী যোগ'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'রোগীর পূর্ণ নাম *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'রোগীর নাম প্রদান করুন';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'মোবাইল নম্বর *',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '01XXXXXXXXX',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'ফোন নম্বর প্রদান করুন';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Age & Gender Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'বয়স',
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'লিঙ্গ',
                              prefixIcon: Icon(Icons.transgender_outlined),
                            ),
                            items: AppConstants.genderOptions.map((g) {
                              return DropdownMenuItem(value: g, child: Text(g));
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedGender = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'ঠিকানা',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Medical History
                    TextFormField(
                      controller: _medicalHistoryController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'মেডিকেল হিস্ট্রি (ডায়াবেটিস, প্রেশার ইত্যাদি)',
                        prefixIcon: Icon(Icons.history_edu_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Allergies
                    TextFormField(
                      controller: _allergiesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'অ্যালার্জি বা বিশেষ সতর্কতা',
                        prefixIcon: Icon(Icons.warning_amber_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Save Button
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _savePatient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.save),
                      label: Text(
                        isEditMode ? 'পরিবর্তন সংরক্ষণ করুন' : 'রোগী যুক্ত করুন',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
