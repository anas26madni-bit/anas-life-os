// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../database/database_initializer.dart' as _i865;
import '../logging/app_logger.dart' as _i354;
import '../logging/developer_app_logger.dart' as _i695;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i354.AppLogger>(() => _i695.DeveloperAppLogger());
    gh.lazySingleton<_i865.DatabaseInitializer>(
      () => _i865.DatabaseInitializer(gh<_i354.AppLogger>()),
    );
    return this;
  }
}
