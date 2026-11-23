import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/tamil_nadu_locations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/app_buttons.dart';
import '../../auth/providers/auth_provider.dart';
import '../../competition/providers/competition_provider.dart';
import '../../navigation/screens/main_nav_shell.dart';

class LocationSetupScreen extends ConsumerStatefulWidget {
  final bool isModal;

  const LocationSetupScreen({super.key, this.isModal = false});

  @override
  ConsumerState<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends ConsumerState<LocationSetupScreen> {
  late String _selectedState;
  late String _selectedDistrict;
  late String _selectedArea;
  final TextEditingController _customAreaController = TextEditingController();
  bool _isCustomArea = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _selectedState = user?.state ?? TamilNaduLocations.defaultState;
    _selectedDistrict = user?.district ?? 'Chennai';
    _selectedArea = user?.area ?? 'Adyar';

    final popular = TamilNaduLocations.getAreasForDistrict(_selectedDistrict);
    if (!popular.contains(_selectedArea) && _selectedArea.isNotEmpty) {
      _isCustomArea = true;
      _customAreaController.text = _selectedArea;
    }
  }

  @override
  void dispose() {
    _customAreaController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveLocation() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final finalArea = _isCustomArea
        ? _customAreaController.text.trim()
        : _selectedArea;

    if (finalArea.isEmpty) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Please specify your area to rank on the local leaderboard.';
      });
      return;
    }

    try {
      final repo = ref.read(competitionRepositoryProvider);
      final currentUser = ref.read(authNotifierProvider).user;
      final displayName = currentUser?.displayName ?? 'Athlete';

      final updatedUser = await repo.updateProfileLocation(
        displayName: displayName,
        state: _selectedState,
        district: _selectedDistrict,
        area: finalArea,
      );

      ref.read(authNotifierProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        if (widget.isModal) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavShell()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Failed to save location. Please check your connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableAreas = TamilNaduLocations.getAreasForDistrict(_selectedDistrict);

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: Text('SET YOUR TERRITORY', style: AppTypography.headingMedium),
        automaticallyImplyLeading: widget.isModal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // System Banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LOCAL MAX-REP CHALLENGE', style: AppTypography.headingSmall),
                          const SizedBox(height: 2),
                          Text(
                            'Compete in push-ups and pull-ups for your area, district, and Tamil Nadu state honors.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // State Selector
              Text('STATE', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgCardSolid,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedState,
                    isExpanded: true,
                    dropdownColor: AppColors.bgCardSolid,
                    items: TamilNaduLocations.states.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s, style: AppTypography.bodyLarge),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedState = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // District Selector
              Text('DISTRICT', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgCardSolid,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDistrict,
                    isExpanded: true,
                    dropdownColor: AppColors.bgCardSolid,
                    items: TamilNaduLocations.districts.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text(d, style: AppTypography.bodyLarge),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDistrict = val;
                          final areas = TamilNaduLocations.getAreasForDistrict(val);
                          _selectedArea = areas.first;
                          _isCustomArea = false;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Area Selector
              Text('AREA / LOCALITY', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  ...availableAreas.map((area) {
                    final isSelected = !_isCustomArea && _selectedArea == area;
                    return ChoiceChip(
                      label: Text(area),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.bgCardSolid,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.bgMain : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedArea = area;
                          _isCustomArea = false;
                        });
                      },
                    );
                  }),
                  ChoiceChip(
                    label: const Text('+ Custom Area'),
                    selected: _isCustomArea,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.bgCardSolid,
                    labelStyle: TextStyle(
                      color: _isCustomArea ? AppColors.bgMain : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() => _isCustomArea = true);
                    },
                  ),
                ],
              ),

              if (_isCustomArea) ...[
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _customAreaController,
                  style: AppTypography.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Enter your Area / Ward Name',
                    hintText: 'e.g. Velachery West',
                    prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                  ),
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.accentRed),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Confirm CTA Button
              PrimaryButton(
                text: 'ENTER ARENA',
                icon: Icons.flash_on,
                isLoading: _isSaving,
                onPressed: _handleSaveLocation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
