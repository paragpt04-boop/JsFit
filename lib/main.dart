import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const JsFitApp());

// ═══ COLORS ═══
const cPurple = Color(0xFF6C35DE);
const cOrange = Color(0xFFFF6B35);
const cBg = Color(0xFF0F0F1A);
const cBg2 = Color(0xFF1A1A2E);
const cCard = Color(0xFF16213E);
const cWhite = Color(0xFFFFFFFF);
const cGrey = Color(0xFF8892B0);
const cGreen = Color(0xFF00D2AA);
const cRed = Color(0xFFFF5252);
const cYellow = Color(0xFFFFD600);

// ═══ USER PROFILE ═══
class UserProfile {
  UserProfile();
  int age = 0;
  String ageRange = "";
  String gender = "";
  double height = 0;
  double weight = 0;
  List<String> goals = [];
  String experience = "";
  int trainingDays = 3;
  String sessionTime = "45 min";
  List<String> equipment = [];
  List<String> limitations = [];
  double sleepHours = 7;
  String stressLevel = "Moderado";
  String workoutStyle = "Equilibrado";
  bool onboardingDone = false;
  Map<String, dynamic> toJson() => {
"age": age, "ageRange": ageRange, "gender": gender,
"height": height, "weight": weight, "goals": goals,
"experience": experience, "trainingDays": trainingDays,
"sessionTime": sessionTime, "equipment": equipment,
"limitations": limitations, "sleepHours": sleepHours,
"stressLevel": stressLevel, "workoutStyle": workoutStyle,
"onboardingDone": onboardingDone,
  };
  factory UserProfile.fromJson(Map<String, dynamic> j) {
    final p = UserProfile();
    p.age = j["age"] ?? 0;
    p.ageRange = j["ageRange"] ?? "";
    p.gender = j["gender"] ?? "";
    p.height = (j["height"] ?? 0).toDouble();
    p.weight = (j["weight"] ?? 0).toDouble();
    p.goals = List<String>.from(j["goals"] ?? []);
    p.experience = j["experience"] ?? "";
    p.trainingDays = j["trainingDays"] ?? 3;
    p.sessionTime = j["sessionTime"] ?? "45 min";
    p.equipment = List<String>.from(j["equipment"] ?? []);
    p.limitations = List<String>.from(j["limitations"] ?? []);
    p.sleepHours = (j["sleepHours"] ?? 7).toDouble();
    p.stressLevel = j["stressLevel"] ?? "Moderado";
    p.workoutStyle = j["workoutStyle"] ?? "Equilibrado";
    p.onboardingDone = j["onboardingDone"] ?? false;
    return p;
  }

  double get bmi => height > 0 ? weight / ((height/100) * (height/100)) : 0;

  double get dailyCalories {
    if (age == 0 || height == 0 || weight == 0) return 2000;
    double bmr;
    if (gender == "Hombre") {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }
    double factor = 1.375;
    if (trainingDays <= 2) factor = 1.2;
    else if (trainingDays <= 4) factor = 1.375;
    else if (trainingDays <= 6) factor = 1.55;
    else factor = 1.725;
    if (goals.contains("Perder grasa")) return bmr * factor - 300;
    if (goals.contains("Ganar musculo")) return bmr * factor + 300;
    return bmr * factor;
  }

  String get fitnessLevel {
    if (experience == "Sedentario total" || experience == "Principiante (nunca he entrenado)") return "Principiante";
    if (experience == "Principiante con algo de base" || experience == "Intermedio") return "Intermedio";
    return "Avanzado";
  }

  bool get isSenior => age >= 60;
  bool get isPregnant => limitations.contains("Embarazo");
  bool get isPostpartum => limitations.contains("Posparto");
}

// ═══ EXERCISE MODEL ═══
class Exercise {
  final String name, muscle, description, difficulty, emoji;
  final List<String> equipment, goodFor, variations;
  final String instructions, commonErrors;
  const Exercise({
required this.name, required this.muscle, required this.description,
required this.difficulty, required this.emoji,
this.equipment = const [], this.goodFor = const [],
this.variations = const [], this.instructions = "", this.commonErrors = "",
  });
}

