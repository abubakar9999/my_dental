// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dentist'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    phone,
    password,
    name,
    role,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String? email;
  final String? phone;
  final String password;
  final String name;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  const User({
    required this.id,
    this.email,
    this.phone,
    required this.password,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['password'] = Variable<String>(password);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      password: Value(password),
      name: Value(name),
      role: Value(role),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      password: serializer.fromJson<String>(json['password']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'password': serializer.toJson<String>(password),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith({
    int? id,
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? password,
    String? name,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    password: password ?? this.password,
    name: name ?? this.name,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      password: data.password.present ? data.password.value : this.password,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('password: $password, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, email, phone, password, name, role, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.password == this.password &&
          other.name == this.name &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String> password;
  final Value<String> name;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.password = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    required String password,
    required String name,
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : password = Value(password),
       name = Value(name);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? password,
    Expression<String>? name,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (password != null) 'password': password,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String>? password,
    Value<String>? name,
    Value<String>? role,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('password: $password, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medicalHistoryMeta = const VerificationMeta(
    'medicalHistory',
  );
  @override
  late final GeneratedColumn<String> medicalHistory = GeneratedColumn<String>(
    'medical_history',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allergiesMeta = const VerificationMeta(
    'allergies',
  );
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
    'allergies',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    age,
    gender,
    address,
    medicalHistory,
    allergies,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Patient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('medical_history')) {
      context.handle(
        _medicalHistoryMeta,
        medicalHistory.isAcceptableOrUnknown(
          data['medical_history']!,
          _medicalHistoryMeta,
        ),
      );
    }
    if (data.containsKey('allergies')) {
      context.handle(
        _allergiesMeta,
        allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      medicalHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medical_history'],
      ),
      allergies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergies'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
  final int id;
  final String name;
  final String phone;
  final int? age;
  final String? gender;
  final String? address;
  final String? medicalHistory;
  final String? allergies;
  final DateTime createdAt;
  const Patient({
    required this.id,
    required this.name,
    required this.phone,
    this.age,
    this.gender,
    this.address,
    this.medicalHistory,
    this.allergies,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || medicalHistory != null) {
      map['medical_history'] = Variable<String>(medicalHistory);
    }
    if (!nullToAbsent || allergies != null) {
      map['allergies'] = Variable<String>(allergies);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      medicalHistory: medicalHistory == null && nullToAbsent
          ? const Value.absent()
          : Value(medicalHistory),
      allergies: allergies == null && nullToAbsent
          ? const Value.absent()
          : Value(allergies),
      createdAt: Value(createdAt),
    );
  }

  factory Patient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      age: serializer.fromJson<int?>(json['age']),
      gender: serializer.fromJson<String?>(json['gender']),
      address: serializer.fromJson<String?>(json['address']),
      medicalHistory: serializer.fromJson<String?>(json['medicalHistory']),
      allergies: serializer.fromJson<String?>(json['allergies']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'age': serializer.toJson<int?>(age),
      'gender': serializer.toJson<String?>(gender),
      'address': serializer.toJson<String?>(address),
      'medicalHistory': serializer.toJson<String?>(medicalHistory),
      'allergies': serializer.toJson<String?>(allergies),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Patient copyWith({
    int? id,
    String? name,
    String? phone,
    Value<int?> age = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> medicalHistory = const Value.absent(),
    Value<String?> allergies = const Value.absent(),
    DateTime? createdAt,
  }) => Patient(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    age: age.present ? age.value : this.age,
    gender: gender.present ? gender.value : this.gender,
    address: address.present ? address.value : this.address,
    medicalHistory: medicalHistory.present
        ? medicalHistory.value
        : this.medicalHistory,
    allergies: allergies.present ? allergies.value : this.allergies,
    createdAt: createdAt ?? this.createdAt,
  );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      age: data.age.present ? data.age.value : this.age,
      gender: data.gender.present ? data.gender.value : this.gender,
      address: data.address.present ? data.address.value : this.address,
      medicalHistory: data.medicalHistory.present
          ? data.medicalHistory.value
          : this.medicalHistory,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('address: $address, ')
          ..write('medicalHistory: $medicalHistory, ')
          ..write('allergies: $allergies, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    age,
    gender,
    address,
    medicalHistory,
    allergies,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.age == this.age &&
          other.gender == this.gender &&
          other.address == this.address &&
          other.medicalHistory == this.medicalHistory &&
          other.allergies == this.allergies &&
          other.createdAt == this.createdAt);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<int?> age;
  final Value<String?> gender;
  final Value<String?> address;
  final Value<String?> medicalHistory;
  final Value<String?> allergies;
  final Value<DateTime> createdAt;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.address = const Value.absent(),
    this.medicalHistory = const Value.absent(),
    this.allergies = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PatientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String phone,
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.address = const Value.absent(),
    this.medicalHistory = const Value.absent(),
    this.allergies = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       phone = Value(phone);
  static Insertable<Patient> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<int>? age,
    Expression<String>? gender,
    Expression<String>? address,
    Expression<String>? medicalHistory,
    Expression<String>? allergies,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
      if (medicalHistory != null) 'medical_history': medicalHistory,
      if (allergies != null) 'allergies': allergies,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PatientsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<int?>? age,
    Value<String?>? gender,
    Value<String?>? address,
    Value<String?>? medicalHistory,
    Value<String?>? allergies,
    Value<DateTime>? createdAt,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (medicalHistory.present) {
      map['medical_history'] = Variable<String>(medicalHistory.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('address: $address, ')
          ..write('medicalHistory: $medicalHistory, ')
          ..write('allergies: $allergies, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, Appointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<int> patientId = GeneratedColumn<int>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _appointmentDateMeta = const VerificationMeta(
    'appointmentDate',
  );
  @override
  late final GeneratedColumn<DateTime> appointmentDate =
      GeneratedColumn<DateTime>(
        'appointment_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('waiting'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    appointmentDate,
    status,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Appointment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('appointment_date')) {
      context.handle(
        _appointmentDateMeta,
        appointmentDate.isAcceptableOrUnknown(
          data['appointment_date']!,
          _appointmentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appointmentDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}patient_id'],
      )!,
      appointmentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}appointment_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class Appointment extends DataClass implements Insertable<Appointment> {
  final int id;
  final int patientId;
  final DateTime appointmentDate;
  final String status;
  final String? note;
  final DateTime createdAt;
  const Appointment({
    required this.id,
    required this.patientId,
    required this.appointmentDate,
    required this.status,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['patient_id'] = Variable<int>(patientId);
    map['appointment_date'] = Variable<DateTime>(appointmentDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      appointmentDate: Value(appointmentDate),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Appointment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<int>(json['id']),
      patientId: serializer.fromJson<int>(json['patientId']),
      appointmentDate: serializer.fromJson<DateTime>(json['appointmentDate']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patientId': serializer.toJson<int>(patientId),
      'appointmentDate': serializer.toJson<DateTime>(appointmentDate),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Appointment copyWith({
    int? id,
    int? patientId,
    DateTime? appointmentDate,
    String? status,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => Appointment(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    appointmentDate: appointmentDate ?? this.appointmentDate,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      appointmentDate: data.appointmentDate.present
          ? data.appointmentDate.value
          : this.appointmentDate,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('appointmentDate: $appointmentDate, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, patientId, appointmentDate, status, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.appointmentDate == this.appointmentDate &&
          other.status == this.status &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<int> id;
  final Value<int> patientId;
  final Value<DateTime> appointmentDate;
  final Value<String> status;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.appointmentDate = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    this.id = const Value.absent(),
    required int patientId,
    required DateTime appointmentDate,
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : patientId = Value(patientId),
       appointmentDate = Value(appointmentDate);
  static Insertable<Appointment> custom({
    Expression<int>? id,
    Expression<int>? patientId,
    Expression<DateTime>? appointmentDate,
    Expression<String>? status,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (appointmentDate != null) 'appointment_date': appointmentDate,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AppointmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? patientId,
    Value<DateTime>? appointmentDate,
    Value<String>? status,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<int>(patientId.value);
    }
    if (appointmentDate.present) {
      map['appointment_date'] = Variable<DateTime>(appointmentDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('appointmentDate: $appointmentDate, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TreatmentsTable extends Treatments
    with TableInfo<$TreatmentsTable, Treatment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreatmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<int> patientId = GeneratedColumn<int>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _toothNumberMeta = const VerificationMeta(
    'toothNumber',
  );
  @override
  late final GeneratedColumn<String> toothNumber = GeneratedColumn<String>(
    'tooth_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _procedureMeta = const VerificationMeta(
    'procedure',
  );
  @override
  late final GeneratedColumn<String> procedure = GeneratedColumn<String>(
    'procedure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    toothNumber,
    procedure,
    cost,
    date,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treatments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Treatment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('tooth_number')) {
      context.handle(
        _toothNumberMeta,
        toothNumber.isAcceptableOrUnknown(
          data['tooth_number']!,
          _toothNumberMeta,
        ),
      );
    }
    if (data.containsKey('procedure')) {
      context.handle(
        _procedureMeta,
        procedure.isAcceptableOrUnknown(data['procedure']!, _procedureMeta),
      );
    } else if (isInserting) {
      context.missing(_procedureMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Treatment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Treatment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}patient_id'],
      )!,
      toothNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tooth_number'],
      ),
      procedure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}procedure'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TreatmentsTable createAlias(String alias) {
    return $TreatmentsTable(attachedDatabase, alias);
  }
}

class Treatment extends DataClass implements Insertable<Treatment> {
  final int id;
  final int patientId;
  final String? toothNumber;
  final String procedure;
  final double cost;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  const Treatment({
    required this.id,
    required this.patientId,
    this.toothNumber,
    required this.procedure,
    required this.cost,
    required this.date,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['patient_id'] = Variable<int>(patientId);
    if (!nullToAbsent || toothNumber != null) {
      map['tooth_number'] = Variable<String>(toothNumber);
    }
    map['procedure'] = Variable<String>(procedure);
    map['cost'] = Variable<double>(cost);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TreatmentsCompanion toCompanion(bool nullToAbsent) {
    return TreatmentsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      toothNumber: toothNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(toothNumber),
      procedure: Value(procedure),
      cost: Value(cost),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Treatment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Treatment(
      id: serializer.fromJson<int>(json['id']),
      patientId: serializer.fromJson<int>(json['patientId']),
      toothNumber: serializer.fromJson<String?>(json['toothNumber']),
      procedure: serializer.fromJson<String>(json['procedure']),
      cost: serializer.fromJson<double>(json['cost']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patientId': serializer.toJson<int>(patientId),
      'toothNumber': serializer.toJson<String?>(toothNumber),
      'procedure': serializer.toJson<String>(procedure),
      'cost': serializer.toJson<double>(cost),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Treatment copyWith({
    int? id,
    int? patientId,
    Value<String?> toothNumber = const Value.absent(),
    String? procedure,
    double? cost,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Treatment(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    toothNumber: toothNumber.present ? toothNumber.value : this.toothNumber,
    procedure: procedure ?? this.procedure,
    cost: cost ?? this.cost,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Treatment copyWithCompanion(TreatmentsCompanion data) {
    return Treatment(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      toothNumber: data.toothNumber.present
          ? data.toothNumber.value
          : this.toothNumber,
      procedure: data.procedure.present ? data.procedure.value : this.procedure,
      cost: data.cost.present ? data.cost.value : this.cost,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Treatment(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('toothNumber: $toothNumber, ')
          ..write('procedure: $procedure, ')
          ..write('cost: $cost, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    toothNumber,
    procedure,
    cost,
    date,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Treatment &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.toothNumber == this.toothNumber &&
          other.procedure == this.procedure &&
          other.cost == this.cost &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class TreatmentsCompanion extends UpdateCompanion<Treatment> {
  final Value<int> id;
  final Value<int> patientId;
  final Value<String?> toothNumber;
  final Value<String> procedure;
  final Value<double> cost;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const TreatmentsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.toothNumber = const Value.absent(),
    this.procedure = const Value.absent(),
    this.cost = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TreatmentsCompanion.insert({
    this.id = const Value.absent(),
    required int patientId,
    this.toothNumber = const Value.absent(),
    required String procedure,
    this.cost = const Value.absent(),
    required DateTime date,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : patientId = Value(patientId),
       procedure = Value(procedure),
       date = Value(date);
  static Insertable<Treatment> custom({
    Expression<int>? id,
    Expression<int>? patientId,
    Expression<String>? toothNumber,
    Expression<String>? procedure,
    Expression<double>? cost,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (toothNumber != null) 'tooth_number': toothNumber,
      if (procedure != null) 'procedure': procedure,
      if (cost != null) 'cost': cost,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TreatmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? patientId,
    Value<String?>? toothNumber,
    Value<String>? procedure,
    Value<double>? cost,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return TreatmentsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      toothNumber: toothNumber ?? this.toothNumber,
      procedure: procedure ?? this.procedure,
      cost: cost ?? this.cost,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<int>(patientId.value);
    }
    if (toothNumber.present) {
      map['tooth_number'] = Variable<String>(toothNumber.value);
    }
    if (procedure.present) {
      map['procedure'] = Variable<String>(procedure.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreatmentsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('toothNumber: $toothNumber, ')
          ..write('procedure: $procedure, ')
          ..write('cost: $cost, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<int> patientId = GeneratedColumn<int>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _treatmentIdMeta = const VerificationMeta(
    'treatmentId',
  );
  @override
  late final GeneratedColumn<int> treatmentId = GeneratedColumn<int>(
    'treatment_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES treatments (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    treatmentId,
    amount,
    date,
    method,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('treatment_id')) {
      context.handle(
        _treatmentIdMeta,
        treatmentId.isAcceptableOrUnknown(
          data['treatment_id']!,
          _treatmentIdMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}patient_id'],
      )!,
      treatmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}treatment_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int patientId;
  final int? treatmentId;
  final double amount;
  final DateTime date;
  final String method;
  final DateTime createdAt;
  const Payment({
    required this.id,
    required this.patientId,
    this.treatmentId,
    required this.amount,
    required this.date,
    required this.method,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['patient_id'] = Variable<int>(patientId);
    if (!nullToAbsent || treatmentId != null) {
      map['treatment_id'] = Variable<int>(treatmentId);
    }
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['method'] = Variable<String>(method);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      treatmentId: treatmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(treatmentId),
      amount: Value(amount),
      date: Value(date),
      method: Value(method),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      patientId: serializer.fromJson<int>(json['patientId']),
      treatmentId: serializer.fromJson<int?>(json['treatmentId']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      method: serializer.fromJson<String>(json['method']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patientId': serializer.toJson<int>(patientId),
      'treatmentId': serializer.toJson<int?>(treatmentId),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'method': serializer.toJson<String>(method),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith({
    int? id,
    int? patientId,
    Value<int?> treatmentId = const Value.absent(),
    double? amount,
    DateTime? date,
    String? method,
    DateTime? createdAt,
  }) => Payment(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    treatmentId: treatmentId.present ? treatmentId.value : this.treatmentId,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    method: method ?? this.method,
    createdAt: createdAt ?? this.createdAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      treatmentId: data.treatmentId.present
          ? data.treatmentId.value
          : this.treatmentId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      method: data.method.present ? data.method.value : this.method,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('treatmentId: $treatmentId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('method: $method, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, patientId, treatmentId, amount, date, method, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.treatmentId == this.treatmentId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.method == this.method &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> patientId;
  final Value<int?> treatmentId;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> method;
  final Value<DateTime> createdAt;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.treatmentId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.method = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int patientId,
    this.treatmentId = const Value.absent(),
    required double amount,
    required DateTime date,
    required String method,
    this.createdAt = const Value.absent(),
  }) : patientId = Value(patientId),
       amount = Value(amount),
       date = Value(date),
       method = Value(method);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? patientId,
    Expression<int>? treatmentId,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? method,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (treatmentId != null) 'treatment_id': treatmentId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (method != null) 'method': method,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? patientId,
    Value<int?>? treatmentId,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String>? method,
    Value<DateTime>? createdAt,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      treatmentId: treatmentId ?? this.treatmentId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<int>(patientId.value);
    }
    if (treatmentId.present) {
      map['treatment_id'] = Variable<int>(treatmentId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('treatmentId: $treatmentId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('method: $method, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PrescriptionsTable extends Prescriptions
    with TableInfo<$PrescriptionsTable, Prescription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrescriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<int> patientId = GeneratedColumn<int>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicinesMeta = const VerificationMeta(
    'medicines',
  );
  @override
  late final GeneratedColumn<String> medicines = GeneratedColumn<String>(
    'medicines',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adviceMeta = const VerificationMeta('advice');
  @override
  late final GeneratedColumn<String> advice = GeneratedColumn<String>(
    'advice',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    date,
    medicines,
    advice,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prescriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prescription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('medicines')) {
      context.handle(
        _medicinesMeta,
        medicines.isAcceptableOrUnknown(data['medicines']!, _medicinesMeta),
      );
    } else if (isInserting) {
      context.missing(_medicinesMeta);
    }
    if (data.containsKey('advice')) {
      context.handle(
        _adviceMeta,
        advice.isAcceptableOrUnknown(data['advice']!, _adviceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Prescription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prescription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}patient_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      medicines: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicines'],
      )!,
      advice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}advice'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PrescriptionsTable createAlias(String alias) {
    return $PrescriptionsTable(attachedDatabase, alias);
  }
}

class Prescription extends DataClass implements Insertable<Prescription> {
  final int id;
  final int patientId;
  final DateTime date;
  final String medicines;
  final String? advice;
  final DateTime createdAt;
  const Prescription({
    required this.id,
    required this.patientId,
    required this.date,
    required this.medicines,
    this.advice,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['patient_id'] = Variable<int>(patientId);
    map['date'] = Variable<DateTime>(date);
    map['medicines'] = Variable<String>(medicines);
    if (!nullToAbsent || advice != null) {
      map['advice'] = Variable<String>(advice);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PrescriptionsCompanion toCompanion(bool nullToAbsent) {
    return PrescriptionsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      date: Value(date),
      medicines: Value(medicines),
      advice: advice == null && nullToAbsent
          ? const Value.absent()
          : Value(advice),
      createdAt: Value(createdAt),
    );
  }

  factory Prescription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prescription(
      id: serializer.fromJson<int>(json['id']),
      patientId: serializer.fromJson<int>(json['patientId']),
      date: serializer.fromJson<DateTime>(json['date']),
      medicines: serializer.fromJson<String>(json['medicines']),
      advice: serializer.fromJson<String?>(json['advice']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patientId': serializer.toJson<int>(patientId),
      'date': serializer.toJson<DateTime>(date),
      'medicines': serializer.toJson<String>(medicines),
      'advice': serializer.toJson<String?>(advice),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Prescription copyWith({
    int? id,
    int? patientId,
    DateTime? date,
    String? medicines,
    Value<String?> advice = const Value.absent(),
    DateTime? createdAt,
  }) => Prescription(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    date: date ?? this.date,
    medicines: medicines ?? this.medicines,
    advice: advice.present ? advice.value : this.advice,
    createdAt: createdAt ?? this.createdAt,
  );
  Prescription copyWithCompanion(PrescriptionsCompanion data) {
    return Prescription(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      date: data.date.present ? data.date.value : this.date,
      medicines: data.medicines.present ? data.medicines.value : this.medicines,
      advice: data.advice.present ? data.advice.value : this.advice,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prescription(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('date: $date, ')
          ..write('medicines: $medicines, ')
          ..write('advice: $advice, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, patientId, date, medicines, advice, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prescription &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.date == this.date &&
          other.medicines == this.medicines &&
          other.advice == this.advice &&
          other.createdAt == this.createdAt);
}

class PrescriptionsCompanion extends UpdateCompanion<Prescription> {
  final Value<int> id;
  final Value<int> patientId;
  final Value<DateTime> date;
  final Value<String> medicines;
  final Value<String?> advice;
  final Value<DateTime> createdAt;
  const PrescriptionsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.date = const Value.absent(),
    this.medicines = const Value.absent(),
    this.advice = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PrescriptionsCompanion.insert({
    this.id = const Value.absent(),
    required int patientId,
    required DateTime date,
    required String medicines,
    this.advice = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : patientId = Value(patientId),
       date = Value(date),
       medicines = Value(medicines);
  static Insertable<Prescription> custom({
    Expression<int>? id,
    Expression<int>? patientId,
    Expression<DateTime>? date,
    Expression<String>? medicines,
    Expression<String>? advice,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (date != null) 'date': date,
      if (medicines != null) 'medicines': medicines,
      if (advice != null) 'advice': advice,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PrescriptionsCompanion copyWith({
    Value<int>? id,
    Value<int>? patientId,
    Value<DateTime>? date,
    Value<String>? medicines,
    Value<String?>? advice,
    Value<DateTime>? createdAt,
  }) {
    return PrescriptionsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      medicines: medicines ?? this.medicines,
      advice: advice ?? this.advice,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<int>(patientId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (medicines.present) {
      map['medicines'] = Variable<String>(medicines.value);
    }
    if (advice.present) {
      map['advice'] = Variable<String>(advice.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrescriptionsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('date: $date, ')
          ..write('medicines: $medicines, ')
          ..write('advice: $advice, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProcedurePricesTable extends ProcedurePrices
    with TableInfo<$ProcedurePricesTable, ProcedurePrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcedurePricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultPriceMeta = const VerificationMeta(
    'defaultPrice',
  );
  @override
  late final GeneratedColumn<double> defaultPrice = GeneratedColumn<double>(
    'default_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, defaultPrice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'procedure_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProcedurePrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_price')) {
      context.handle(
        _defaultPriceMeta,
        defaultPrice.isAcceptableOrUnknown(
          data['default_price']!,
          _defaultPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultPriceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcedurePrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcedurePrice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      defaultPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_price'],
      )!,
    );
  }

  @override
  $ProcedurePricesTable createAlias(String alias) {
    return $ProcedurePricesTable(attachedDatabase, alias);
  }
}

class ProcedurePrice extends DataClass implements Insertable<ProcedurePrice> {
  final int id;
  final String name;
  final double defaultPrice;
  const ProcedurePrice({
    required this.id,
    required this.name,
    required this.defaultPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['default_price'] = Variable<double>(defaultPrice);
    return map;
  }

  ProcedurePricesCompanion toCompanion(bool nullToAbsent) {
    return ProcedurePricesCompanion(
      id: Value(id),
      name: Value(name),
      defaultPrice: Value(defaultPrice),
    );
  }

  factory ProcedurePrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcedurePrice(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      defaultPrice: serializer.fromJson<double>(json['defaultPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'defaultPrice': serializer.toJson<double>(defaultPrice),
    };
  }

  ProcedurePrice copyWith({int? id, String? name, double? defaultPrice}) =>
      ProcedurePrice(
        id: id ?? this.id,
        name: name ?? this.name,
        defaultPrice: defaultPrice ?? this.defaultPrice,
      );
  ProcedurePrice copyWithCompanion(ProcedurePricesCompanion data) {
    return ProcedurePrice(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      defaultPrice: data.defaultPrice.present
          ? data.defaultPrice.value
          : this.defaultPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcedurePrice(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultPrice: $defaultPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, defaultPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcedurePrice &&
          other.id == this.id &&
          other.name == this.name &&
          other.defaultPrice == this.defaultPrice);
}

class ProcedurePricesCompanion extends UpdateCompanion<ProcedurePrice> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> defaultPrice;
  const ProcedurePricesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultPrice = const Value.absent(),
  });
  ProcedurePricesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double defaultPrice,
  }) : name = Value(name),
       defaultPrice = Value(defaultPrice);
  static Insertable<ProcedurePrice> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? defaultPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (defaultPrice != null) 'default_price': defaultPrice,
    });
  }

  ProcedurePricesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? defaultPrice,
  }) {
    return ProcedurePricesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultPrice: defaultPrice ?? this.defaultPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultPrice.present) {
      map['default_price'] = Variable<double>(defaultPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProcedurePricesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultPrice: $defaultPrice')
          ..write(')'))
        .toString();
  }
}

class $ToothConditionsTable extends ToothConditions
    with TableInfo<$ToothConditionsTable, ToothCondition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ToothConditionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<int> patientId = GeneratedColumn<int>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _toothNumberMeta = const VerificationMeta(
    'toothNumber',
  );
  @override
  late final GeneratedColumn<String> toothNumber = GeneratedColumn<String>(
    'tooth_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('healthy'),
  );
  static const VerificationMeta _surfacesMeta = const VerificationMeta(
    'surfaces',
  );
  @override
  late final GeneratedColumn<String> surfaces = GeneratedColumn<String>(
    'surfaces',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    toothNumber,
    condition,
    surfaces,
    notes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tooth_conditions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ToothCondition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('tooth_number')) {
      context.handle(
        _toothNumberMeta,
        toothNumber.isAcceptableOrUnknown(
          data['tooth_number']!,
          _toothNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toothNumberMeta);
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    }
    if (data.containsKey('surfaces')) {
      context.handle(
        _surfacesMeta,
        surfaces.isAcceptableOrUnknown(data['surfaces']!, _surfacesMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ToothCondition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ToothCondition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}patient_id'],
      )!,
      toothNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tooth_number'],
      )!,
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      )!,
      surfaces: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surfaces'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ToothConditionsTable createAlias(String alias) {
    return $ToothConditionsTable(attachedDatabase, alias);
  }
}

class ToothCondition extends DataClass implements Insertable<ToothCondition> {
  final int id;
  final int patientId;
  final String toothNumber;
  final String condition;
  final String? surfaces;
  final String? notes;
  final DateTime updatedAt;
  const ToothCondition({
    required this.id,
    required this.patientId,
    required this.toothNumber,
    required this.condition,
    this.surfaces,
    this.notes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['patient_id'] = Variable<int>(patientId);
    map['tooth_number'] = Variable<String>(toothNumber);
    map['condition'] = Variable<String>(condition);
    if (!nullToAbsent || surfaces != null) {
      map['surfaces'] = Variable<String>(surfaces);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ToothConditionsCompanion toCompanion(bool nullToAbsent) {
    return ToothConditionsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      toothNumber: Value(toothNumber),
      condition: Value(condition),
      surfaces: surfaces == null && nullToAbsent
          ? const Value.absent()
          : Value(surfaces),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
    );
  }

  factory ToothCondition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ToothCondition(
      id: serializer.fromJson<int>(json['id']),
      patientId: serializer.fromJson<int>(json['patientId']),
      toothNumber: serializer.fromJson<String>(json['toothNumber']),
      condition: serializer.fromJson<String>(json['condition']),
      surfaces: serializer.fromJson<String?>(json['surfaces']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'patientId': serializer.toJson<int>(patientId),
      'toothNumber': serializer.toJson<String>(toothNumber),
      'condition': serializer.toJson<String>(condition),
      'surfaces': serializer.toJson<String?>(surfaces),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ToothCondition copyWith({
    int? id,
    int? patientId,
    String? toothNumber,
    String? condition,
    Value<String?> surfaces = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? updatedAt,
  }) => ToothCondition(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    toothNumber: toothNumber ?? this.toothNumber,
    condition: condition ?? this.condition,
    surfaces: surfaces.present ? surfaces.value : this.surfaces,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ToothCondition copyWithCompanion(ToothConditionsCompanion data) {
    return ToothCondition(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      toothNumber: data.toothNumber.present
          ? data.toothNumber.value
          : this.toothNumber,
      condition: data.condition.present ? data.condition.value : this.condition,
      surfaces: data.surfaces.present ? data.surfaces.value : this.surfaces,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ToothCondition(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('toothNumber: $toothNumber, ')
          ..write('condition: $condition, ')
          ..write('surfaces: $surfaces, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    toothNumber,
    condition,
    surfaces,
    notes,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ToothCondition &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.toothNumber == this.toothNumber &&
          other.condition == this.condition &&
          other.surfaces == this.surfaces &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt);
}

class ToothConditionsCompanion extends UpdateCompanion<ToothCondition> {
  final Value<int> id;
  final Value<int> patientId;
  final Value<String> toothNumber;
  final Value<String> condition;
  final Value<String?> surfaces;
  final Value<String?> notes;
  final Value<DateTime> updatedAt;
  const ToothConditionsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.toothNumber = const Value.absent(),
    this.condition = const Value.absent(),
    this.surfaces = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ToothConditionsCompanion.insert({
    this.id = const Value.absent(),
    required int patientId,
    required String toothNumber,
    this.condition = const Value.absent(),
    this.surfaces = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : patientId = Value(patientId),
       toothNumber = Value(toothNumber);
  static Insertable<ToothCondition> custom({
    Expression<int>? id,
    Expression<int>? patientId,
    Expression<String>? toothNumber,
    Expression<String>? condition,
    Expression<String>? surfaces,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (toothNumber != null) 'tooth_number': toothNumber,
      if (condition != null) 'condition': condition,
      if (surfaces != null) 'surfaces': surfaces,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ToothConditionsCompanion copyWith({
    Value<int>? id,
    Value<int>? patientId,
    Value<String>? toothNumber,
    Value<String>? condition,
    Value<String?>? surfaces,
    Value<String?>? notes,
    Value<DateTime>? updatedAt,
  }) {
    return ToothConditionsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      toothNumber: toothNumber ?? this.toothNumber,
      condition: condition ?? this.condition,
      surfaces: surfaces ?? this.surfaces,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<int>(patientId.value);
    }
    if (toothNumber.present) {
      map['tooth_number'] = Variable<String>(toothNumber.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (surfaces.present) {
      map['surfaces'] = Variable<String>(surfaces.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ToothConditionsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('toothNumber: $toothNumber, ')
          ..write('condition: $condition, ')
          ..write('surfaces: $surfaces, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $TreatmentsTable treatments = $TreatmentsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PrescriptionsTable prescriptions = $PrescriptionsTable(this);
  late final $ProcedurePricesTable procedurePrices = $ProcedurePricesTable(
    this,
  );
  late final $ToothConditionsTable toothConditions = $ToothConditionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    patients,
    appointments,
    treatments,
    payments,
    prescriptions,
    procedurePrices,
    toothConditions,
  ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String?> email,
  Value<String?> phone,
  required String password,
  required String name,
  Value<String> role,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String?> email,
  Value<String?> phone,
  Value<String> password,
  Value<String> name,
  Value<String> role,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                phone: phone,
                password: password,
                name: name,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required String password,
                required String name,
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                phone: phone,
                password: password,
                name: name,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, User>(table),
                  BaseReferences<_$AppDatabase, $UsersTable, User>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$PatientsTableCreateCompanionBuilder = PatientsCompanion Function({
  Value<int> id,
  required String name,
  required String phone,
  Value<int?> age,
  Value<String?> gender,
  Value<String?> address,
  Value<String?> medicalHistory,
  Value<String?> allergies,
  Value<DateTime> createdAt,
});
typedef $$PatientsTableUpdateCompanionBuilder = PatientsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> phone,
  Value<int?> age,
  Value<String?> gender,
  Value<String?> address,
  Value<String?> medicalHistory,
  Value<String?> allergies,
  Value<DateTime> createdAt,
});

final class $$PatientsTableReferences
    extends BaseReferences<_$AppDatabase, $PatientsTable, Patient> {
  $$PatientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AppointmentsTable, List<Appointment>>
  _appointmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.appointments,
    aliasName: 'patients__id__appointments__patient_id',
  );

  $$AppointmentsTableProcessedTableManager get appointmentsRefs {
    final manager = $$AppointmentsTableTableManager(
      $_db,
      $_db.appointments,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appointmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TreatmentsTable, List<Treatment>>
  _treatmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.treatments,
    aliasName: 'patients__id__treatments__patient_id',
  );

  $$TreatmentsTableProcessedTableManager get treatmentsRefs {
    final manager = $$TreatmentsTableTableManager(
      $_db,
      $_db.treatments,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_treatmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'patients__id__payments__patient_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrescriptionsTable, List<Prescription>>
  _prescriptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prescriptions,
    aliasName: 'patients__id__prescriptions__patient_id',
  );

  $$PrescriptionsTableProcessedTableManager get prescriptionsRefs {
    final manager = $$PrescriptionsTableTableManager(
      $_db,
      $_db.prescriptions,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_prescriptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ToothConditionsTable, List<ToothCondition>>
  _toothConditionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.toothConditions,
    aliasName: 'patients__id__tooth_conditions__patient_id',
  );

  $$ToothConditionsTableProcessedTableManager get toothConditionsRefs {
    final manager = $$ToothConditionsTableTableManager(
      $_db,
      $_db.toothConditions,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _toothConditionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicalHistory => $composableBuilder(
    column: $table.medicalHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> appointmentsRefs(
    Expression<bool> Function($$AppointmentsTableFilterComposer f) f,
  ) {
    final $$AppointmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appointments,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppointmentsTableFilterComposer(
            $db: $db,
            $table: $db.appointments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> treatmentsRefs(
    Expression<bool> Function($$TreatmentsTableFilterComposer f) f,
  ) {
    final $$TreatmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatments,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableFilterComposer(
            $db: $db,
            $table: $db.treatments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prescriptionsRefs(
    Expression<bool> Function($$PrescriptionsTableFilterComposer f) f,
  ) {
    final $$PrescriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionsTableFilterComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> toothConditionsRefs(
    Expression<bool> Function($$ToothConditionsTableFilterComposer f) f,
  ) {
    final $$ToothConditionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.toothConditions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ToothConditionsTableFilterComposer(
            $db: $db,
            $table: $db.toothConditions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicalHistory => $composableBuilder(
    column: $table.medicalHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get medicalHistory => $composableBuilder(
    column: $table.medicalHistory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> appointmentsRefs<T extends Object>(
    Expression<T> Function($$AppointmentsTableAnnotationComposer a) f,
  ) {
    final $$AppointmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appointments,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppointmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.appointments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> treatmentsRefs<T extends Object>(
    Expression<T> Function($$TreatmentsTableAnnotationComposer a) f,
  ) {
    final $$TreatmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatments,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.treatments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prescriptionsRefs<T extends Object>(
    Expression<T> Function($$PrescriptionsTableAnnotationComposer a) f,
  ) {
    final $$PrescriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prescriptions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrescriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.prescriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> toothConditionsRefs<T extends Object>(
    Expression<T> Function($$ToothConditionsTableAnnotationComposer a) f,
  ) {
    final $$ToothConditionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.toothConditions,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ToothConditionsTableAnnotationComposer(
            $db: $db,
            $table: $db.toothConditions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          Patient,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (Patient, $$PatientsTableReferences),
          Patient,
          PrefetchHooks Function({
            bool appointmentsRefs,
            bool treatmentsRefs,
            bool paymentsRefs,
            bool prescriptionsRefs,
            bool toothConditionsRefs,
          })
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> medicalHistory = const Value.absent(),
                Value<String?> allergies = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PatientsCompanion(
                id: id,
                name: name,
                phone: phone,
                age: age,
                gender: gender,
                address: address,
                medicalHistory: medicalHistory,
                allergies: allergies,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String phone,
                Value<int?> age = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> medicalHistory = const Value.absent(),
                Value<String?> allergies = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                age: age,
                gender: gender,
                address: address,
                medicalHistory: medicalHistory,
                allergies: allergies,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PatientsTable, Patient>(table),
                  $$PatientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                appointmentsRefs = false,
                treatmentsRefs = false,
                paymentsRefs = false,
                prescriptionsRefs = false,
                toothConditionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (appointmentsRefs) db.appointments,
                    if (treatmentsRefs) db.treatments,
                    if (paymentsRefs) db.payments,
                    if (prescriptionsRefs) db.prescriptions,
                    if (toothConditionsRefs) db.toothConditions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (appointmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Patient,
                          $PatientsTable,
                          Appointment,
                          $AppointmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._appointmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).appointmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'patient_id',
                          typedResults: items,
                        ),
                      if (treatmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Patient,
                          $PatientsTable,
                          Treatment,
                          $TreatmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._treatmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).treatmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'patient_id',
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Patient,
                          $PatientsTable,
                          Payment,
                          $PaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'patient_id',
                          typedResults: items,
                        ),
                      if (prescriptionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Patient,
                          $PatientsTable,
                          Prescription,
                          $PrescriptionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._prescriptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).prescriptionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'patient_id',
                          typedResults: items,
                        ),
                      if (toothConditionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Patient,
                          $PatientsTable,
                          ToothCondition,
                          $ToothConditionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableReferences
                              ._toothConditionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableReferences(
                                db,
                                table,
                                p0,
                              ).toothConditionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'patient_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      Patient,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (Patient, $$PatientsTableReferences),
      Patient,
      PrefetchHooks Function({
        bool appointmentsRefs,
        bool treatmentsRefs,
        bool paymentsRefs,
        bool prescriptionsRefs,
        bool toothConditionsRefs,
      })
    >;
typedef $$AppointmentsTableCreateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<int> id,
      required int patientId,
      required DateTime appointmentDate,
      Value<String> status,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$AppointmentsTableUpdateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<int> id,
      Value<int> patientId,
      Value<DateTime> appointmentDate,
      Value<String> status,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$AppointmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment> {
  $$AppointmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('appointments__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<int>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appointmentDate => $composableBuilder(
    column: $table.appointmentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appointmentDate => $composableBuilder(
    column: $table.appointmentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get appointmentDate => $composableBuilder(
    column: $table.appointmentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppointmentsTable,
          Appointment,
          $$AppointmentsTableFilterComposer,
          $$AppointmentsTableOrderingComposer,
          $$AppointmentsTableAnnotationComposer,
          $$AppointmentsTableCreateCompanionBuilder,
          $$AppointmentsTableUpdateCompanionBuilder,
          (Appointment, $$AppointmentsTableReferences),
          Appointment,
          PrefetchHooks Function({bool patientId})
        > {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> patientId = const Value.absent(),
                Value<DateTime> appointmentDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppointmentsCompanion(
                id: id,
                patientId: patientId,
                appointmentDate: appointmentDate,
                status: status,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int patientId,
                required DateTime appointmentDate,
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppointmentsCompanion.insert(
                id: id,
                patientId: patientId,
                appointmentDate: appointmentDate,
                status: status,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppointmentsTable, Appointment>(table),
                  $$AppointmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.patientId,
                        referencedTable: $$AppointmentsTableReferences
                            ._patientIdTable(db),
                        referencedColumn: $$AppointmentsTableReferences
                            ._patientIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppointmentsTable,
      Appointment,
      $$AppointmentsTableFilterComposer,
      $$AppointmentsTableOrderingComposer,
      $$AppointmentsTableAnnotationComposer,
      $$AppointmentsTableCreateCompanionBuilder,
      $$AppointmentsTableUpdateCompanionBuilder,
      (Appointment, $$AppointmentsTableReferences),
      Appointment,
      PrefetchHooks Function({bool patientId})
    >;
typedef $$TreatmentsTableCreateCompanionBuilder = TreatmentsCompanion Function({
  Value<int> id,
  required int patientId,
  Value<String?> toothNumber,
  required String procedure,
  Value<double> cost,
  required DateTime date,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$TreatmentsTableUpdateCompanionBuilder = TreatmentsCompanion Function({
  Value<int> id,
  Value<int> patientId,
  Value<String?> toothNumber,
  Value<String> procedure,
  Value<double> cost,
  Value<DateTime> date,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

final class $$TreatmentsTableReferences
    extends BaseReferences<_$AppDatabase, $TreatmentsTable, Treatment> {
  $$TreatmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('treatments__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<int>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'treatments__id__payments__treatment_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.treatmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TreatmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TreatmentsTable> {
  $$TreatmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toothNumber => $composableBuilder(
    column: $table.toothNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get procedure => $composableBuilder(
    column: $table.procedure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.treatmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreatmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TreatmentsTable> {
  $$TreatmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toothNumber => $composableBuilder(
    column: $table.toothNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get procedure => $composableBuilder(
    column: $table.procedure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreatmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreatmentsTable> {
  $$TreatmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get toothNumber => $composableBuilder(
    column: $table.toothNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get procedure =>
      $composableBuilder(column: $table.procedure, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.treatmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreatmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreatmentsTable,
          Treatment,
          $$TreatmentsTableFilterComposer,
          $$TreatmentsTableOrderingComposer,
          $$TreatmentsTableAnnotationComposer,
          $$TreatmentsTableCreateCompanionBuilder,
          $$TreatmentsTableUpdateCompanionBuilder,
          (Treatment, $$TreatmentsTableReferences),
          Treatment,
          PrefetchHooks Function({bool patientId, bool paymentsRefs})
        > {
  $$TreatmentsTableTableManager(_$AppDatabase db, $TreatmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreatmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreatmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreatmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> patientId = const Value.absent(),
                Value<String?> toothNumber = const Value.absent(),
                Value<String> procedure = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TreatmentsCompanion(
                id: id,
                patientId: patientId,
                toothNumber: toothNumber,
                procedure: procedure,
                cost: cost,
                date: date,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int patientId,
                Value<String?> toothNumber = const Value.absent(),
                required String procedure,
                Value<double> cost = const Value.absent(),
                required DateTime date,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TreatmentsCompanion.insert(
                id: id,
                patientId: patientId,
                toothNumber: toothNumber,
                procedure: procedure,
                cost: cost,
                date: date,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TreatmentsTable, Treatment>(table),
                  $$TreatmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false, paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.patientId,
                        referencedTable: $$TreatmentsTableReferences
                            ._patientIdTable(db),
                        referencedColumn: $$TreatmentsTableReferences
                            ._patientIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedDataByColumns<
                      Treatment,
                      $TreatmentsTable,
                      Payment,
                      $PaymentsTable
                    >(
                      currentTable: table,
                      referencedTable: $$TreatmentsTableReferences
                          ._paymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TreatmentsTableReferences(
                            db,
                            table,
                            p0,
                          ).paymentsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'treatment_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TreatmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreatmentsTable,
      Treatment,
      $$TreatmentsTableFilterComposer,
      $$TreatmentsTableOrderingComposer,
      $$TreatmentsTableAnnotationComposer,
      $$TreatmentsTableCreateCompanionBuilder,
      $$TreatmentsTableUpdateCompanionBuilder,
      (Treatment, $$TreatmentsTableReferences),
      Treatment,
      PrefetchHooks Function({bool patientId, bool paymentsRefs})
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  required int patientId,
  Value<int?> treatmentId,
  required double amount,
  required DateTime date,
  required String method,
  Value<DateTime> createdAt,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  Value<int> patientId,
  Value<int?> treatmentId,
  Value<double> amount,
  Value<DateTime> date,
  Value<String> method,
  Value<DateTime> createdAt,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('payments__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<int>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TreatmentsTable _treatmentIdTable(_$AppDatabase db) =>
      db.treatments.createAlias('payments__treatment_id__treatments__id');

  $$TreatmentsTableProcessedTableManager? get treatmentId {
    final $_column = $_itemColumn<int>('treatment_id');
    if ($_column == null) return null;
    final manager = $$TreatmentsTableTableManager(
      $_db,
      $_db.treatments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_treatmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TreatmentsTableFilterComposer get treatmentId {
    final $$TreatmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatmentId,
      referencedTable: $db.treatments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableFilterComposer(
            $db: $db,
            $table: $db.treatments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TreatmentsTableOrderingComposer get treatmentId {
    final $$TreatmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatmentId,
      referencedTable: $db.treatments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableOrderingComposer(
            $db: $db,
            $table: $db.treatments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TreatmentsTableAnnotationComposer get treatmentId {
    final $$TreatmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatmentId,
      referencedTable: $db.treatments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.treatments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({bool patientId, bool treatmentId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> patientId = const Value.absent(),
                Value<int?> treatmentId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                patientId: patientId,
                treatmentId: treatmentId,
                amount: amount,
                date: date,
                method: method,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int patientId,
                Value<int?> treatmentId = const Value.absent(),
                required double amount,
                required DateTime date,
                required String method,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                patientId: patientId,
                treatmentId: treatmentId,
                amount: amount,
                date: date,
                method: method,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, Payment>(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false, treatmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.patientId,
                        referencedTable: $$PaymentsTableReferences
                            ._patientIdTable(db),
                        referencedColumn: $$PaymentsTableReferences
                            ._patientIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (treatmentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.treatmentId,
                        referencedTable: $$PaymentsTableReferences
                            ._treatmentIdTable(db),
                        referencedColumn: $$PaymentsTableReferences
                            ._treatmentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({bool patientId, bool treatmentId})
    >;
typedef $$PrescriptionsTableCreateCompanionBuilder =
    PrescriptionsCompanion Function({
      Value<int> id,
      required int patientId,
      required DateTime date,
      required String medicines,
      Value<String?> advice,
      Value<DateTime> createdAt,
    });
typedef $$PrescriptionsTableUpdateCompanionBuilder =
    PrescriptionsCompanion Function({
      Value<int> id,
      Value<int> patientId,
      Value<DateTime> date,
      Value<String> medicines,
      Value<String?> advice,
      Value<DateTime> createdAt,
    });

final class $$PrescriptionsTableReferences
    extends BaseReferences<_$AppDatabase, $PrescriptionsTable, Prescription> {
  $$PrescriptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('prescriptions__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<int>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrescriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicines => $composableBuilder(
    column: $table.medicines,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get advice => $composableBuilder(
    column: $table.advice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicines => $composableBuilder(
    column: $table.medicines,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get advice => $composableBuilder(
    column: $table.advice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get medicines =>
      $composableBuilder(column: $table.medicines, builder: (column) => column);

  GeneratedColumn<String> get advice =>
      $composableBuilder(column: $table.advice, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrescriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrescriptionsTable,
          Prescription,
          $$PrescriptionsTableFilterComposer,
          $$PrescriptionsTableOrderingComposer,
          $$PrescriptionsTableAnnotationComposer,
          $$PrescriptionsTableCreateCompanionBuilder,
          $$PrescriptionsTableUpdateCompanionBuilder,
          (Prescription, $$PrescriptionsTableReferences),
          Prescription,
          PrefetchHooks Function({bool patientId})
        > {
  $$PrescriptionsTableTableManager(_$AppDatabase db, $PrescriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrescriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrescriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrescriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> patientId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> medicines = const Value.absent(),
                Value<String?> advice = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PrescriptionsCompanion(
                id: id,
                patientId: patientId,
                date: date,
                medicines: medicines,
                advice: advice,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int patientId,
                required DateTime date,
                required String medicines,
                Value<String?> advice = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PrescriptionsCompanion.insert(
                id: id,
                patientId: patientId,
                date: date,
                medicines: medicines,
                advice: advice,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrescriptionsTable, Prescription>(table),
                  $$PrescriptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.patientId,
                        referencedTable: $$PrescriptionsTableReferences
                            ._patientIdTable(db),
                        referencedColumn: $$PrescriptionsTableReferences
                            ._patientIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PrescriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrescriptionsTable,
      Prescription,
      $$PrescriptionsTableFilterComposer,
      $$PrescriptionsTableOrderingComposer,
      $$PrescriptionsTableAnnotationComposer,
      $$PrescriptionsTableCreateCompanionBuilder,
      $$PrescriptionsTableUpdateCompanionBuilder,
      (Prescription, $$PrescriptionsTableReferences),
      Prescription,
      PrefetchHooks Function({bool patientId})
    >;
typedef $$ProcedurePricesTableCreateCompanionBuilder =
    ProcedurePricesCompanion Function({
      Value<int> id,
      required String name,
      required double defaultPrice,
    });
typedef $$ProcedurePricesTableUpdateCompanionBuilder =
    ProcedurePricesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> defaultPrice,
    });

class $$ProcedurePricesTableFilterComposer
    extends Composer<_$AppDatabase, $ProcedurePricesTable> {
  $$ProcedurePricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProcedurePricesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcedurePricesTable> {
  $$ProcedurePricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProcedurePricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcedurePricesTable> {
  $$ProcedurePricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => column,
  );
}

class $$ProcedurePricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProcedurePricesTable,
          ProcedurePrice,
          $$ProcedurePricesTableFilterComposer,
          $$ProcedurePricesTableOrderingComposer,
          $$ProcedurePricesTableAnnotationComposer,
          $$ProcedurePricesTableCreateCompanionBuilder,
          $$ProcedurePricesTableUpdateCompanionBuilder,
          (
            ProcedurePrice,
            BaseReferences<
              _$AppDatabase,
              $ProcedurePricesTable,
              ProcedurePrice
            >,
          ),
          ProcedurePrice,
          PrefetchHooks Function()
        > {
  $$ProcedurePricesTableTableManager(
    _$AppDatabase db,
    $ProcedurePricesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcedurePricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcedurePricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcedurePricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> defaultPrice = const Value.absent(),
              }) => ProcedurePricesCompanion(
                id: id,
                name: name,
                defaultPrice: defaultPrice,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double defaultPrice,
              }) => ProcedurePricesCompanion.insert(
                id: id,
                name: name,
                defaultPrice: defaultPrice,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProcedurePricesTable, ProcedurePrice>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProcedurePricesTable,
                    ProcedurePrice
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProcedurePricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProcedurePricesTable,
      ProcedurePrice,
      $$ProcedurePricesTableFilterComposer,
      $$ProcedurePricesTableOrderingComposer,
      $$ProcedurePricesTableAnnotationComposer,
      $$ProcedurePricesTableCreateCompanionBuilder,
      $$ProcedurePricesTableUpdateCompanionBuilder,
      (
        ProcedurePrice,
        BaseReferences<_$AppDatabase, $ProcedurePricesTable, ProcedurePrice>,
      ),
      ProcedurePrice,
      PrefetchHooks Function()
    >;
typedef $$ToothConditionsTableCreateCompanionBuilder =
    ToothConditionsCompanion Function({
      Value<int> id,
      required int patientId,
      required String toothNumber,
      Value<String> condition,
      Value<String?> surfaces,
      Value<String?> notes,
      Value<DateTime> updatedAt,
    });
typedef $$ToothConditionsTableUpdateCompanionBuilder =
    ToothConditionsCompanion Function({
      Value<int> id,
      Value<int> patientId,
      Value<String> toothNumber,
      Value<String> condition,
      Value<String?> surfaces,
      Value<String?> notes,
      Value<DateTime> updatedAt,
    });

final class $$ToothConditionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ToothConditionsTable, ToothCondition> {
  $$ToothConditionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('tooth_conditions__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<int>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ToothConditionsTableFilterComposer
    extends Composer<_$AppDatabase, $ToothConditionsTable> {
  $$ToothConditionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toothNumber => $composableBuilder(
    column: $table.toothNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surfaces => $composableBuilder(
    column: $table.surfaces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ToothConditionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ToothConditionsTable> {
  $$ToothConditionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toothNumber => $composableBuilder(
    column: $table.toothNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surfaces => $composableBuilder(
    column: $table.surfaces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ToothConditionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ToothConditionsTable> {
  $$ToothConditionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get toothNumber => $composableBuilder(
    column: $table.toothNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get surfaces =>
      $composableBuilder(column: $table.surfaces, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ToothConditionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ToothConditionsTable,
          ToothCondition,
          $$ToothConditionsTableFilterComposer,
          $$ToothConditionsTableOrderingComposer,
          $$ToothConditionsTableAnnotationComposer,
          $$ToothConditionsTableCreateCompanionBuilder,
          $$ToothConditionsTableUpdateCompanionBuilder,
          (ToothCondition, $$ToothConditionsTableReferences),
          ToothCondition,
          PrefetchHooks Function({bool patientId})
        > {
  $$ToothConditionsTableTableManager(
    _$AppDatabase db,
    $ToothConditionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ToothConditionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ToothConditionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ToothConditionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> patientId = const Value.absent(),
                Value<String> toothNumber = const Value.absent(),
                Value<String> condition = const Value.absent(),
                Value<String?> surfaces = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ToothConditionsCompanion(
                id: id,
                patientId: patientId,
                toothNumber: toothNumber,
                condition: condition,
                surfaces: surfaces,
                notes: notes,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int patientId,
                required String toothNumber,
                Value<String> condition = const Value.absent(),
                Value<String?> surfaces = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ToothConditionsCompanion.insert(
                id: id,
                patientId: patientId,
                toothNumber: toothNumber,
                condition: condition,
                surfaces: surfaces,
                notes: notes,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ToothConditionsTable, ToothCondition>(table),
                  $$ToothConditionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.patientId,
                        referencedTable: $$ToothConditionsTableReferences
                            ._patientIdTable(db),
                        referencedColumn: $$ToothConditionsTableReferences
                            ._patientIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ToothConditionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ToothConditionsTable,
      ToothCondition,
      $$ToothConditionsTableFilterComposer,
      $$ToothConditionsTableOrderingComposer,
      $$ToothConditionsTableAnnotationComposer,
      $$ToothConditionsTableCreateCompanionBuilder,
      $$ToothConditionsTableUpdateCompanionBuilder,
      (ToothCondition, $$ToothConditionsTableReferences),
      ToothCondition,
      PrefetchHooks Function({bool patientId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
  $$TreatmentsTableTableManager get treatments =>
      $$TreatmentsTableTableManager(_db, _db.treatments);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$PrescriptionsTableTableManager get prescriptions =>
      $$PrescriptionsTableTableManager(_db, _db.prescriptions);
  $$ProcedurePricesTableTableManager get procedurePrices =>
      $$ProcedurePricesTableTableManager(_db, _db.procedurePrices);
  $$ToothConditionsTableTableManager get toothConditions =>
      $$ToothConditionsTableTableManager(_db, _db.toothConditions);
}
