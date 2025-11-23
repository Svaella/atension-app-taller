import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
            Text(
              'Tendencias',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 14),
            _MiniBars(items: bp.items),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: () => _showHistoryModal(context, bp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF747474)
                      : Colors.grey[300],
                  foregroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Ver Historial Completo', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Última toma de presión',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            if (last != null)
              _LastCard(sys: last.systolic, dia: last.diastolic, cat: last.category, date: last.takenAt)
            else
              Text(
                'Sin registros',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return ElevatedButton.icon(
                    onPressed: () => _showAddModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.grey[200],
                      foregroundColor: Colors.black87,
                      elevation: isDark ? 0 : 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.add, size: 22),
                    label: const Text('Añadir Presión', style: TextStyle(fontWeight: FontWeight.w700)),
                  );
                },
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro guardado'), backgroundColor: Colors.green));
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
    int page = 1;
    int limit = 5;
    List<BPEntry> entries = [];
    bool loading = true;
    int total = 0;
    bool initialized = false;
    int? selectedIndex;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          Future<void> loadPage(int p) async {
            setDialogState(() {
              loading = true;
              selectedIndex = null;
            });
            final result = await bp.fetchPage(page: p, limit: limit);
            setDialogState(() {
              entries = result['items'] as List<BPEntry>;
              total = result['total'] as int;
              page = p;
              loading = false;
            });
          }

          Future<void> deleteSelected() async {
            if (selectedIndex == null) return;
            final entry = entries[selectedIndex!];
            final success = await bp.delete(entry.id);
            if (success) {
              // Recarga la página actual después de borrar
              await loadPage(page);
              setDialogState(() => selectedIndex = null);
            }
          }

          if (!initialized) {
            initialized = true;
            loadPage(page);
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF6B6B6B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Center(
              child: Text('Ver Historial Completo',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
            ),
            content: SizedBox(
              width: 360,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : entries.isEmpty
                      ? const Center(child: Text('Sin registros', style: TextStyle(color: Colors.white70)))
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final e = entries[i];
                            final vis = bpVisualFromCategory(e.category);
                            final dt = DateFormat("d 'de' MMMM, yyyy – HH:mm", 'es').format(e.takenAt);
                            final isSelected = selectedIndex == i;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedIndex = selectedIndex == i ? null : i;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? vis.color : Colors.grey.shade300,
                                    width: isSelected ? 3 : 2,
                                  ),
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
            actions: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: page > 1 && !loading
                            ? () => loadPage(page - 1)
                            : null,
                        child: const Text('Anterior', style: TextStyle(color: Colors.white)),
                      ),
                      Text(
                        'Página $page',
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: (page * limit < total) && !loading
                            ? () => loadPage(page + 1)
                            : null,
                        child: const Text('Siguiente', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Atrás'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onPressed: loading || selectedIndex == null
                            ? null
                            : () => deleteSelected(),
                        icon: const Icon(Icons.delete),
                        label: const Text('Borrar'),
                      ),
                    ],
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
        height: 240,
        decoration: BoxDecoration(
          color: const Color(0xFF3D4A5C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Sin datos', style: TextStyle(color: Colors.white54, fontSize: 16)),
        ),
      );
    }

    final data = [...items];
    data.sort((a, b) => a.takenAt.compareTo(b.takenAt)); // Orden ascendente (antiguas a recientes)

    final year = data.isNotEmpty ? data.last.takenAt.year : DateTime.now().year;

    // Calcula el scroll inicial para mostrar las últimas 6 alineadas a la derecha
    final itemWidth = 46.0; // ancho barra + separación
    final visibleCount = 6;
    final initialScroll = data.length > visibleCount
        ? (data.length - visibleCount) * itemWidth
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF3D4A5C),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$year',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              controller: ScrollController(
                initialScrollOffset: initialScroll,
              ),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(width: 24),
              itemBuilder: (context, i) {
                final e = data[i];
                final vis = bpVisualFromCategory(e.category);
                final normalized = (e.systolic.clamp(70, 220) - 70) / 150;
                final barHeight = (40 + (normalized * 80)).clamp(40.0, 120.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${e.systolic}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 22,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: vis.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${e.diastolic}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormat('dd-MM', 'es').format(e.takenAt),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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