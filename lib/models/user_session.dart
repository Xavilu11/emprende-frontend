class UserSession {
  final String email;
  final String nickname;
  final String telefono;
  final String rol; // 'cliente' o 'dueno'
  final bool isAuthenticated;

  const UserSession({
    this.email = '',
    this.nickname = '',
    this.telefono = '',
    this.rol = 'cliente',
    this.isAuthenticated = false,
  });

  // Se guarda en el almacenamiento local (SharedPreferences) para recordar la sesión.
  Map<String, dynamic> toJson() => {
        'email': email,
        'nickname': nickname,
        'telefono': telefono,
        'rol': rol,
      };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        email: (json['email'] ?? '').toString(),
        nickname: (json['nickname'] ?? 'Usuario').toString(),
        telefono: (json['telefono'] ?? '').toString(),
        rol: (json['rol'] ?? 'cliente').toString(),
        isAuthenticated: true,
      );
}