// ═══ EXERCISE DATABASE ═══
const List<Exercise> exercises = [
  Exercise(name: "Sentadilla básica", muscle: "Piernas", description: "Ejercicio fundamental para piernas y glúteos",
difficulty: "Principiante", emoji: "🦵", equipment: ["Sin material"],
goodFor: ["Principiante", "Senior", "General"],
instructions: "1. Pies al ancho de hombros 2. Baja como si fueras a sentarte 3. Rodillas no sobrepasen punteras 4. Espalda recta",
commonErrors: "Rodillas hacia adentro, espalda arqueada",
variations: ["Sentadilla en silla (para mayores)", "Sentadilla con pausa", "Sentadilla sumo"]),
  Exercise(name: "Flexiones", muscle: "Pecho", description: "Clásico ejercicio de empuje",
difficulty: "Principiante", emoji: "💪", equipment: ["Sin material"],
goodFor: ["General", "Casa"],
instructions: "1. Manos al ancho de hombros 2. Cuerpo recto 3. Baja el pecho al suelo 4. Empuja hacia arriba",
commonErrors: "Cadera caida, codos muy abiertos",
variations: ["Flexiones en rodillas", "Flexiones en pared (principiantes)", "Flexiones diamante"]),
  Exercise(name: "Plancha", muscle: "Core", description: "Ejercicio isométrico para el core",
difficulty: "Principiante", emoji: "🏋️", equipment: ["Sin material"],
goodFor: ["General", "Embarazo (1er trimestre)", "Rehabilitación"],
instructions: "1. Apoyate en antebrazos y puntas de pies 2. Cuerpo recto como tabla 3. Manten la posicion",
commonErrors: "Cadera muy alta o muy baja",
variations: ["Plancha en rodillas", "Plancha lateral", "Plancha con toque de hombro"]),
  Exercise(name: "Sentadilla en silla", muscle: "Piernas", description: "Versión suave ideal para mayores",
difficulty: "Principiante", emoji: "🪑", equipment: ["Sin material"],
goodFor: ["Senior", "Movilidad reducida", "Rodillas"],
instructions: "1. Sientate al borde de la silla 2. Levantate lentamente 3. Vuelve a sentarte con control",
commonErrors: "Usar las manos para apoyarse demasiado",
variations: ["Con apoyo de manos al inicio"]),
  Exercise(name: "Marcha en sitio", muscle: "Cardio", description: "Cardio suave sin impacto",
difficulty: "Principiante", emoji: "🚶", equipment: ["Sin material"],
goodFor: ["Senior", "Principiante", "Embarazo", "Rodillas", "Posparto"],
instructions: "1. De pie, levanta las rodillas alternadas 2. Mueve los brazos 3. Manten ritmo constante",
commonErrors: "Levantar poco las rodillas",
variations: ["Marcha con elevación de brazos", "Marcha con giro de cadera"]),
  Exercise(name: "Curl de bíceps", muscle: "Brazos", description: "Ejercicio para bíceps",
difficulty: "Principiante", emoji: "💪", equipment: ["Mancuernas"],
goodFor: ["General", "Senior"],
instructions: "1. Sosten mancuernas con palmas hacia arriba 2. Dobla el codo hacia arriba 3. Baja con control",
commonErrors: "Balancear el torso, no bajar del todo",
variations: ["Curl martillo", "Curl concentrado", "Curl con banda"]),
  Exercise(name: "Peso muerto rumano", muscle: "Espalda / Isquios", description: "Trabaja cadena posterior",
difficulty: "Intermedio", emoji: "🏋️", equipment: ["Mancuernas"],
goodFor: ["General", "Fuerza"],
instructions: "1. Pies al ancho de caderas 2. Inclinate hacia adelante con espalda recta 3. Baja las mancuernas por las piernas 4. Sube apretando gluteos",
commonErrors: "Redondear la espalda",
variations: ["Con banda elástica", "Una pierna"]),
  Exercise(name: "Hip thrust", muscle: "Glúteos", description: "El mejor ejercicio para glúteos",
difficulty: "Principiante", emoji: "🍑", equipment: ["Sin material"],
goodFor: ["Mujeres", "General", "Posparto"],
instructions: "1. Apoya hombros en banco/sofa 2. Pies al ancho de caderas 3. Eleva las caderas apretando gluteos 4. Baja con control",
commonErrors: "No apretar gluteos arriba",
variations: ["Con banda elástica", "Una pierna", "En suelo"]),
  Exercise(name: "Remo con mancuerna", muscle: "Espalda", description: "Trabaja la espalda media",
difficulty: "Principiante", emoji: "🏋️", equipment: ["Mancuernas"],
goodFor: ["General", "Postura"],
instructions: "1. Apoya una rodilla en banco 2. Tira la mancuerna hacia la cadera 3. Codo pegado al cuerpo",
commonErrors: "Rotar el torso, no bajar del todo",
variations: ["Remo inclinado con dos mancuernas"]),
  Exercise(name: "Estiramiento de isquiotibiales", muscle: "Flexibilidad", description: "Estiramiento clave para la movilidad",
difficulty: "Principiante", emoji: "🧘", equipment: ["Sin material"],
goodFor: ["Senior", "Rehabilitación", "Embarazo", "Todos"],
instructions: "1. Sientate en el suelo con piernas extendidas 2. Inclinate hacia adelante 3. Manten 30 segundos",
commonErrors: "Redondear la espalda demasiado",
variations: ["De pie con apoyo en silla", "Sentado en silla"]),
  Exercise(name: "Press de hombros", muscle: "Hombros", description: "Trabaja deltoides",
difficulty: "Intermedio", emoji: "🏋️", equipment: ["Mancuernas"],
goodFor: ["General", "Fuerza"],
instructions: "1. Mancuernas a altura de hombros 2. Empuja hacia arriba 3. Baja con control",
commonErrors: "Arquear la espalda, bloquear codos",
variations: ["Sentado", "Con banda elástica"]),
  Exercise(name: "Zancadas", muscle: "Piernas", description: "Trabaja piernas y equilibrio",
difficulty: "Intermedio", emoji: "🦵", equipment: ["Sin material"],
goodFor: ["General", "Equilibrio"],
instructions: "1. Da un paso grande hacia adelante 2. Baja la rodilla trasera casi al suelo 3. Vuelve a la posicion inicial",
commonErrors: "Rodilla delantera sobre el pie",
variations: ["Zancada estática", "Zancada inversa (más suave para rodillas)", "Con mancuernas"]),
  Exercise(name: "Ejercicio de Kegel", muscle: "Suelo pélvico", description: "Fortalece el suelo pélvico",
difficulty: "Principiante", emoji: "🌸", equipment: ["Sin material"],
goodFor: ["Embarazo", "Posparto", "Mujeres", "Incontinencia"],
instructions: "1. Contrae los musculos del suelo pelvico 2. Manten 5-10 segundos 3. Relaja 4. Repite 10 veces",
commonErrors: "Contener la respiracion, contraer gluteos",
variations: ["Rápidos (contracciones rápidas)", "Con respiración"]),
  Exercise(name: "Rotaciones de tobillo", muscle: "Movilidad", description: "Mejora la movilidad del tobillo",
difficulty: "Principiante", emoji: "🦶", equipment: ["Sin material"],
goodFor: ["Senior", "Rehabilitación", "Principiante"],
instructions: "1. Sentado o de pie 2. Levanta un pie 3. Rota el tobillo en circulos 4. Cambia de direccion",
commonErrors: "Ninguno relevante",
variations: ["De pie con apoyo"]),
  Exercise(name: "Burpee modificado", muscle: "Full body", description: "Cardio funcional sin salto",
difficulty: "Intermedio", emoji: "🔥", equipment: ["Sin material"],
goodFor: ["General", "Cardio"],
instructions: "1. De pie, baja las manos al suelo 2. Camina los pies hacia atras a plancha 3. Camina hacia adelante 4. Levantate",
commonErrors: "Hacerlo muy rapido sin control",
variations: ["Sin el salto (versión suave)", "Versión completa con salto"]),
];

// ═══ WORKOUT TEMPLATES ═══
class WorkoutTemplate {
  final String name, description, duration, difficulty, emoji;
  final List<String> exerciseNames;
  final List<String> tags;
  const WorkoutTemplate({
required this.name, required this.description,
required this.duration, required this.difficulty,
required this.emoji, required this.exerciseNames,
this.tags = const [],
  });
}

