import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'styles.dart'; 
import 'background.dart';
import 'components.dart';
import 'logic.dart';
import 'models.dart';
import 'themes/theme_data.dart';
import 'widgets/glass_settings_menu.dart'; 
import 'widgets/glass_dialogs.dart';       

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _settingsBtnKey = GlobalKey();
  bool _showTriggerType = false; 
  bool _expandIntrusions = true; 

  double _calculateDynamicDistress(AppData appData) {
    double peak = appData.anxietyPeak / 100.0;
    double urge = appData.urgePeak / 100.0;
    double control = appData.senseOfControl / 100.0;
    double after = appData.anxietyAfter / 100.0;
    
    int intrusions = appData.activeIntrusions.where((i) => i.thoughtCtrl.text.isNotEmpty).length;
    int compulsions = appData.compulsionUrgesCtrls.where((c) => c.text.isNotEmpty).length;
    
    double distress = (peak * 0.5) + (urge * 0.5); 
    distress += (intrusions * 0.1) + (compulsions * 0.1);
    
    distress -= (control * 0.5);
    distress -= ((1.0 - after) * 0.5);
    
    return distress.clamp(0.08, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final isDark = appData.isDarkMode;
    final textColor = AppStyles.getText(isDark);
    
    bool isResisting = appData.isCrisisMode || appData.isTimerRunning;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false, 
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: WaveBackground(
                  isDarkMode: isDark,
                  distressLevel: _calculateDynamicDistress(appData), 
                  currentTheme: appData.currentTheme,
                  isHighPerformance: appData.isHighPerformance,
                  isResistanceActive: isResisting,
                  isPostCrisisLog: appData.isPostCrisisLog, 
                ),
              ),

              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        if (!appData.isCrisisMode) _buildHeader(context, appData),
                        
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: appData.isCrisisMode
                                ? _buildCrisisMode(context, appData)
                                : _buildStandardLog(context, appData, textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (!appData.isCrisisMode && !appData.isPostCrisisLog) ...[
                Positioned(
                  top: 20 + MediaQuery.of(context).padding.top,
                  left: 20,
                  child: SizedBox(
                    height: 45,
                    child: RubberBandButton(
                      onTap: appData.toggleCrisisMode,
                      borderRadius: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      baseColor: appData.isCrisisMode 
                         ? const Color(0xFFD32F2F).withValues(alpha: 0.9) 
                         : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.6)),
                      textColor: appData.isCrisisMode ? Colors.white : const Color(0xFFD32F2F),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, 
                            color: appData.isCrisisMode ? Colors.white : const Color(0xFFD32F2F), 
                            size: 20),
                          const SizedBox(width: 8),
                          Text(
                            appData.t('crisis_mode'), 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0)
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 20 + MediaQuery.of(context).padding.top,
                  right: 20,
                  child: Container(
                    key: _settingsBtnKey,
                    width: 45, height: 45,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: RubberBandButton(
                      onTap: () => showGlassSettingsMenu(context, appData, _settingsBtnKey),
                      borderRadius: 30,
                      padding: EdgeInsets.zero,
                      baseColor: Colors.transparent,
                      child: Icon(Icons.settings_rounded, color: textColor, size: 24),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppData appData) {
    return const SizedBox(height: 70);
  }

  Widget _buildCrisisMode(BuildContext context, AppData appData) {
    final textColor = Colors.white; 
    final isDark = appData.isDarkMode;

    if (appData.crisisStep == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                appData.currentAnchorPhrase,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: textColor.withValues(alpha: 0.9), height: 1.4, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(height: 60),
            
            CrisisTimerRing(
              seconds: appData.crisisSeconds,
              isRunning: appData.isCrisisTimerRunning,
              onTap: appData.startCrisisTimer,
              appData: appData, 
            ),
            
            const SizedBox(height: 60),
            
            SizedBox(
              width: 200,
              height: 50,
              child: RubberBandButton(
                onTap: appData.endCrisisSession,
                baseColor: Colors.white.withValues(alpha: 0.1),
                textColor: Colors.white,
                borderRadius: 25,
                child: Text(
                  appData.t('end_session').toUpperCase(), 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.bold)
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Center(
        child: Container(
          width: 350,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
            boxShadow: AppStyles.glassShadow(isDark),
            border: Border.all(
              color: AppStyles.lowDistress.withValues(alpha: isDark ? 0.6 : 0.8),
              width: 3.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(42),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                decoration: AppStyles.glassDecorationNoShadow(isDark),
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 60, color: AppStyles.lowDistress),
                    const SizedBox(height: 20),
                    Text(
                      appData.t('you_survived'),
                      style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    Text(
                      appData.formattedCrisisTime,
                      style: TextStyle(color: textColor, fontSize: 40, fontWeight: FontWeight.w900, fontFamily: 'Courier'),
                    ),
                    const SizedBox(height: 30),
                    
                    SizedBox(
                      width: double.infinity,
                      child: RubberBandButton(
                        onTap: appData.proceedToCrisisLog,
                        baseColor: AppStyles.lowDistress.withValues(alpha: 0.2),
                        textColor: AppStyles.lowDistress,
                        child: Text(
                          appData.t('add_details_now').toUpperCase(), 
                          textAlign: TextAlign.center, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: RubberBandButton(
                        onTap: appData.quickSaveCrisisAndExit, 
                        baseColor: Colors.transparent,
                        textColor: Colors.white.withValues(alpha: 0.5),
                        child: Text(
                          appData.t('save_and_exit').toUpperCase(),
                          textAlign: TextAlign.center, 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildStandardLog(BuildContext context, AppData appData, Color textColor) {
    final themeAccent = getThemeData(appData.currentTheme).accentColor;
    final isDark = appData.isDarkMode; 
    final bool isEditing = appData.currentEditingSession != null; 
    final bool isPostCrisis = appData.isPostCrisisLog; 

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      physics: const BouncingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30, top: 10),
          child: GlassTitleCard(title: appData.t('app_title').toUpperCase()), 
        ),

        // 1. Trigger
        GlassCard(
          isPostCrisis: isPostCrisis,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(appData.t('trigger'), Icons.flash_on_rounded, themeAccent),
              const SizedBox(height: 20),
              AeroTextField(
                controller: appData.triggerCtrl,
                hint: appData.t('trigger_hint'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Center(child: Text(appData.t('context'), style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              GlassSelector<ContextTag>(
                items: ContextTag.values,
                selectedItem: appData.selectedContext,
                onSelected: (val) { appData.selectedContext = val; appData.refreshUI(); },
                labelBuilder: (val) => appData.translateContext(val),
              ),
              
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => setState(() => _showTriggerType = !_showTriggerType),
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(appData.t('trigger_type_optional'), style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)), const SizedBox(width: 5), Icon(_showTriggerType ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 16, color: textColor.withValues(alpha: 0.5))])),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(25, 20, 25, 35), child: GlassSelector<TriggerType>(items: TriggerType.values, selectedItem: appData.selectedTriggerType, onSelected: (val) { if (appData.selectedTriggerType == val) { appData.selectedTriggerType = null; } else { appData.selectedTriggerType = val; } appData.refreshUI(); }, labelBuilder: (val) => appData.translateTriggerType(val))),
                crossFadeState: _showTriggerType ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
                sizeCurve: Curves.easeOut,
              ),
              
              const SizedBox(height: 10),
              Container(height: 1, color: textColor.withValues(alpha: 0.1)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appData.t('was_crisis'), style: TextStyle(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 14)),
                  Switch(
                    value: appData.isStandardCrisis,
                    activeTrackColor: themeAccent, 
                    onChanged: (val) {
                      appData.isStandardCrisis = val;
                      appData.refreshUI();
                    },
                  )
                ],
              )
            ],
          ),
        ),

        // 2. INTRUSIONS
        GlassCard(
          isPostCrisis: isPostCrisis, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle("${appData.t('intrusions')} (${appData.activeIntrusions.length})", Icons.psychology_rounded, themeAccent),
                  IconButton(
                    icon: Icon(_expandIntrusions ? Icons.expand_less : Icons.expand_more, color: textColor.withValues(alpha: 0.5)),
                    onPressed: () => setState(() => _expandIntrusions = !_expandIntrusions),
                  )
                ],
              ),
              
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Column(
                  children: [
                    if (_expandIntrusions) ...[
                      const SizedBox(height: 10),
                      ...appData.activeIntrusions.map((intr) {
                         return Container(
                           key: ValueKey(intr.id), 
                           margin: const EdgeInsets.only(bottom: 20),
                           padding: const EdgeInsets.all(15),
                           decoration: BoxDecoration(
                             color: Colors.black.withValues(alpha: 0.05),
                             borderRadius: BorderRadius.circular(20),
                             border: Border.all(color: textColor.withValues(alpha: 0.1))
                           ),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   Expanded(child: AeroTextField(controller: intr.thoughtCtrl, hint: appData.t('intrusion_hint'), maxLines: 2)),
                                   if (appData.activeIntrusions.length > 1)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: SizedBox(
                                          width: 40, height: 40,
                                          child: RubberBandButton(
                                            onTap: () => appData.removeIntrusionField(intr.id),
                                            borderRadius: 12,
                                            baseColor: Colors.redAccent.withValues(alpha: 0.1),
                                            textColor: Colors.redAccent,
                                            padding: EdgeInsets.zero,
                                            child: const Icon(Icons.close, size: 20),
                                          ),
                                        ),
                                      )
                                 ],
                               ),
                               const SizedBox(height: 15),
                               AeroTextField(controller: intr.themeCtrl, hint: appData.t('theme_tag_optional')),
                               const SizedBox(height: 20),
                               MirrorSlider(
                                  label: appData.t('belief_strength'), 
                                  value: intr.beliefStrength, 
                                  onChanged: (val) { intr.beliefStrength = val; appData.refreshUI(); }
                               ),
                               const SizedBox(height: 20),
                               Text(appData.t('cognitive_distortion'), style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                               const SizedBox(height: 10),
                               GlassSelector<CognitiveDistortion>(
                                  items: CognitiveDistortion.values,
                                  selectedItem: intr.distortion,
                                  onSelected: (val) {
                                     if (intr.distortion == val) {
                                       intr.distortion = null; 
                                     } else {
                                       intr.distortion = val;
                                     }
                                     appData.refreshUI();
                                  },
                                  labelBuilder: (val) => appData.translateDistortion(val),
                               )
                             ],
                           ),
                         );
                      }), 
                      SizedBox(
                        width: double.infinity, 
                        child: RubberBandButton(
                          onTap: appData.addIntrusionField, 
                          baseColor: themeAccent.withValues(alpha: 0.1), 
                          textColor: isDark ? themeAccent : const Color(0xFF374151), 
                          child: Text(appData.t('add_intrusion').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))
                        )
                      ),
                    ]
                  ],
                ),
              )
            ]
          )
        ),

        // 3. Distress
        GlassCard(isPostCrisis: isPostCrisis, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSectionTitle(appData.t('distress_metrics'), Icons.timeline_rounded, themeAccent), 
          const SizedBox(height: 25), 
          MirrorSlider(label: "${appData.t('anxiety')} (Peak)", value: appData.anxietyPeak, activeColor: AppStyles.highDistress, onChanged: (val) { appData.anxietyPeak = val; appData.refreshUI(); }), 
          const SizedBox(height: 30), 
          MirrorSlider(label: appData.t('sense_of_control'), value: appData.senseOfControl, activeColor: AppStyles.lowDistress, onChanged: (val) { appData.senseOfControl = val; appData.refreshUI(); }), 
          const SizedBox(height: 30), 
          MirrorSlider(label: "${appData.t('urge')} (To Ritualize)", value: appData.urgePeak, activeColor: AppStyles.mediumDistress, onChanged: (val) { appData.urgePeak = val; appData.refreshUI(); })
        ])),

        // 4. Response
        GlassCard(isPostCrisis: isPostCrisis, isResistanceActive: appData.isTimerRunning, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSectionTitle(appData.t('response'), Icons.shield_rounded, themeAccent), 
          const SizedBox(height: 20), 
          
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(appData.t('urge_timer'), style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.bold)),
               GestureDetector(
                  onTap: () async {
                     int? val = await showGlassDurationPicker(context, appData.t('manual_delay'), appData.urgeSeconds ~/ 60, isDark, appData);
                     if (val != null) { appData.urgeSeconds = val * 60; appData.refreshUI(); }
                  },
                  child: Text(appData.t('edit_manually'), style: TextStyle(color: themeAccent, fontSize: 10, decoration: TextDecoration.underline, fontWeight: FontWeight.bold))
               )
             ]
          ),
           
          const SizedBox(height: 15), 
          Center(child: UrgeTimerDisplay(appData: appData)), 
          const SizedBox(height: 30), 
          Text(appData.t('compulsions'), style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.bold)), 
          const SizedBox(height: 15), 
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeOut, child: Column(children: List.generate(appData.compulsionUrgesCtrls.length, (i) { return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: AeroTextField(controller: appData.compulsionUrgesCtrls[i])), if (i > 0) Padding(padding: const EdgeInsets.only(left: 8.0), child: SizedBox(width: 40, height: 40, child: RubberBandButton(onTap: () => appData.removeCompulsionField(i), borderRadius: 12, baseColor: Colors.redAccent.withValues(alpha: 0.1), textColor: Colors.redAccent, padding: EdgeInsets.zero, child: const Icon(Icons.close, size: 20))))])); }))), 
          SizedBox(
            width: double.infinity, 
            child: RubberBandButton(
              onTap: appData.addCompulsionField, 
              baseColor: themeAccent.withValues(alpha: 0.15), 
              textColor: isDark ? themeAccent : const Color(0xFF374151), 
              child: Text(appData.t('add_compulsion').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))
            )
          ), 
          const SizedBox(height: 25), 
          
          Center(child: Text(appData.t('how_feel'), style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
          const SizedBox(height: 12),
          GlassSelector<FeelingStatus>(
            items: FeelingStatus.values,
            selectedItem: appData.selectedFeeling,
            onSelected: (val) => appData.setFeeling(val),
            labelBuilder: (val) => appData.translateFeeling(val),
          ),
          
          const SizedBox(height: 30),
          Row(
            children: [
              Text(appData.t('resisted'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  appData.resisted ? appData.t('nice_work') : (appData.compulsionUrgesCtrls.first.text.isNotEmpty ? appData.t('thats_okay') : ""),
                  style: TextStyle(color: appData.resisted ? AppStyles.lowDistress : textColor.withValues(alpha: 0.5), fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
              Switch(
                value: appData.resisted, 
                activeTrackColor: themeAccent, 
                onChanged: (val) { appData.resisted = val; appData.refreshUI(); }
              )
            ]
          )
        ])),

        // 5. Learning
        GlassCard(isPostCrisis: isPostCrisis, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSectionTitle(appData.t('learning'), Icons.lightbulb_outline_rounded, themeAccent), 
          const SizedBox(height: 20), 
          AeroTextField(controller: appData.predictedOutcomeCtrl, hint: appData.t('prediction'), maxLines: 2), 
          const SizedBox(height: 25), 
          MirrorSlider(label: appData.t('fear_confidence'), value: appData.fearConfidence, activeColor: themeAccent, onChanged: (val) { appData.fearConfidence = val; appData.refreshUI(); }), 
          const SizedBox(height: 20), 
          AeroTextField(controller: appData.actualOutcomeCtrl, hint: appData.t('actual'), maxLines: 2), 
          const SizedBox(height: 25), 
          MirrorSlider(label: appData.t('surprise'), value: appData.surpriseLevel, onChanged: (val) { appData.surpriseLevel = val; appData.refreshUI(); }), 
          const SizedBox(height: 25), 
          MirrorSlider(label: "${appData.t('anxiety')} (After)", value: appData.anxietyAfter, activeColor: const Color(0xFF4CAF50), onChanged: (val) { appData.anxietyAfter = val; appData.refreshUI(); })
        ])),

        const SizedBox(height: 20),
        
        if (isEditing) ...[
          Row(
            children: [
              Expanded(
                child: RubberBandButton(
                  onTap: () {
                    appData.clearForm();
                  },
                  baseColor: Colors.grey.withValues(alpha: 0.2),
                  textColor: textColor,
                  child: Text(
                    appData.t('cancel').toUpperCase(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: RubberBandButton(
                  onTap: () {
                    if (appData.saveSession()) {
                      showGlassAlert(context, appData.t('save'), appData.t('session_updated'), appData.isDarkMode, appData);
                    } else {
                      showGlassAlert(context, appData.t('error'), appData.t('fill_trigger'), appData.isDarkMode, appData, isError: true);
                    }
                  },
                  baseColor: AppStyles.lowDistress.withValues(alpha: 0.8),
                  textColor: Colors.white,
                  child: Text(
                    appData.t('update_session').toUpperCase(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          RubberBandButton(
            onTap: () {
              if (appData.saveSession()) {
                showGlassAlert(context, appData.t('save'), appData.t('session_logged'), appData.isDarkMode, appData);
              } else {
                showGlassAlert(context, appData.t('error'), appData.t('fill_trigger'), appData.isDarkMode, appData, isError: true);
              }
            },
            baseColor: themeAccent.withValues(alpha: 0.8),
            textColor: Colors.white,
            child: Text(
              appData.t('save').toUpperCase(),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: 20),
        
        // FIXED: Re-wired to directly trigger the JSON export backup
        RubberBandButton(
          onTap: () {
            if (appData.sessions.isEmpty) {
               showGlassAlert(context, appData.t('empty'), appData.t('no_data'), appData.isDarkMode, appData);
            } else {
               appData.exportBackup(); 
            }
          },
          baseColor: Colors.orangeAccent.withValues(alpha: 0.8),
          textColor: Colors.white,
          child: Text(
            appData.t('export').toUpperCase(),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 20),
        RubberBandButton(
          onTap: () async {
            bool success = await appData.importBackup();
            if (context.mounted && success) {
                showGlassAlert(context, appData.t('restore'), appData.t('backup_restored'), appData.isDarkMode, appData);
            }
          },
          baseColor: Colors.blueGrey.withValues(alpha: 0.3),
          textColor: textColor,
          child: Text(
            appData.t('restore').toUpperCase(),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 60),
        Center(child: Text(appData.t('history').toUpperCase(), style: TextStyle(color: textColor.withValues(alpha: 0.5), letterSpacing: 3.0, fontWeight: FontWeight.w900, fontSize: 14))), 
        const SizedBox(height: 30),
        
        ...appData.sessions.map((s) => OCDHistoryCard(session: s, appData: appData)),
        const SizedBox(height: 120), 
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color accent) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 22),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(), 
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 13
          ),
        )
      ],
    );
  }
}