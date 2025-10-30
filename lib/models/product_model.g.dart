// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      barcode: fields[0] as String,
      name: fields[1] as String,
      brand: fields[2] as String?,
      imageUrl: fields[3] as String?,
      nutriments: fields[4] as Nutriments?,
      ingredients: (fields[5] as List?)?.cast<String>(),
      allergens: (fields[6] as List?)?.cast<String>(),
      nutriscore: fields[7] as String?,
      categories: fields[8] as String?,
      quantity: fields[9] as String?,
      scannedAt: fields[10] as DateTime?,
      isFavorite: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.barcode)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.nutriments)
      ..writeByte(5)
      ..write(obj.ingredients)
      ..writeByte(6)
      ..write(obj.allergens)
      ..writeByte(7)
      ..write(obj.nutriscore)
      ..writeByte(8)
      ..write(obj.categories)
      ..writeByte(9)
      ..write(obj.quantity)
      ..writeByte(10)
      ..write(obj.scannedAt)
      ..writeByte(11)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutrimentsAdapter extends TypeAdapter<Nutriments> {
  @override
  final int typeId = 1;

  @override
  Nutriments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nutriments(
      energy: fields[0] as double?,
      proteins: fields[1] as double?,
      carbohydrates: fields[2] as double?,
      sugars: fields[3] as double?,
      fat: fields[4] as double?,
      saturatedFat: fields[5] as double?,
      fiber: fields[6] as double?,
      sodium: fields[7] as double?,
      salt: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Nutriments obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.energy)
      ..writeByte(1)
      ..write(obj.proteins)
      ..writeByte(2)
      ..write(obj.carbohydrates)
      ..writeByte(3)
      ..write(obj.sugars)
      ..writeByte(4)
      ..write(obj.fat)
      ..writeByte(5)
      ..write(obj.saturatedFat)
      ..writeByte(6)
      ..write(obj.fiber)
      ..writeByte(7)
      ..write(obj.sodium)
      ..writeByte(8)
      ..write(obj.salt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutrimentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
