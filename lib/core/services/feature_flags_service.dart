class FeatureFlags {
  final bool aiEnabled;
  final bool outbreakMapEnabled;
  final bool adminEnabled;
  final bool offlineSyncEnabled;

  const FeatureFlags({
    this.aiEnabled = true,
    this.outbreakMapEnabled = true,
    this.adminEnabled = false,
    this.offlineSyncEnabled = true,
  });

  FeatureFlags copyWith({
    bool? aiEnabled,
    bool? outbreakMapEnabled,
    bool? adminEnabled,
    bool? offlineSyncEnabled,
  }) {
    return FeatureFlags(
      aiEnabled: aiEnabled ?? this.aiEnabled,
      outbreakMapEnabled: outbreakMapEnabled ?? this.outbreakMapEnabled,
      adminEnabled: adminEnabled ?? this.adminEnabled,
      offlineSyncEnabled: offlineSyncEnabled ?? this.offlineSyncEnabled,
    );
  }
}