List<WorkoutTemplate> getRecommendedWorkouts(UserProfile p) {
  final List<WorkoutTemplate> all = [
WorkoutTemplate(
name: "Inicio Suave", description: "Perfecto para comenzar sin experiencia",
duration: "20 min", difficulty: "Principiante", emoji: "🌱",
exerciseNames: ["Marcha en sitio", "Sentadilla básica", "Flexiones", "Plancha", "Estiramiento de isquiotibiales"],
tags: ["Principiante", "Sin material", "Casa"]),
WorkoutTemplate(
name: "Fuerza Total", description: "Rutina completa de fuerza con mancuernas",
duration: "45 min", difficulty: "Intermedio", emoji: "💪",
exerciseNames: ["Sentadilla básica", "Peso muerto rumano", "Remo con mancuerna", "Press de hombros", "Curl de bíceps"],
tags: ["Fuerza", "Mancuernas", "Intermedio"]),
WorkoutTemplate(
name: "Movilidad Senior", description: "Ejercicios suaves para mantener la movilidad",
duration: "25 min", difficulty: "Principiante", emoji: "🧘",
exerciseNames: ["Marcha en sitio", "Sentadilla en silla", "Rotaciones de tobillo", "Estiramiento de isquiotibiales"],
tags: ["Senior", "Movilidad", "Sin impacto"]),
WorkoutTemplate(
name: "Glúteos y Piernas", description: "Enfocado en tren inferior y glúteos",
duration: "35 min", difficulty: "Principiante", emoji: "🍑",
exerciseNames: ["Sentadilla básica", "Hip thrust", "Zancadas", "Sentadilla en silla"],
tags: ["Glúteos", "Piernas", "Mujeres"]),
WorkoutTemplate(
name: "Core y Postura", description: "Fortalece el core y mejora la postura",
duration: "20 min", difficulty: "Principiante", emoji: "🏋️",
exerciseNames: ["Plancha", "Hip thrust", "Remo con mancuerna", "Estiramiento de isquiotibiales"],
tags: ["Core", "Postura", "Espalda"]),
WorkoutTemplate(
name: "Embarazo Seguro", description: "Rutina especial para embarazadas",
duration: "20 min", difficulty: "Principiante", emoji: "🤰",
exerciseNames: ["Marcha en sitio", "Sentadilla básica", "Ejercicio de Kegel", "Estiramiento de isquiotibiales"],
tags: ["Embarazo", "Suave", "Sin impacto"]),
WorkoutTemplate(
name: "Posparto", description: "Recuperación gradual tras el parto",
duration: "15 min", difficulty: "Principiante", emoji: "🌸",
exerciseNames: ["Marcha en sitio", "Ejercicio de Kegel", "Hip thrust", "Estiramiento de isquiotibiales"],
tags: ["Posparto", "Suave", "Recuperación"]),
WorkoutTemplate(
name: "HIIT Suave", description: "Alta intensidad sin impacto",
duration: "30 min", difficulty: "Intermedio", emoji: "🔥",
exerciseNames: ["Marcha en sitio", "Burpee modificado", "Sentadilla básica", "Plancha", "Hip thrust"],
tags: ["Cardio", "HIIT", "Intermedio"]),
  ];
  return all.where((w) {
if (p.isPregnant && !w.tags.contains("Embarazo")) return false;
  if (p.isPostpartum && !w.tags.contains("Posparto") && !w.tags.contains("Suave")) return false;
  if (p.isSenior && w.difficulty == "Avanzado") return false;
  if (p.fitnessLevel == "Principiante" && w.difficulty == "Avanzado") return false;
  return true;
  }).toList();
}

// ═══ APP ═══
class JsFitApp extends StatelessWidget {
  const JsFitApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
title: 'JsFit',
debugShowCheckedModeBanner: false,
theme: ThemeData(
scaffoldBackgroundColor: cBg,
colorScheme: ColorScheme.dark(primary: cPurple, secondary: cOrange),
fontFamily: 'sans-serif',
),
home: const SplashScreen(),
  );
}

// ═══ SPLASH ═══
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _scale;
@override
  void initState() {
super.initState();
_ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
_scale = CurvedAnimation(parent: _ac, curve: Curves.elasticOut);
_ac.forward();
_init();
  }
Future<void> _init() async {
await Future.delayed(const Duration(milliseconds: 2000));
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString("profile");
  if (!mounted) return;
  if (data != null) {
final profile = UserProfile.fromJson(jsonDecode(data));
  if (profile.onboardingDone) {
Navigator.pushReplacement(context, MaterialPageRoute(
builder: (_) => MainScreen(profile: profile)));
  return;
}
    }
Navigator.pushReplacement(context, MaterialPageRoute(
builder: (_) => const OnboardingScreen()));
  }
@override
  void dispose() { _ac.dispose(); super.dispose(); }
@override
  Widget build(BuildContext context) => Scaffold(
backgroundColor: cBg,
body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
ScaleTransition(scale: _scale, child: Container(
width: 100, height: 100,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(24),
boxShadow: [BoxShadow(color: cPurple.withOpacity(0.4), blurRadius: 30)]),
child: ClipRRect(borderRadius: BorderRadius.circular(24),
child: Image.asset("android-icon/icon.png",
errorBuilder: (_, __, ___) => Container(
color: cPurple,
child: const Center(child: Text("JS", style: TextStyle(color: cWhite, fontSize: 36, fontWeight: FontWeight.bold)))))))),
const SizedBox(height: 20),
const Text("JsFit", style: TextStyle(color: cWhite, fontSize: 32, fontWeight: FontWeight.bold)),
const Text("Tu entrenador personal", style: TextStyle(color: cGrey, fontSize: 14)),
])),
  );
}

// ═══ ONBOARDING ═══
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardState();
}

class _OnboardState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _page = 0;
  final UserProfile _profile = UserProfile();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final int _totalPages = 10;
  void _next() {
if (_page < _totalPages - 1) {
_pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
} else {
_finish();
}
  }
void _prev() {
if (_page > 0) {
_pc.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
}
  }
Future<void> _finish() async {
_profile.onboardingDone = true;
  if (_heightCtrl.text.isNotEmpty) _profile.height = double.tryParse(_heightCtrl.text) ?? 0;
  if (_weightCtrl.text.isNotEmpty) _profile.weight = double.tryParse(_weightCtrl.text) ?? 0;
  if (_ageCtrl.text.isNotEmpty) _profile.age = int.tryParse(_ageCtrl.text) ?? 0;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("profile", jsonEncode(_profile.toJson()));
  if (!mounted) return;
  Navigator.pushReplacement(context, MaterialPageRoute(
builder: (_) => MainScreen(profile: _profile)));
  }
