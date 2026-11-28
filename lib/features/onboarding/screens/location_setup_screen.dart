import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
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
  ConsumerState<LocationSetupScreen> createState() =>
      _LocationSetupScreenState();
}

class _LocationSetupScreenState extends ConsumerState<LocationSetupScreen> {
  static const List<Map<String, String>> _countries = [
    {'code': 'IN', 'name': 'India (IN)'},
    {'code': 'US', 'name': 'United States (US)'},
    {'code': 'GB', 'name': 'United Kingdom (GB)'},
    {'code': 'CA', 'name': 'Canada (CA)'},
    {'code': 'AU', 'name': 'Australia (AU)'},
    {'code': 'DE', 'name': 'Germany (DE)'},
    {'code': 'FR', 'name': 'France (FR)'},
    {'code': 'JP', 'name': 'Japan (JP)'},
    {'code': 'SG', 'name': 'Singapore (SG)'},
    {'code': 'AE', 'name': 'UAE (AE)'},
    {'code': 'BR', 'name': 'Brazil (BR)'},
  ];

  late String _selectedCountryCode;
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  bool _locationVisible = true;
  bool _isSaving = false;
  String? _errorMessage;

  List<String> _regionSuggestions = [];
  List<String> _citySuggestions = [];
  Timer? _regionDebounce;
  Timer? _cityDebounce;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    final initialCC = (user?.countryCode ?? 'IN').toUpperCase();
    _selectedCountryCode =
        _countries.any((c) => c['code'] == initialCC) ? initialCC : 'IN';
    _regionController.text = user?.region ?? user?.state ?? '';
    _cityController.text = user?.city ?? user?.district ?? '';
    _locationVisible = user?.locationVisible ?? true;
  }

  @override
  void dispose() {
    _regionDebounce?.cancel();
    _cityDebounce?.cancel();
    _regionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onRegionChanged(String value) {
    _regionDebounce?.cancel();
    _regionDebounce = Timer(const Duration(milliseconds: 280), () async {
      final q = value.trim();
      if (q.isEmpty) {
        if (mounted) setState(() => _regionSuggestions = []);
        return;
      }
      try {
        final results = await ref
            .read(competitionRepositoryProvider)
            .suggestLocations(
              type: 'region',
              countryCode: _selectedCountryCode,
              query: q,
            );
        if (mounted) setState(() => _regionSuggestions = results);
      } catch (_) {
        // Offline/rate-limit safe: silently keep manual input
      }
    });
  }

  void _onCityChanged(String value) {
    _cityDebounce?.cancel();
    _cityDebounce = Timer(const Duration(milliseconds: 280), () async {
      final q = value.trim();
      if (q.isEmpty) {
        if (mounted) setState(() => _citySuggestions = []);
        return;
      }
      try {
        final results = await ref
            .read(competitionRepositoryProvider)
            .suggestLocations(
              type: 'city',
              countryCode: _selectedCountryCode,
              query: q,
            );
        if (mounted) setState(() => _citySuggestions = results);
      } catch (_) {
        // Offline/rate-limit safe: silently keep manual input
      }
    });
  }

  Future<void> _handleSaveLocation() async {
    final region = _regionController.text.trim();
    final city = _cityController.text.trim();

    if (region.isEmpty || city.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your region and city to join local leaderboards.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(competitionRepositoryProvider);
      final currentUser = ref.read(authNotifierProvider).user;
      final displayName = currentUser?.displayName ?? 'Athlete';

      final updatedUser = await repo.updateProfileLocation(
        displayName: displayName,
        countryCode: _selectedCountryCode,
        region: region,
        city: city,
        locationVisible: _locationVisible,
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
              // Calm Territory Banner (surface1 + 1px hairline)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        AppIcons.location,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GLOBAL ARENA TERRITORY',
                            style: AppTypography.headingSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Compete across city, region, country, and global leaderboards.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Country Selector
              Text('COUNTRY', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Container(
                constraints: const BoxConstraints(
                  minHeight: AppSpacing.minTouchTarget,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    isExpanded: true,
                    dropdownColor: AppColors.surface3,
                    items: _countries.map((c) {
                      return DropdownMenuItem(
                        value: c['code'],
                        child: Text(c['name']!, style: AppTypography.bodyLarge),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedCountryCode = val;
                          _regionSuggestions = [];
                          _citySuggestions = [];
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Region Input + Autocomplete Suggestions
              Text('REGION / STATE', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _regionController,
                style: AppTypography.bodyLarge,
                onChanged: _onRegionChanged,
                decoration: const InputDecoration(
                  hintText: 'e.g. Tamil Nadu, California, Ontario',
                  prefixIcon: Icon(AppIcons.location, color: AppColors.primary),
                ),
              ),
              if (_regionSuggestions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _regionSuggestions.map((s) {
                    return ActionChip(
                      label: Text(s),
                      backgroundColor: AppColors.surface2,
                      side: const BorderSide(color: AppColors.border),
                      labelStyle: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _regionController.text = s;
                        setState(() => _regionSuggestions = []);
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              // City Input + Autocomplete Suggestions
              Text('CITY', style: AppTypography.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _cityController,
                style: AppTypography.bodyLarge,
                onChanged: _onCityChanged,
                decoration: const InputDecoration(
                  hintText: 'e.g. Chennai, San Francisco, Toronto',
                  prefixIcon: Icon(AppIcons.target, color: AppColors.primary),
                ),
              ),
              if (_citySuggestions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _citySuggestions.map((s) {
                    return ActionChip(
                      label: Text(s),
                      backgroundColor: AppColors.surface2,
                      side: const BorderSide(color: AppColors.border),
                      labelStyle: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _cityController.text = s;
                        setState(() => _citySuggestions = []);
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              // Location Visibility Toggle
              Material(
                color: AppColors.surface1,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.roundedMd,
                  side: const BorderSide(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: SwitchListTile(
                  value: _locationVisible,
                  activeThumbColor: AppColors.primary,
                  title: Text(
                    'Show on local leaderboards',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'When off, you only appear on the global leaderboard without your city or region.',
                    style: AppTypography.bodySmall,
                  ),
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _locationVisible = val);
                  },
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  style: AppTypography.rawDangerSmall,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),

              // Submit CTA
              PrimaryButton(
                text: 'ENTER ARENA',
                icon: AppIcons.check,
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
