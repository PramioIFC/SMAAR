class User {
  final int? id;
  final String name;
  final String? passwordHash; // opcional: só o Mock usa; a API real não expõe hash de senha
  final List<int> ownedGateIds;
  final DateTime? createdAt;

  const User({
    this.id,
    required this.name,
    this.passwordHash,
    this.ownedGateIds = const [],
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: (map['name'] ?? map['username']) as String,
      passwordHash: map['password_hash'] as String?,
      ownedGateIds: (map['owned_gate_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (passwordHash != null) 'password_hash': passwordHash,
      'owned_gate_ids': ownedGateIds,
      'created_at': createdAt?.toIso8601String(),
    };
  }

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

enum AuthStatus { success, invalidCredentials, userNotFound, userAlreadyExists, unknownError }

class AuthResult {
  final AuthStatus status;
  final User? user;
  final String? rawMessage; // Erro real (timeout, socket, etc.)

  const AuthResult({required this.status, this.user, this.rawMessage});

  bool get isSuccess => status == AuthStatus.success;

  String get message => rawMessage ?? switch (status) {
        AuthStatus.success            => 'Sucesso',
        AuthStatus.invalidCredentials => 'Nome ou senha incorretos',
        AuthStatus.userNotFound       => 'Usuário não encontrado',
        AuthStatus.userAlreadyExists  => 'Este nome de usuário já está em uso',
        AuthStatus.unknownError       => 'Erro inesperado. Tente novamente.',
      };
}