@override
  Widget build(BuildContext context) => Scaffold(
backgroundColor: cBg,
body: SafeArea(child: Column(children: [
// Progress bar
Container(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
child: Column(children: [
Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
if (_page > 0) GestureDetector(
onTap: _prev,
child: const Icon(Icons.arrow_back_ios, color: cGrey, size: 20))
else const SizedBox(width: 20),
Text("${_page + 1} / $_totalPages",
style: const TextStyle(color: cGrey, fontSize: 12)),
const SizedBox(width: 20),
]),
const SizedBox(height: 8),
LinearProgressIndicator(
value: (_page + 1) / _totalPages,
backgroundColor: cCard,
valueColor: const AlwaysStoppedAnimation(cPurple),
minHeight: 4,
borderRadius: BorderRadius.circular(2)),
])),
Expanded(child: PageView(
controller: _pc,
physics: const NeverScrollableScrollPhysics(),
onPageChanged: (i) => setState(() => _page = i),
children: [
_buildWelcomePage(),
_buildAgePage(),
_buildGenderPage(),
_buildMeasurementsPage(),
_buildGoalsPage(),
_buildExperiencePage(),
_buildSchedulePage(),
_buildEquipmentPage(),
_buildLimitationsPage(),
_buildLifestylePage(),
])),
])));
  Widget _buildWelcomePage() => _pageWrapper(
emoji: "🏋️",
title: "Bienvenido a JsFit",
subtitle: "Tu entrenador personal adaptado a TI. Vamos a conocerte para crear tu plan perfecto.",
child: Column(children: [
_infoCard("✅", "Planes 100% personalizados"),
_infoCard("🌍", "Para todo tipo de personas"),
_infoCard("🦮", "Adaptado a tus limitaciones"),
_infoCard("📈", "Progreso a tu ritmo"),
]),
onNext: _next);
  Widget _buildAgePage() => _pageWrapper(
emoji: "🎂",
title: "¿Cuántos años tienes?",
subtitle: "Adaptamos el entrenamiento según tu edad",
child: Column(children: [
Container(
margin: const EdgeInsets.symmetric(vertical: 8),
child: TextField(
controller: _ageCtrl,
keyboardType: TextInputType.number,
style: const TextStyle(color: cWhite, fontSize: 32, fontWeight: FontWeight.bold),
textAlign: TextAlign.center,
decoration: InputDecoration(
hintText: "25",
hintStyle: TextStyle(color: cGrey.withOpacity(0.5), fontSize: 32),
filled: true, fillColor: cCard,
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(color: cPurple)),
focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(color: cPurple, width: 2)),
suffixText: "años", suffixStyle: const TextStyle(color: cGrey)))),
const SizedBox(height: 12),
...["13-17 años", "18-35 años", "36-50 años", "51-65 años", "65+ años"].map((r) =>
_selectChip(r, _profile.ageRange == r, () => setState(() {
_profile.ageRange = r;
  final parts = r.split("-");
  if (parts.isNotEmpty) {
_ageCtrl.text = parts[0].replaceAll(RegExp(r"[^0-9]"), "");
}
        }))),
]),
onNext: _next);
  Widget _buildGenderPage() => _pageWrapper(
emoji: "👤",
title: "¿Cómo te identificas?",
subtitle: "Esto nos ayuda a calcular mejor tus necesidades",
child: Column(children: [
...["Hombre", "Mujer", "No binario", "Prefiero no decir"].map((g) =>
_selectChip(g, _profile.gender == g, () => setState(() => _profile.gender = g))),
]),
onNext: _next);
  Widget _buildMeasurementsPage() => _pageWrapper(
emoji: "📏",
title: "Tu altura y peso",
subtitle: "Para calcular tu índice de masa corporal y calorías",
child: Column(children: [
_inputField("Altura", _heightCtrl, "170", "cm"),
const SizedBox(height: 12),
_inputField("Peso actual", _weightCtrl, "70", "kg"),
const SizedBox(height: 8),
Text("Tus datos son privados y solo se usan localmente",
style: TextStyle(color: cGrey.withOpacity(0.7), fontSize: 11),
textAlign: TextAlign.center),
]),
onNext: _next);
  Widget _buildGoalsPage() => _pageWrapper(
emoji: "🎯",
title: "¿Cuál es tu objetivo?",
subtitle: "Puedes seleccionar varios",
child: Column(children: [
...["Perder grasa / Adelgazar", "Ganar músculo / Hipertrofia", "Mejorar fuerza",
"Mejorar resistencia cardiovascular", "Mejorar movilidad y flexibilidad",
"Rehabilitación / Recuperación", "Salud general y bienestar",
"Mantenerse en forma"].map((g) => _multiChip(g, _profile.goals.contains(g),
() => setState(() => _profile.goals.contains(g) ? _profile.goals.remove(g) : _profile.goals.add(g)))),
]),
onNext: _next);
  Widget _buildExperiencePage() => _pageWrapper(
emoji: "⭐",
title: "Tu nivel de experiencia",
subtitle: "Sé honesto, ajustaremos la dificultad",
child: Column(children: [
...["Sedentario total", "Principiante (nunca he entrenado)", "Principiante con algo de base",
"Intermedio", "Avanzado", "Atleta / Competidor"].map((e) =>
_selectChip(e, _profile.experience == e, () => setState(() => _profile.experience = e))),
]),
onNext: _next);
  Widget _buildSchedulePage() => _pageWrapper(
emoji: "📅",
title: "Tu disponibilidad",
subtitle: "¿Cuántos días y tiempo tienes?",
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text("Días por semana: ${_profile.trainingDays}",
style: const TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)),
Slider(
value: _profile.trainingDays.toDouble(), min: 1, max: 7,
divisions: 6, activeColor: cPurple, inactiveColor: cCard,
label: "${_profile.trainingDays} días",
onChanged: (v) => setState(() => _profile.trainingDays = v.round())),
const SizedBox(height: 12),
Text("Tiempo por sesión:", style: const TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 8),
...["15 min", "30 min", "45 min", "60+ min"].map((t) =>
_selectChip(t, _profile.sessionTime == t, () => setState(() => _profile.sessionTime = t))),
]),
onNext: _next);
  Widget _buildEquipmentPage() => _pageWrapper(
emoji: "🏋️",
title: "¿Qué equipamiento tienes?",
subtitle: "Selecciona todo lo disponible",
child: Column(children: [
...["Sin material (solo peso corporal)", "Mancuernas", "Bandas elásticas",
"Kettlebells", "Gimnasio completo", "Casa con objetos improvisados"].map((e) =>
_multiChip(e, _profile.equipment.contains(e),
() => setState(() => _profile.equipment.contains(e) ? _profile.equipment.remove(e) : _profile.equipment.add(e)))),
]),
onNext: _next);
  Widget _buildLimitationsPage() => _pageWrapper(
emoji: "🏥",
title: "Lesiones o limitaciones",
subtitle: "Para adaptar los ejercicios y mantenerte seguro",
child: Column(children: [
...["Ninguna", "Espalda baja", "Rodillas", "Hombros", "Muñecas", "Cervicales",
"Artritis", "Hipertensión", "Problemas cardíacos", "Embarazo", "Posparto"].map((l) =>
_multiChip(l, _profile.limitations.contains(l),
() => setState(() {
if (l == "Ninguna") { _profile.limitations.clear(); _profile.limitations.add(l); return; }
_profile.limitations.remove("Ninguna");
_profile.limitations.contains(l) ? _profile.limitations.remove(l) : _profile.limitations.add(l);
}))),
]),
onNext: _next);
  Widget _buildLifestylePage() => _pageWrapper(
emoji: "😴",
title: "Estilo de vida",
subtitle: "Últimas preguntas para completar tu perfil",
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text("Horas de sueño: ${_profile.sleepHours.toStringAsFixed(0)}h",
style: const TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)),
Slider(
value: _profile.sleepHours, min: 4, max: 10,
divisions: 6, activeColor: cPurple, inactiveColor: cCard,
label: "${_profile.sleepHours.toStringAsFixed(0)}h",
onChanged: (v) => setState(() => _profile.sleepHours = v)),
const SizedBox(height: 12),
Text("Nivel de estrés:", style: const TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 8),
...["Bajo", "Moderado", "Alto", "Muy alto"].map((s) =>
_selectChip(s, _profile.stressLevel == s, () => setState(() => _profile.stressLevel = s))),
const SizedBox(height: 12),
Text("Estilo preferido:", style: const TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 8),
...["Corto e intenso", "Equilibrado", "Largo y controlado"].map((s) =>
_selectChip(s, _profile.workoutStyle == s, () => setState(() => _profile.workoutStyle = s))),
]),
onNext: _finish);
  Widget _pageWrapper({required String emoji, required String title, required String subtitle,
required Widget child, required VoidCallback onNext}) {
return SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(emoji, style: const TextStyle(fontSize: 48)),
const SizedBox(height: 12),
Text(title, style: const TextStyle(color: cWhite, fontSize: 26, fontWeight: FontWeight.bold)),
const SizedBox(height: 6),
Text(subtitle, style: const TextStyle(color: cGrey, fontSize: 14)),
const SizedBox(height: 24),
child,
const SizedBox(height: 24),
SizedBox(width: double.infinity, child: ElevatedButton(
onPressed: onNext,
style: ElevatedButton.styleFrom(
backgroundColor: cPurple, padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
child: Text(_page == _totalPages - 1 ? "¡Comenzar!" : "Continuar",
style: const TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)))),
]));
  }
