class Negocio {
  final String id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String contacto;
  final String dueno;
  final double lat;
  final double lng;
  final double? distanciaKm; // solo si el usuario concedió el permiso de ubicación

  const Negocio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.contacto,
    required this.dueno,
    required this.lat,
    required this.lng,
    this.distanciaKm,
  });

  factory Negocio.fromJson(Map<String, dynamic> j) => Negocio(
        id: (j['id'] ?? '').toString(),
        nombre: (j['nombre'] ?? 'Negocio').toString(),
        descripcion: (j['descripcion'] ?? '').toString(),
        direccion: (j['direccion'] ?? 'No disponible').toString(),
        contacto: (j['contacto'] ?? 'No disponible').toString(),
        dueno: (j['dueno'] ?? 'No disponible').toString(),
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        distanciaKm: (j['distanciaKm'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'direccion': direccion,
        'contacto': contacto,
        'dueno': dueno,
        'lat': lat,
        'lng': lng,
        if (distanciaKm != null) 'distanciaKm': distanciaKm,
      };

  Negocio conDistancia(double? km) => Negocio(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        direccion: direccion,
        contacto: contacto,
        dueno: dueno,
        lat: lat,
        lng: lng,
        distanciaKm: km,
      );

  // Datos de respaldo: se usan solo si no hay backend NI datos guardados en el teléfono.
  static const List<Negocio> semilla = [
    Negocio(
      id: '1',
      nombre: 'Detalles Creativos',
      descripcion: 'Artículos personalizados y regalos',
      direccion: 'Av. Maldonado y Calle 5, Quito',
      contacto: '+593987654321',
      dueno: 'María López',
      lat: -0.22985,
      lng: -78.52495,
    ),
    Negocio(
      id: '2',
      nombre: 'Moda Urbana Andina',
      descripcion: 'Prendas estampadas y diseño textil',
      direccion: 'Calle Loja y Av. Teniente Hugo Ortiz, Quito',
      contacto: '+593912345678',
      dueno: 'Carlos Pérez',
      lat: -0.2305,
      lng: -78.5252,
    ),
    Negocio(
      id: '3',
      nombre: 'Arte en Piedra',
      descripcion: 'Decoración artesanal personalizada',
      direccion: 'Av. Napo y Calle 10, Quito',
      contacto: '+593998877665',
      dueno: 'Ana Torres',
      lat: -0.231,
      lng: -78.526,
    ),
  ];
}
