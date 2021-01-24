import 'dart:io';

import 'package:meta/meta.dart';

// ignore_for_file: avoid_as

/// Script configuration file.
class ScriptConfig {
  /// The project type on which the script the script is running.
  final String projectType;

  /// The project's directory on which the script is run against.
  final Directory hooksDir;

  /// The hook's directory where tools are saved.
  final Directory projectDir;

  /// Create the [ScriptConfig] with the specified [projectType], [projectDir]
  /// the [hooksDir].
  const ScriptConfig({
    @required this.projectType,
    @required this.projectDir,
    @required this.hooksDir,
  })  : assert(projectType != null, "project type can't be null"),
        assert(projectDir != null, "project directory can't be null"),
        assert(hooksDir != null, "hooks directory can't be null");

  /// Create json representation of the [ScriptConfig].
  Map<String, Object> toJson() {
    return <String, Object>{
      'projectType': projectType,
      'projectDir': projectDir.path,
      'hooksDir': hooksDir.path,
    };
  }

  /// Create a [ScriptConfig] from the provided [json].
  ScriptConfig.fromJson(final Map<String, Object> json)
      : projectType = json['projectType'] as String,
        projectDir = Directory(json['projectDir'] as String),
        hooksDir = Directory(json['hooksDir'] as String);
}
