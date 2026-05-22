/// Modelo de Usuário
/// Preparado para integração com PostgreSQL
class User {
  final int? id;
  final String name;
  final String passwordHash; // armazenar hash, nunca senha em texto puro

  /// IDs das porteiras que pertencem a este usuário.
  /// Admin (id=1) começa com [1, 2, 3]; novos usuários começam com [].
  final List<int> ownedGateIds;

  final DateTime? createdAt;

  const User({
    this.id,
    required this.name,
    required this.passwordHash,
    this.ownedGateIds = const [],
    this.createdAt,
  });

  /// Cria uma instância a partir de um Map (para PostgreSQL/JSON)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      passwordHash: map['password_hash'] as String,
      ownedGateIds: (map['owned_gate_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// Converte para Map (para inserção no PostgreSQL)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'password_hash': passwordHash,
      'owned_gate_ids': ownedGateIds,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Cria uma cópia com valores alterados
  User copyWith({
    int? id,
    String? name,
    String? passwordHash,
    List<int>? ownedGateIds,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      passwordHash: passwordHash ?? this.passwordHash,
      ownedGateIds: ownedGateIds ?? this.ownedGateIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name)';
}

/// Resultado de uma tentativa de autenticação
enum AuthStatus {
  success,
  invalidCredentials,
  userNotFound,
  userAlreadyExists,
  unknownError,
}

class AuthResult {
  final AuthStatus status;
  final User? user;

  const AuthResult({required this.status, this.user});

  bool get isSuccess => status == AuthStatus.success;

  /// Mensagem amigável para exibir ao usuário
  String get message => switch (status) {
        AuthStatus.success            => 'Sucesso',
        AuthStatus.invalidCredentials => 'Nome ou senha incorretos',
        AuthStatus.userNotFound       => 'Usuário não encontrado',
        AuthStatus.userAlreadyExists  => 'Este nome de usuário já está em uso',
        AuthStatus.unknownError       => 'Erro inesperado. Tente novamente.',
      };
}
