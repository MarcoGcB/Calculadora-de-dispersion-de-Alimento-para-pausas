import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalculadoraPage(),
    );
  }
}

class CalculadoraPage extends StatefulWidget {
  const CalculadoraPage({super.key});


  @override
  CalculadoraPageState createState() => CalculadoraPageState();
}

class CalculadoraPageState extends State<CalculadoraPage> {
  final dosisController = TextEditingController();

  DateTime? horaInicio;
  DateTime? horaFin;
  Duration? pausa;

  String resultado = "";

  Future<void> seleccionarHora(bool esInicio) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      DateTime seleccionada = DateTime(2026, 1, 1, picked.hour, picked.minute);
      setState(() {
        if (esInicio) {
          horaInicio = seleccionada;
        } else {
          horaFin = seleccionada;
        }
      });
    }
  }

  Future<void> seleccionarPausa() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 30),
    );
    if (picked != null) {
      setState(() {
        pausa = Duration(hours: picked.hour, minutes: picked.minute);
      });
    }
  }

  void calcular() {
    if (horaInicio == null || horaFin == null || pausa == null) return;

    int dosis = int.parse(dosisController.text);

    int minutosTotales = horaFin!.difference(horaInicio!).inMinutes;
    int minutosEfectivos = minutosTotales - pausa!.inMinutes;
    double dosisReal = dosis * (minutosEfectivos / minutosTotales);
    DateTime horaInicioReal = horaInicio!.add(pausa!);

    setState(() {
      resultado =
          "Hora real inicio: ${DateFormat("HH:mm").format(horaInicioReal)}\n"
          "Hora fin: ${DateFormat("HH:mm").format(horaFin!)}\n"
          "Rango total: $minutosTotales min\n"
          "Minutos de dispersión: $minutosEfectivos min\n"
          "Dosis real dispersada: ${dosisReal.toStringAsFixed(2)} kg\n"
          "Pausa: ${pausa!.inHours.toString().padLeft(2, '0')}:${(pausa!.inMinutes % 60).toString().padLeft(2, '0')}";

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calculadora de dispersión")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: dosisController,
              decoration: InputDecoration(labelText: "Dosis (kg)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => seleccionarHora(true),
              child: Text(horaInicio == null
                  ? "Seleccionar hora inicio"
                  : "Inicio: ${DateFormat("HH:mm").format(horaInicio!)}"),
            ),
            ElevatedButton(
              onPressed: () => seleccionarHora(false),
              child: Text(horaFin == null
                  ? "Seleccionar hora fin"
                  : "Fin: ${DateFormat("HH:mm").format(horaFin!)}"),
            ),
            ElevatedButton(
              onPressed: seleccionarPausa,
              child: Text(pausa == null
                  ? "Seleccionar pausa (HH:mm)"
                  : "Pausa: ${pausa!.inHours.toString().padLeft(2, '0')}:${(pausa!.inMinutes % 60).toString().padLeft(2, '0')}"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: calcular, child: Text("Calcular")),
            SizedBox(height: 20),
            Text(resultado, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
