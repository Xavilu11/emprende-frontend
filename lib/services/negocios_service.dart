import 'package:geolocator/geolocator.dart';
import '../models/negocio.dart';
import 'api_service.dart';
import 'local_storage.dart';

class ResultadoNegocios {
  final List<Negocio> negocios;
  final bool desdeCache; // true = no se pudo contactar al backend
  const ResultadoNegocios(this.negocios, {this.desdeCache = false});
}

/// Backend primero, almacenamiento local como respaldo.
class NegociosService {
  static Future<ResultadoNegocios> cargar({double? lat, double? lng}) async {
    try {
      // 1) BACKEND: GET /businesses (con lat/lng solo si hay permiso de ubicación)
      final lista = await ApiService.getBusinesses(lat: lat, lng: lng);
      final negocios = lista
          .map((e) => Negocio.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      // 2) LOCAL: guardamos copia para uso sin conexión
      await LocalStorage.guardarNegocios(negocios);
      return ResultadoNegocios(negocios);
    } catch (_) {
      // Sin backend: usamos lo guardado (o los datos de respaldo) y calculamos distancias en el teléfono
      var negocios = await LocalStorage.leerNegocios();
      if (negocios.isEmpty) negocios = Negocio.semilla;
      return ResultadoNegocios(_conDistancias(negocios, lat, lng), desdeCache: true);
    }
  }

  static List<Negocio> _conDistancias(
      List<Negocio> negocios, double? lat, double? lng) {
    if (lat == null || lng == null) return negocios;
    final lista = negocios
        .map((n) => n.conDistancia(
            Geolocator.distanceBetween(lat, lng, n.lat, n.lng) / 1000))
        .toList();
    lista.sort((a, b) => a.distanciaKm!.compareTo(b.distanciaKm!));
    return lista;
  }
}
