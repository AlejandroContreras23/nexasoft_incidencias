
import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();

  List<Incidencia> incidencias = [];
  int cantidadPendientes = 0;

  Future<void> iniciar() async {
    incidencias = await datos.leer();
    actualizarContadores();
  }

  void actualizarContadores() {
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;
  }

  List<Incidencia> buscar(String texto) {
    final consulta = texto.trim().toLowerCase();

    if (consulta.isEmpty) return incidencias;

    return incidencias.where((x) {
      return x.titulo.toLowerCase().contains(consulta) ||
          x.descripcion.toLowerCase().contains(consulta);
    }).toList();
  }

  Incidencia? porId(String id) {
    for (final x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    if (estado == 'Pendiente') return cantidadPendientes;

    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    final item = porId(id);
    if (item == null) return;

    item.estado = estado;
    actualizarContadores();

    await datos.guardar(incidencias);
  }

  Future<void> cambiarPrioridad(
    String id,
    String prioridad,
  ) async {
    const prioridadesValidas = ['Baja', 'Media', 'Alta'];

    if (!prioridadesValidas.contains(prioridad)) {
      throw ArgumentError('La prioridad seleccionada no es válida.');
    }

    final item = porId(id);
    if (item == null) return;

    item.prioridad = prioridad;

    // Persistir la lista completa con la prioridad actualizada.
    await datos.guardar(incidencias);
  }

  Future<void> crear(
    String titulo,
    String descripcion,
    String cliente,
    String categoria,
    String prioridad,
  ) async {
    const prioridadesValidas = ['Baja', 'Media', 'Alta'];

    final prioridadValida = prioridadesValidas.contains(prioridad)
        ? prioridad
        : 'Media';

    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      fecha: DateTime.now().toIso8601String().split('T').first,
      prioridad: prioridadValida,
    );

    incidencias.insert(0, nuevo);
    actualizarContadores();

    // Guardar todas las incidencias, incluida la recién creada.
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
