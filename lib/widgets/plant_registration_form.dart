import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/plant_provider.dart';
import '../models/app_models.dart';

class PlantRegistrationForm extends StatefulWidget {
  @override
  _PlantRegistrationFormState createState() => _PlantRegistrationFormState();
}

class _PlantRegistrationFormState extends State<PlantRegistrationForm> {
  String _plantName = '';
  String _plantSpecies = '';
  Map<String, double> _optimalSettings = {
    'optimalTempMin': 18,
    'optimalTempMax': 25,
    'optimalHumidityMin': 40,
    'optimalHumidityMax': 70,
    'optimalSoilMoistureMin': 40,
    'optimalSoilMoistureMax': 70,
    'optimalLightMin': 60,
    'optimalLightMax': 90,
  };

  void _updateOptimalSettings(List<PlantProfile> plantProfiles) {
    PlantProfile? profile = plantProfiles.firstWhere(
          (p) => p.species == _plantSpecies,
      orElse: () => PlantProfile(
        species: '',
        commonName: '',
        optimalTempMin: 18,
        optimalTempMax: 25,
        optimalHumidityMin: 40,
        optimalHumidityMax: 70,
        optimalSoilMoistureMin: 40,
        optimalSoilMoistureMax: 70,
        optimalLightMin: 60,
        optimalLightMax: 90,
        description: '',
      ),
    );

    if (profile.species.isNotEmpty) {
      setState(() {
        _optimalSettings = {
          'optimalTempMin': profile.optimalTempMin,
          'optimalTempMax': profile.optimalTempMax,
          'optimalHumidityMin': profile.optimalHumidityMin,
          'optimalHumidityMax': profile.optimalHumidityMax,
          'optimalSoilMoistureMin': profile.optimalSoilMoistureMin,
          'optimalSoilMoistureMax': profile.optimalSoilMoistureMax,
          'optimalLightMin': profile.optimalLightMin,
          'optimalLightMax': profile.optimalLightMax,
        };
      });
    }
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_plantName.isEmpty || _plantSpecies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('식물 이름과 종류를 입력해주세요')),
      );
      return;
    }

    Plant newPlant = Plant(
      id: '', // API에서 생성됨
      name: _plantName,
      species: _plantSpecies,
      registeredDate: DateTime.now().toString().split(' ')[0],
      optimalTempMin: _optimalSettings['optimalTempMin']!,
      optimalTempMax: _optimalSettings['optimalTempMax']!,
      optimalHumidityMin: _optimalSettings['optimalHumidityMin']!,
      optimalHumidityMax: _optimalSettings['optimalHumidityMax']!,
      optimalSoilMoistureMin: _optimalSettings['optimalSoilMoistureMin']!,
      optimalSoilMoistureMax: _optimalSettings['optimalSoilMoistureMax']!,
      optimalLightMin: _optimalSettings['optimalLightMin']!,
      optimalLightMax: _optimalSettings['optimalLightMax']!,
    );

    final plantProvider = Provider.of<PlantProvider>(context, listen: false);
    bool success = await plantProvider.registerPlant(newPlant);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('식물이 등록되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(plantProvider.error ?? '등록에 실패했습니다. 다시 시도해주세요'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantProvider>(
      builder: (context, plantProvider, child) {
        return Dialog(
          insetPadding: EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '식물 등록',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: plantProvider.isLoading ? null : () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),

                // 내용
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 안내 텍스트
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.eco_outlined,
                                size: 32,
                                color: Color(0xFF4CAF50),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '새로운 식물 친구를 등록해보세요!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '식물 정보를 입력하시면 최적의 환경을 추천해드립니다',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4CAF50),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // 식물 등록 폼
                        _buildRegistrationForm(context, plantProvider.plantProfiles),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegistrationForm(BuildContext context, List<PlantProfile> plantProfiles) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: '식물 이름',
            hintText: '예: 우리집 몬스테라',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.eco_outlined, color: Color(0xFF4CAF50)),
          ),
          onChanged: (value) {
            setState(() {
              _plantName = value;
            });
          },
        ),

        SizedBox(height: 16),

        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: '어떤 식물인가요?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            prefixIcon: Icon(Icons.search, color: Color(0xFF4CAF50)),
          ),
          value: _plantSpecies.isEmpty ? null : _plantSpecies,
          menuMaxHeight: 250,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
          onChanged: (String? value) {
            setState(() {
              _plantSpecies = value ?? '';
            });
            _updateOptimalSettings(plantProfiles);
          },
          selectedItemBuilder: (BuildContext context) {
            return [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '선택하세요',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...plantProfiles.map((PlantProfile profile) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${profile.species} (${profile.commonName})',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ];
          },
          items: [
            DropdownMenuItem(
              value: '',
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '선택하세요',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            ...plantProfiles.map((PlantProfile profile) {
              return DropdownMenuItem(
                value: profile.species,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.species,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (profile.commonName.isNotEmpty) ...[
                        SizedBox(height: 2),
                        Text(
                          profile.commonName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
          dropdownColor: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),

        if (_plantSpecies.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildOptimalSettingsInfo(),
        ],

        SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: Consumer<PlantProvider>(
            builder: (context, plantProvider, child) {
              return ElevatedButton.icon(
                onPressed: plantProvider.isLoading ? null : () => _handleSubmit(context),
                icon: plantProvider.isLoading
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(Icons.add),
                label: Text(
                  plantProvider.isLoading ? '등록 중...' : '식물 등록하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptimalSettingsInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.green[700],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '적정 환경 설정',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOptimalInfoRow(
                  Icons.thermostat_outlined,
                  '온도',
                  '${_optimalSettings['optimalTempMin']!.toInt()}°C - ${_optimalSettings['optimalTempMax']!.toInt()}°C',
                  Colors.red[400]!,
                ),
                SizedBox(height: 6),
                _buildOptimalInfoRow(
                  Icons.water_drop_outlined,
                  '습도',
                  '${_optimalSettings['optimalHumidityMin']!.toInt()}% - ${_optimalSettings['optimalHumidityMax']!.toInt()}%',
                  Colors.blue[400]!,
                ),
                SizedBox(height: 6),
                _buildOptimalInfoRow(
                  Icons.opacity_outlined,
                  '토양 수분',
                  '${_optimalSettings['optimalSoilMoistureMin']!.toInt()}% - ${_optimalSettings['optimalSoilMoistureMax']!.toInt()}%',
                  Colors.green[400]!,
                ),
                SizedBox(height: 6),
                _buildOptimalInfoRow(
                  Icons.wb_sunny_outlined,
                  '조도',
                  '${_optimalSettings['optimalLightMin']!.toInt()}% - ${_optimalSettings['optimalLightMax']!.toInt()}%',
                  Colors.orange[400]!,
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '나중에 설정에서 언제든 변경할 수 있습니다',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimalInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}