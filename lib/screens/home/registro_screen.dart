import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/bp_style.dart';
import '../../services/bp_service.dart';
import '../../models/bp_entry.dart'; // nuevo import

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BPService>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BPService>();
    final last = bp.last;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView( // <- Column -> ListView para permitir scroll y evitar overflow
          children: [
            const SizedBox(height: 8),
            Text('Tendencia', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _MiniBars(items: bp.items),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: () => _showHistoryModal(context, bp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF747474),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Ver Historial Completo', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 42),
            Text('Última toma de presión', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (last != null)
              _LastCard(sys: last.systolic, dia: last.diastolic, cat: last.category, date: last.takenAt)
            else
              const Text('Sin registros', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => _showAddModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.add, size: 22),
                label: const Text('Añadir Presión', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    final sys = ValueNotifier<int>(120);
    final dia = ValueNotifier<int>(80);

    // Solo hora y minuto (la fecha será hoy)
    final now = DateTime.now();
    final hour = ValueNotifier<int>(now.hour);
    final minute = ValueNotifier<int>(now.minute);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF6B6B6B), // gris como en mock
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.only(top: 16),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: const Center(
          child: Text(
            'MEDIDAS DE PRESIÓN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.4),
          ),
        ),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pickers sistólica/diastólica
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NumberPicker(label: 'Sistólica', value: sys, min: 70, max: 220),
                  _NumberPicker(label: 'Diastólica', value: dia, min: 40, max: 140),
                ],
              ),
              const SizedBox(height: 8),
              // Panel fecha/hora (fecha fija = hoy)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF878787),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha (solo lectura)
                    Row(
                      children: [
                        const Text('Fecha: ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        Text(
                          // Antes: DateFormat('dd de MMMM, yyyy', 'es')
                          DateFormat("d 'de' MMMM, yyyy", 'es').format(DateTime.now()),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Hora:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    //const SizedBox(height: 6),
                    // Ruedas de hora:minuto
                    _HourMinutePicker(hour: hour, minute: minute),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Atrás'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final today = DateTime.now();
                    final selected = DateTime(
                      today.year,
                      today.month,
                      today.day,
                      hour.value,
                      minute.value,
                    );
                    // selected se pasa en hora local; el servicio lo enviará en UTC
                    final ok = await context.read<BPService>().add(
                      sys: sys.value,
                      dia: dia.value,
                      takenAt: selected,
                    );
                    if (!context.mounted) return;
                    if (ok) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro guardado')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se pudo guardar'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHistoryModal(BuildContext context, BPService bp) {
    int? selectedId = bp.items.isNotEmpty ? bp.items.first.id : null;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final entries = bp.items;
          if (selectedId != null && entries.every((e) => e.id != selectedId)) {
            selectedId = entries.isEmpty ? null : entries.first.id;
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF6B6B6B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Center(
              child: Text('Ver Historial Completo',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20) ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: SizedBox(
                width: 360,
                child: entries.isEmpty
                    ? const Center(
                        child: Text('Sin registros', style: TextStyle(color: Colors.white70)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final e = entries[i];
                          final vis = bpVisualFromCategory(e.category);
                          final dt = DateFormat("d 'de' MMMM, yyyy – HH:mm", 'es').format(e.takenAt);
                          final isSelected = selectedId == e.id;
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedId = e.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? vis.color : Colors.transparent,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isSelected ? 0.25 : 0.15),
                                    blurRadius: isSelected ? 12 : 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: vis.color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vis.label.toUpperCase(),
                                            style: TextStyle(
                                              color: vis.color,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            dt,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${e.systolic}',
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        
                                        Text(
                                          '${e.diastolic}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6E6E6),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Atrás'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedId == null
                          ? null
                          : () async {
                              final ok = await context.read<BPService>().delete(selectedId!);
                              if (!dialogCtx.mounted) return;
                              if (ok) setDialogState(() {});
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD13434),
                        disabledBackgroundColor: const Color(0xFFB5B5B5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Borrar'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NumberPicker extends StatelessWidget {
  final String label;
  final ValueNotifier<int> value;
  final int min, max;
  const _NumberPicker({required this.label, required this.value, required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        SizedBox(
          width: 100,
          height: 140,
          child: ListWheelScrollView.useDelegate(
            onSelectedItemChanged: (i) => value.value = min + i,
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: max - min + 1,
              builder: (context, i) => i == null
                  ? null
                  : Center(
                      child: Text(
                        '${min + i}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LastCard extends StatelessWidget {
  final int sys, dia;
  final String cat;
  final DateTime date;
  const _LastCard({required this.sys, required this.dia, required this.cat, required this.date});

  @override
  Widget build(BuildContext context) {
    final vis = bpVisualFromCategory(cat);
    return Container(
      decoration: BoxDecoration(
        color: vis.color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('$sys',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 4),
              const Text('mmHg',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(vis.label.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6)),
                const SizedBox(height: 6),
                Text(
                  DateFormat("d 'de' MMMM, yyyy – HH:mm", 'es').format(date),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('$dia',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 4),
              const Text('mmHg',
                  style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w500, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBars extends StatelessWidget {
  final List<BPEntry> items;
  const _MiniBars({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('Sin datos', style: TextStyle(color: Colors.black45)),
        ),
      );
    }

    final data = [...items];
    data.sort((a, b) => a.takenAt.compareTo(b.takenAt));
    final display = data.take(4).toList();

    return Container(
      height: 190,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: display.map((e) {
          final vis = bpVisualFromCategory(e.category);
          final normalized = (e.systolic.clamp(90, 180) - 90) / 90;
          final barHeight = 60 + (normalized * 50);

          return SizedBox(
            width: 68,
            child: Column(
              children: [
                Text(
                  '${e.systolic}',
                  style: TextStyle(color: vis.color, fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 22,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: vis.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${e.diastolic}',
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  DateFormat('dd-MM', 'es').format(e.takenAt),
                  style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HourMinutePicker extends StatelessWidget {
  final ValueNotifier<int> hour;
  final ValueNotifier<int> minute;
  const _HourMinutePicker({required this.hour, required this.minute});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Wheel(
            initial: hour.value,
            min: 0,
            max: 23,
            onChanged: (v) => hour.value = v,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
          ),
          _Wheel(
            initial: (minute.value ~/ 1),
            min: 0,
            max: 59,
            onChanged: (v) => minute.value = v,
          ),
        ],
      ),
    );
  }
}

class _Wheel extends StatefulWidget {
  final int initial;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _Wheel({required this.initial, required this.min, required this.max, required this.onChanged});

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late FixedExtentScrollController _c;
  @override
  void initState() {
    super.initState();
    _c = FixedExtentScrollController(initialItem: (widget.initial - widget.min).clamp(0, widget.max - widget.min));
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.max - widget.min + 1;
    return SizedBox(
      width: 56,
      child: ListWheelScrollView.useDelegate(
        controller: _c,
        onSelectedItemChanged: (i) => widget.onChanged(widget.min + i),
        itemExtent: 36,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (_, i) {
            final v = widget.min + i;
            return Center(
              child: Text(
                v.toString().padLeft(2, '0'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            );
          },
        ),
      ),
    );
  }
}