Widget _selectChip(String label, bool selected, VoidCallback onTap) => GestureDetector(
onTap: onTap,
child: Container(
width: double.infinity,
margin: const EdgeInsets.only(bottom: 8),
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
decoration: BoxDecoration(
color: selected ? cPurple.withOpacity(0.2) : cCard,
borderRadius: BorderRadius.circular(12),
border: Border.all(color: selected ? cPurple : cCard.withOpacity(0.5), width: 2)),
child: Row(children: [
Expanded(child: Text(label, style: TextStyle(
color: selected ? cWhite : cGrey,
fontSize: 15, fontWeight: selected ? FontWeight.bold : FontWeight.normal))),
if (selected) const Icon(Icons.check_circle, color: cPurple, size: 20),
])));
  Widget _multiChip(String label, bool selected, VoidCallback onTap) => _selectChip(label, selected, onTap);
  Widget _inputField(String label, TextEditingController ctrl, String hint, String suffix) => TextField(
controller: ctrl,
keyboardType: TextInputType.number,
style: const TextStyle(color: cWhite, fontSize: 18),
decoration: InputDecoration(
labelText: label, labelStyle: const TextStyle(color: cGrey),
hintText: hint, hintStyle: TextStyle(color: cGrey.withOpacity(0.4)),
suffixText: suffix, suffixStyle: const TextStyle(color: cGrey),
filled: true, fillColor: cCard,
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(color: cPurple, width: 2))));
  Widget _infoCard(String emoji, String text) => Container(
width: double.infinity,
margin: const EdgeInsets.only(bottom: 8),
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12)),
child: Row(children: [
Text(emoji, style: const TextStyle(fontSize: 20)),
const SizedBox(width: 12),
Text(text, style: const TextStyle(color: cWhite, fontSize: 15)),
]));
}

// ═══ MAIN SCREEN ═══
class MainScreen extends StatefulWidget {
  final UserProfile profile;
  const MainScreen({super.key, required this.profile});
  @override
  State<MainScreen> createState() => _MainState();
}

class _MainState extends State<MainScreen> {
  int _tab = 0;
  late UserProfile _profile;
@override
  void initState() {
super.initState();
_profile = widget.profile;
  }
@override
  Widget build(BuildContext context) => Scaffold(
backgroundColor: cBg,
body: IndexedStack(index: _tab, children: [
HomeTab(profile: _profile),
WorkoutsTab(profile: _profile),
ExercisesTab(profile: _profile),
ProfileTab(profile: _profile, onUpdate: (p) async {
setState(() => _profile = p);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("profile", jsonEncode(p.toJson()));
}),
]),
bottomNavigationBar: Container(
decoration: BoxDecoration(
color: cBg2,
border: Border(top: BorderSide(color: cCard))),
child: BottomNavigationBar(
currentIndex: _tab,
onTap: (i) => setState(() => _tab = i),
backgroundColor: Colors.transparent,
selectedItemColor: cPurple,
unselectedItemColor: cGrey,
type: BottomNavigationBarType.fixed,
elevation: 0,
items: const [
BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Entrena"),
BottomNavigationBarItem(icon: Icon(Icons.list), label: "Ejercicios"),
BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
])));
}

