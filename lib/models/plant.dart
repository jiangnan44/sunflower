class Plant {
  String plantId;
  String name;
  String description;
  int growZoneNumber;
  int wateringInterval;
  String imageUrl;

  Plant(
    this.plantId,
    this.name, {
    this.description = "",
    this.growZoneNumber = 0,
    this.wateringInterval = 7,
    this.imageUrl = "",
  });

  bool shouldBeWatered(DateTime since, DateTime lastWateringTime) {
    return since.day - lastWateringTime.day > wateringInterval;
  }

  String waterInString() {
    if (wateringInterval <= 1) {
      return "water in 1 day";
    } else {
      return "water in $wateringInterval days";
    }
  }

  String wateringIntervalString() {
    if (wateringInterval <= 1) {
      return "every day";
    } else {
      return "every $wateringInterval days";
    }
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      json['plantId'] as String,
      json['name'] as String,
      description: json['description'] as String,
      growZoneNumber: json['growZoneNumber'] as int,
      wateringInterval: json['wateringInterval'] as int,
      imageUrl: json['imageUrl'] as String,
    );
  }

  @override
  String toString() {
    return 'Plant{plantId: $plantId, name: $name, description: $description, growZoneNumber: $growZoneNumber, wateringInterval: $wateringInterval, imageUrl: $imageUrl}';
  }
}
