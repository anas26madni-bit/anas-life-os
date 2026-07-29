// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../database/database_initializer.dart' as _i3;
import '../logging/app_logger.dart' as _i4;
import '../logging/developer_app_logger.dart' as _i5;

extension GetItInjectableX on _i1.GetIt {
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final helper = _i2.GetItHelper(this, environment, environmentFilter);
    helper.lazySingleton<_i4.AppLogger>(_i5.DeveloperAppLogger.new);
    helper.lazySingleton<_i3.DatabaseInitializer>(
      () => _i3.DatabaseInitializer(helper<_i4.AppLogger>()),
    );
    return this;
  }
}