// ═══ HOME TAB ═══
class HomeTab extends StatelessWidget {
  final UserProfile profile;
  const HomeTab({super.key, required this.profile});
@override
  Widget build(BuildContext context) {
final workouts = getRecommendedWorkouts(profile);
  final greeting = _greeting();
  return Scaffold(
backgroundColor: cBg,
body: SafeArea(child: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// Header
Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(greeting, style: const TextStyle(color: cGrey, fontSize: 14)),
Text("¡Hola, campeón! 💪", style: const TextStyle(color: cWhite, fontSize: 22, fontWeight: FontWeight.bold)),
]),
Container(
width: 48, height: 48,
decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
boxShadow: [BoxShadow(color: cPurple.withOpacity(0.3), blurRadius: 10)]),
child: ClipRRect(borderRadius: BorderRadius.circular(12),
child: Image.asset("android-icon/icon.png",
errorBuilder: (_, __, ___) => Container(color: cPurple,
child: const Center(child: Text("JS", style: TextStyle(color: cWhite, fontWeight: FontWeight.bold))))))),
]),
const SizedBox(height: 20),
// Stats cards
Row(children: [
Expanded(child: _statCard("💧", "Calorías", "${profile.dailyCalories.toStringAsFixed(0)} kcal", cPurple)),
const SizedBox(width: 10),
Expanded(child: _statCard("⚖️", "IMC", profile.bmi > 0 ? profile.bmi.toStringAsFixed(1) : "N/A", cOrange)),
const SizedBox(width: 10),
Expanded(child: _statCard("🎯", "Días/sem", "${profile.trainingDays}", cGreen)),
]),
const SizedBox(height: 20),
// Special alerts
if (profile.isPregnant) _alertCard("🤰", "Modo Embarazo Activo", "Rutinas adaptadas para ti", cOrange),
if (profile.isPostpartum) _alertCard("🌸", "Modo Posparto Activo", "Recuperación gradual y segura", cGreen),
if (profile.isSenior) _alertCard("🧘", "Modo Senior Activo", "Ejercicios suaves y de movilidad", cPurple),
if (profile.limitations.isNotEmpty && !profile.limitations.contains("Ninguna"))
_alertCard("⚠️", "Limitaciones detectadas", "Ejercicios adaptados a tu condición", cYellow),
// Recommended workout
if (workouts.isNotEmpty) ...[
const Text("🔥 Entrenamiento del día", style: TextStyle(color: cWhite, fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
_workoutCard(context, workouts.first, true),
],
const SizedBox(height: 20),
const Text("📋 Más rutinas para ti", style: TextStyle(color: cWhite, fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
...workouts.skip(1).take(4).map((w) => _workoutCard(context, w, false)),
const SizedBox(height: 20),
// Motivation
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
gradient: const LinearGradient(colors: [cPurple, Color(0xFF9C27B0)]),
borderRadius: BorderRadius.circular(16)),
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
const Text("💡 Consejo del día", style: TextStyle(color: cWhite, fontSize: 12, fontWeight: FontWeight.bold)),
const SizedBox(height: 6),
Text(_motivationalTip(profile), style: const TextStyle(color: cWhite, fontSize: 14)),
])),
]))));
  }
String _greeting() {
final h = DateTime.now().hour;
  if (h < 12) return "Buenos días";
  if (h < 18) return "Buenas tardes";
  return "Buenas noches";
  }
String _motivationalTip(UserProfile p) {
if (p.isPregnant) return "Durante el embarazo, el ejercicio moderado es beneficioso. Escucha siempre a tu cuerpo.";
  if (p.isSenior) return "La constancia es más importante que la intensidad. ¡Cada movimiento cuenta!";
  if (p.fitnessLevel == "Principiante") return "El primer paso es siempre el más difícil. ¡Ya lo diste al abrir esta app!";
  return "La recuperación es parte del entrenamiento. Duerme bien y mantente hidratado.";
  }
Widget _statCard(String emoji, String label, String value, Color color) => Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
border: Border.all(color: color.withOpacity(0.3))),
child: Column(children: [
Text(emoji, style: const TextStyle(fontSize: 20)),
const SizedBox(height: 4),
Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
Text(label, style: const TextStyle(color: cGrey, fontSize: 10)),
]));
  Widget _alertCard(String emoji, String title, String sub, Color color) => Container(
margin: const EdgeInsets.only(bottom: 10),
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
border: Border.all(color: color.withOpacity(0.4))),
child: Row(children: [
Text(emoji, style: const TextStyle(fontSize: 24)),
const SizedBox(width: 10),
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
Text(sub, style: const TextStyle(color: cGrey, fontSize: 11)),
]),
]));
  Widget _workoutCard(BuildContext context, WorkoutTemplate w, bool featured) => GestureDetector(
onTap: () => Navigator.push(context, MaterialPageRoute(
builder: (_) => WorkoutDetailScreen(workout: w, profile: profile))),
child: Container(
width: double.infinity,
margin: const EdgeInsets.only(bottom: 10),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
gradient: featured ? const LinearGradient(
begin: Alignment.topLeft, end: Alignment.bottomRight,
colors: [Color(0xFF2D1B69), Color(0xFF6C35DE)]) : null,
color: featured ? null : cCard,
borderRadius: BorderRadius.circular(16),
border: featured ? null : Border.all(color: cBg2)),
child: Row(children: [
Text(w.emoji, style: TextStyle(fontSize: featured ? 36.0 : 28.0)),
const SizedBox(width: 12),
Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(w.name, style: const TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)),
Text(w.description, style: const TextStyle(color: cGrey, fontSize: 12)),
const SizedBox(height: 6),
Row(children: [
_tag(w.duration, cPurple),
const SizedBox(width: 6),
_tag(w.difficulty, cOrange),
]),
])),
const Icon(Icons.arrow_forward_ios, color: cGrey, size: 16),
])));
  Widget _tag(String text, Color color) => Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)));
}

// ═══ WORKOUTS TAB ═══
class WorkoutsTab extends StatelessWidget {
  final UserProfile profile;
  const WorkoutsTab({super.key, required this.profile});
@override
  Widget build(BuildContext context) {
final workouts = getRecommendedWorkouts(profile);
  return Scaffold(
backgroundColor: cBg,
appBar: AppBar(backgroundColor: cBg, elevation: 0,
title: const Text("Entrenamientos", style: TextStyle(color: cWhite, fontWeight: FontWeight.bold))),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
const Text("🎯 Recomendados para ti", style: TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 12),
...workouts.map((w) => GestureDetector(
onTap: () => Navigator.push(context, MaterialPageRoute(
builder: (_) => WorkoutDetailScreen(workout: w, profile: profile))),
child: Container(
margin: const EdgeInsets.only(bottom: 10),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(16)),
child: Row(children: [
Text(w.emoji, style: const TextStyle(fontSize: 32)),
const SizedBox(width: 12),
Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(w.name, style: const TextStyle(color: cWhite, fontSize: 15, fontWeight: FontWeight.bold)),
Text(w.description, style: const TextStyle(color: cGrey, fontSize: 12)),
const SizedBox(height: 6),
Wrap(spacing: 6, children: [
_tag(w.duration, cPurple),
_tag(w.difficulty, cOrange),
...w.tags.take(2).map((t) => _tag(t, cGreen)),
]),
])),
const Icon(Icons.play_circle, color: cPurple, size: 28),
])))),
])));
  }
Widget _tag(String text, Color color) => Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)));
}

// ═══ WORKOUT DETAIL ═══
class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutTemplate workout;
  final UserProfile profile;
  const WorkoutDetailScreen({super.key, required this.workout, required this.profile});
  @override
  State<WorkoutDetailScreen> createState() => _WDS();
}

