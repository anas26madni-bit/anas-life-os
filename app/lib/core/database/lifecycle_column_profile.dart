abstract final class LifecycleColumnProfile {
  static const businessEntity = <String>{
    'id',
    'uuid',
    'created_at',
    'updated_at',
    'deleted_at',
    'is_deleted',
    'sync_status',
    'version',
    'created_by',
    'updated_by',
    'notes',
  };

  static const history = <String>{'id', 'uuid', 'created_at'};

  static const schema = <String>{'id', 'uuid'};
}
