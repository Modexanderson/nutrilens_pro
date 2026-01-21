// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      allergensToAvoid: (fields[2] as List?)?.cast<String>(),
      dietaryRestrictions: (fields[3] as List?)?.cast<String>(),
      nutritionGoals: fields[4] as NutritionGoals?,
      onboardingCompleted: fields[5] as bool,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.allergensToAvoid)
      ..writeByte(3)
      ..write(obj.dietaryRestrictions)
      ..writeByte(4)
      ..write(obj.nutritionGoals)
      ..writeByte(5)
      ..write(obj.onboardingCompleted)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutritionGoalsAdapter extends TypeAdapter<NutritionGoals> {
  @override
  final int typeId = 3;

  @override
  NutritionGoals read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionGoals(
      dailyCalories: fields[0] as double,
      dailyProtein: fields[1] as double,
      dailyCarbs: fields[2] as double,
      dailyFat: fields[3] as double,
      dailyFiber: fields[4] as double,
      dailySodium: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionGoals obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dailyCalories)
      ..writeByte(1)
      ..write(obj.dailyProtein)
      ..writeByte(2)
      ..write(obj.dailyCarbs)
      ..writeByte(3)
      ..write(obj.dailyFat)
      ..writeByte(4)
      ..write(obj.dailyFiber)
      ..writeByte(5)
      ..write(obj.dailySodium);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionGoalsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