class _WDS extends State<WorkoutDetailScreen> {
  bool _started = false;
  int _currentExercise = 0;
  int _seconds = 0;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _seconds = 0;
  }

  String get _timeStr {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }
  List<Exercise> get _exercises => widget.workout.exerciseNames
.map((name) => exercises.firstWhere((e) => e.name == name,
orElse: () => Exercise(name: name, muscle: "", description: "", difficulty: "Principiante", emoji: "💪")))
.toList();
@override
  Widget build(BuildContext context) => Scaffold(
backgroundColor: cBg,
appBar: AppBar(
backgroundColor: cBg, elevation: 0,
leading: IconButton(icon: const Icon(Icons.arrow_back, color: cWhite), onPressed: () => Navigator.pop(context)),
title: Text(widget.workout.name, style: const TextStyle(color: cWhite, fontWeight: FontWeight.bold))),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// Header
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: const LinearGradient(colors: [Color(0xFF2D1B69), Color(0xFF6C35DE)]),
borderRadius: BorderRadius.circular(16)),
child: Row(children: [
Text(widget.workout.emoji, style: const TextStyle(fontSize: 48)),
const SizedBox(width: 16),
Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(widget.workout.name, style: const TextStyle(color: cWhite, fontSize: 20, fontWeight: FontWeight.bold)),
Text(widget.workout.description, style: const TextStyle(color: cGrey, fontSize: 13)),
const SizedBox(height: 8),
Row(children: [
_info("⏱", widget.workout.duration),
const SizedBox(width: 12),
_info("📊", widget.workout.difficulty),
const SizedBox(width: 12),
_info("🏋️", "${_exercises.length} ejercicios"),
]),
])),
])),
const SizedBox(height: 20),
const Text("📋 Ejercicios", style: TextStyle(color: cWhite, fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
..._exercises.asMap().entries.map((e) => GestureDetector(
onTap: () => Navigator.push(context, MaterialPageRoute(
builder: (_) => ExerciseDetailScreen(exercise: e.value))),
child: Container(
margin: const EdgeInsets.only(bottom: 8),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: cCard, borderRadius: BorderRadius.circular(12),
border: Border.all(color: cBg2)),
child: Row(children: [
Container(
width: 36, height: 36,
decoration: BoxDecoration(color: cPurple.withOpacity(0.2), shape: BoxShape.circle),
child: Center(child: Text("${e.key + 1}", style: const TextStyle(color: cPurple, fontWeight: FontWeight.bold)))),
const SizedBox(width: 12),
Text(e.value.emoji, style: const TextStyle(fontSize: 24)),
const SizedBox(width: 8),
Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(e.value.name, style: const TextStyle(color: cWhite, fontSize: 14, fontWeight: FontWeight.bold)),
Text(e.value.muscle, style: const TextStyle(color: cGrey, fontSize: 12)),
])),
const Icon(Icons.info_outline, color: cGrey, size: 18),
])))),
const SizedBox(height: 20),
SizedBox(width: double.infinity, child: ElevatedButton.icon(
onPressed: () => setState(() => _started = !_started),
style: ElevatedButton.styleFrom(
backgroundColor: _started ? cRed : cPurple,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
icon: Icon(_started ? Icons.stop : Icons.play_arrow, color: cWhite),
label: Text(_started ? "Detener entrenamiento" : "¡Comenzar ahora!",
style: const TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)))),
])));
  Widget _info(String emoji, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
Text(emoji, style: const TextStyle(fontSize: 14)),
const SizedBox(width: 4),
Text(text, style: const TextStyle(color: cWhite, fontSize: 12)),
  ]);
}

// ═══ EXERCISES TAB ═══
class ExercisesTab extends StatefulWidget {
  final UserProfile profile;
  const ExercisesTab({super.key, required this.profile});
  @override
  State<ExercisesTab> createState() => _ExTab();
}

class _ExTab extends State<ExercisesTab> {
  String _filter = "Todos";
  final _filters = ["Todos", "Piernas", "Pecho", "Espalda", "Brazos", "Core", "Cardio", "Flexibilidad", "Movilidad"];
  List<Exercise> get _filtered => _filter == "Todos" ? exercises :
exercises.where((e) => e.muscle.contains(_filter)).toList();
@override
  Widget build(BuildContext context) => Scaffold(
backgroundColor: cBg,
appBar: AppBar(backgroundColor: cBg, elevation: 0,
title: const Text("Ejercicios", style: TextStyle(color: cWhite, fontWeight: FontWeight.bold))),
body: Column(children: [
// Filters
SizedBox(height: 50, child: ListView.builder(
scrollDirection: Axis.horizontal,
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
itemCount: _filters.length,
itemBuilder: (_, i) => GestureDetector(
onTap: () => setState(() => _filter = _filters[i]),
child: Container(
margin: const EdgeInsets.only(right: 8),
padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
decoration: BoxDecoration(
color: _filter == _filters[i] ? cPurple : cCard,
borderRadius: BorderRadius.circular(20)),
child: Text(_filters[i], style: TextStyle(
color: _filter == _filters[i] ? cWhite : cGrey,
fontSize: 13, fontWeight: FontWeight.bold)))))),
// List
Expanded(child: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: _filtered.length,
itemBuilder: (_, i) {
final ex = _filtered[i];
  return GestureDetector(
onTap: () => Navigator.push(context, MaterialPageRoute(
builder: (_) => ExerciseDetailScreen(exercise: ex))),
child: Container(
margin: const EdgeInsets.only(bottom: 8),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12)),
child: Row(children: [
Text(ex.emoji, style: const TextStyle(fontSize: 32)),
const SizedBox(width: 12),
Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(ex.name, style: const TextStyle(color: cWhite, fontSize: 14, fontWeight: FontWeight.bold)),
Text(ex.muscle, style: const TextStyle(color: cGrey, fontSize: 12)),
const SizedBox(height: 4),
Row(children: [
_tag(ex.difficulty, ex.difficulty == "Principiante" ? cGreen :
ex.difficulty == "Intermedio" ? cOrange : cRed),
const SizedBox(width: 6),
if (ex.equipment.isNotEmpty) _tag(ex.equipment.first, cPurple),
]),
])),
const Icon(Icons.arrow_forward_ios, color: cGrey, size: 14),
])));
})),
]));
  Widget _tag(String text, Color color) => Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)));
}

