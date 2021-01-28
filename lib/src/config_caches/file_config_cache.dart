/*
 * The Clear BSD License
 *
 * Copyright (c) 2021 Bitsy Darel
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted (subject to the limitations in the disclaimer
 * below) provided that the following conditions are met:
 *
 *      * Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *
 *      * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *      * Neither the name of the copyright holder nor the names of its
 *      contributors may be used to endorse or promote products derived from
 *      this software without specific prior written permission.
 *
 * NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY
 * THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
 * NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import 'dart:convert';
import 'dart:io';

import 'package:hooks/src/config_cache.dart';
import 'package:hooks/src/script_config.dart';
import 'package:meta/meta.dart';

/// [ConfigCache] that save [ScriptConfig] to a file.
class FileConfigCache extends ConfigCache {
  ScriptConfig _cachedConfig;

  final String _configFilePath;

  /// Create [FileConfigCache] with the specified [hooksDir].
  FileConfigCache({@required Directory hooksDir})
      : assert(hooksDir != null, "Hooks Directory can't be null"),
        _configFilePath = '${hooksDir.path}/.script_config';

  @override
  Future<ScriptConfig> loadScriptConfig() async {
    return _cachedConfig ??= await _loadFromFile();
  }

  @override
  Future<void> saveScriptConfig(final ScriptConfig config) async {
    final File configFile = File(_configFilePath);

    final Map<String, Object> mappedConfig = config.toJson();

    final String jsonConfig = jsonEncode(mappedConfig);

    configFile.writeAsStringSync(jsonConfig, mode: FileMode.write, flush: true);
  }

  @override
  Future<ScriptConfig> refreshScriptConfig() async {
    final ScriptConfig config = await _loadFromFile();
    _cachedConfig = config;
    return config;
  }

  Future<ScriptConfig> _loadFromFile() async {
    final File configFile = File(_configFilePath);

    if (configFile.existsSync()) {
      final String rawConfig = configFile.readAsStringSync();

      final Object jsonConfig = jsonDecode(rawConfig);

      if (jsonConfig is Map<String, Object>) {
        return ScriptConfig.fromJson(jsonConfig);
      }
    }

    return null;
  }
}
