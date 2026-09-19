class Hostel {
  final String id;
  final String name;
  final String code;
  final String? address;
  final int totalBlocks;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Hostel({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    required this.totalBlocks,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hostel.fromJson(Map<String, dynamic> json) {
    return Hostel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      address: json['address'] as String?,
      totalBlocks: json['total_blocks'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class Block {
  final String id;
  final String hostelId;
  final String name;
  final String code;
  final int totalFloors;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Block({
    required this.id,
    required this.hostelId,
    required this.name,
    required this.code,
    required this.totalFloors,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'] as String,
      hostelId: json['hostel_id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      totalFloors: json['total_floors'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class Floor {
  final String id;
  final String blockId;
  final int floorNumber;
  final String? name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Floor({
    required this.id,
    required this.blockId,
    required this.floorNumber,
    this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'] as String,
      blockId: json['block_id'] as String,
      floorNumber: json['floor_number'] as int,
      name: json['name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class Room {
  final String id;
  final String floorId;
  final String roomNumber;
  final int capacity;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Room({
    required this.id,
    required this.floorId,
    required this.roomNumber,
    required this.capacity,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      floorId: json['floor_id'] as String,
      roomNumber: json['room_number'] as String,
      capacity: json['capacity'] as int? ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