// ═══ EXERCISE DETAIL ═══
class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});
@override
  Widget build(BuildContext context) => Scaffold(
backgroundColor: cBg,
appBar: AppBar(backgroundColor: cBg, elevation: 0,
leading: IconButton(icon: const Icon(Icons.arrow_back, color: cWhite), onPressed: () => Navigator.pop(context)),
title: Text(exercise.name, style: const TextStyle(color: cWhite, fontWeight: FontWeight.bold))),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Center(child: Text(exercise.emoji, style: const TextStyle(fontSize: 80))),
const SizedBox(height: 16),
Center(child: Text(exercise.name, style: const TextStyle(color: cWhite, fontSize: 24, fontWeight: FontWeight.bold))),
const SizedBox(height: 8),
Center(child: Text(exercise.description, style: const TextStyle(color: cGrey, fontSize: 14), textAlign: TextAlign.center)),
const SizedBox(height: 16),
Wrap(spacing: 8, runSpacing: 6, children: [
_chip("💪 " + exercise.muscle, cPurple),
_chip("📊 " + exercise.difficulty, cOrange),
...exercise.equipment.map((e) => _chip("🏋️ " + e, cGreen)),
...exercise.goodFor.map((e) => _chip("✅ " + e, cGrey)),
]),
if (exercise.instructions.isNotEmpty) ...[
const SizedBox(height: 20),
_section("📋 Instrucciones", exercise.instructions),
],
if (exercise.commonErrors.isNotEmpty) ...[
const SizedBox(height: 16),
_section("⚠️ Errores comunes", exercise.commonErrors),
],
if (exercise.variations.isNotEmpty) ...[
const SizedBox(height: 16),
const Text("🔄 Variaciones", style: TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 8),
...exercise.variations.map((v) => Container(
margin: const EdgeInsets.only(bottom: 6),
padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(8)),
child: Row(children: [
const Icon(Icons.arrow_right, color: cPurple),
const SizedBox(width: 8),
Expanded(child: Text(v, style: const TextStyle(color: cWhite, fontSize: 13))),
]))),
],
])));
  Widget _chip(String text, Color color) => Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)));
  Widget _section(String title, String content) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(title, style: const TextStyle(color: cWhite, fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 8),
Container(
width: double.infinity,
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12)),
child: Text(content, style: const TextStyle(color: cWhite, fontSize: 14, height: 1.6))),
  ]);
}

// ═══ PROFILE TAB ═══
class ProfileTab extends StatelessWidget {
  final UserProfile profile;
  final Function(UserProfile) onUpdate;
  const ProfileTab({super.key, required this.profile, required this.onUpdate});
@override
  Widget build(BuildContext context) => Scaffold(
backgroundColor: cBg,
appBar: AppBar(backgroundColor: cBg, elevation: 0,
title: const Text("Mi Perfil", style: TextStyle(color: cWhite, fontWeight: FontWeight.bold)),
actions: [
TextButton(
onPressed: () async {
final prefs = await SharedPreferences.getInstance();
  await prefs.remove("profile");
  Navigator.pushReplacement(context, MaterialPageRoute(
builder: (_) => const OnboardingScreen()));
},
child: const Text("Reiniciar", style: TextStyle(color: cRed))),
]),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(children: [
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
gradient: const LinearGradient(colors: [Color(0xFF2D1B69), cPurple]),
borderRadius: BorderRadius.circular(16)),
child: Column(children: [
Container(
width: 80, height: 80,
decoration: BoxDecoration(shape: BoxShape.circle,
border: Border.all(color: cWhite.withOpacity(0.3), width: 3)),
child: ClipRRect(borderRadius: BorderRadius.circular(40),
child: Image.asset("android-icon/icon.png",
errorBuilder: (_, __, ___) => Container(color: cPurple,
child: const Center(child: Text("JS", style: TextStyle(color: cWhite, fontSize: 28, fontWeight: FontWeight.bold))))))),
const SizedBox(height: 12),
Text(profile.gender.isNotEmpty ? profile.gender : "Atleta", style: const TextStyle(color: cWhite, fontSize: 20, fontWeight: FontWeight.bold)),
Text(profile.experience.isNotEmpty ? profile.experience : "Nivel desconocido", style: TextStyle(color: cWhite.withOpacity(0.7), fontSize: 13)),
])),
const SizedBox(height: 16),
_infoSection("📊 Datos físicos", [
_infoRow("Edad", profile.age > 0 ? "${profile.age} años" : "No especificado"),
_infoRow("Altura", profile.height > 0 ? "${profile.height.toStringAsFixed(0)} cm" : "No especificado"),
_infoRow("Peso", profile.weight > 0 ? "${profile.weight.toStringAsFixed(1)} kg" : "No especificado"),
_infoRow("IMC", profile.bmi > 0 ? profile.bmi.toStringAsFixed(1) : "N/A"),
_infoRow("Calorías/día", "${profile.dailyCalories.toStringAsFixed(0)} kcal"),
]),
const SizedBox(height: 12),
_infoSection("🎯 Objetivos", profile.goals.isNotEmpty ?
profile.goals.map((g) => _infoRow("•", g)).toList() :
[_infoRow("•", "No especificado")]),
const SizedBox(height: 12),
_infoSection("🏋️ Entrenamiento", [
_infoRow("Días/semana", "${profile.trainingDays} días"),
_infoRow("Tiempo/sesión", profile.sessionTime),
_infoRow("Nivel", profile.fitnessLevel),
]),
if (profile.limitations.isNotEmpty && !profile.limitations.contains("Ninguna")) ...[
const SizedBox(height: 12),
_infoSection("⚠️ Limitaciones", profile.limitations.map((l) => _infoRow("•", l)).toList()),
],
const SizedBox(height: 20),
if (profile.limitations.isNotEmpty && !profile.limitations.contains("Ninguna"))
Container(
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: cYellow.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
border: Border.all(color: cYellow.withOpacity(0.3))),
child: const Row(children: [
Text("⚕️", style: TextStyle(fontSize: 20)),
SizedBox(width: 10),
Expanded(child: Text("Consulta con tu médico antes de iniciar un programa de ejercicios si tienes condiciones de salud.",
style: TextStyle(color: cYellow, fontSize: 12))),
])),
])));
  Widget _infoSection(String title, List<Widget> rows) => Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(color: cCard, borderRadius: BorderRadius.circular(12)),
child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Text(title, style: const TextStyle(color: cWhite, fontSize: 15, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
...rows,
]));
  Widget _infoRow(String label, String value) => Padding(
padding: const EdgeInsets.only(bottom: 6),
child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
Text(label, style: const TextStyle(color: cGrey, fontSize: 13)),
Flexible(child: Text(value, style: const TextStyle(color: cWhite, fontSize: 13, fontWeight: FontWeight.w500),
textAlign: TextAlign.right)),
]));
}
// v1779782416
