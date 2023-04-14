import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../util/logger.dart';

class GardenPlanting {
  String plantId;
  int plantTime;
  int lastWateringTime;

  GardenPlanting({
    this.plantId = "",
    this.plantTime = 0,
    this.lastWateringTime = 0,
  });

  _testFormat() async {
    initializeDateFormatting('zh', '').then((value) {
      VLog.d(DateFormat.yMMMEd('zh').format(DateTime.now()));
    });
  }

  String plantDateTime() {
    return DateFormat.yMMMEd()
        .format(DateTime.fromMillisecondsSinceEpoch(plantTime).toLocal());
  }

  String lastWateringDateTime() {
    return DateFormat('yyyy-MM-dd').format(
        DateTime.fromMillisecondsSinceEpoch(lastWateringTime).toLocal());
  }

  @override
  String toString() {
    return 'GardenPlanting{plantId: $plantId, plantTime: $plantTime, lastWateringTime: $lastWateringTime}';
  }
}
