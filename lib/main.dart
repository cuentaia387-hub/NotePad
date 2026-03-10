import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/note.dart';
import 'providers/notes_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización sincrónica y persistente usando Hive
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  
  // Abrimos la caja de notas de manera asíncrona pero antes de ejecutar la APP
  await Hive.openBox<Note>('notes_box');

  runApp(const NotepadApp());
}

class NotepadApp extends StatelessWidget {
  const NotepadApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: MaterialApp(
        title: 'Glassmorphism Notepad',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
