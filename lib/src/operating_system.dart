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

import 'dart:io';

/// Script supported computer operating system.
enum OperatingSystem {
  /// Windows.
  windows,

  /// MacOs.
  macOs,

  /// Linux.
  linux
}

/// Get the current operating system running on the computer.
OperatingSystem getCurrentOs() {
  if (Platform.isWindows) {
    return OperatingSystem.windows;
  } else if (Platform.isMacOS) {
    return OperatingSystem.macOs;
  } else if (Platform.isLinux) {
    return OperatingSystem.linux;
  } else {
    throw const UnsupportedOsException();
  }
}

/// [OperatingSystem] extensions functions.
extension SupportedOperatingSystemExtensions on OperatingSystem {
  /// Get the displayable name of the operating system.
  String name() => Platform.operatingSystem;

  /// Get the displayable version of the operating system.
  String version() => Platform.operatingSystemVersion;

  /// Get the permission tool used to change files permissions.
  String getPermissionTool() {
    switch (this) {
      case OperatingSystem.windows:
        return 'icacls';
      case OperatingSystem.macOs:
      case OperatingSystem.linux:
        // Both mac and linux support the find command, new window system does
        // but through powershell since we don't limit it in specific version.
        return 'find';
      default:
        throw const UnsupportedOsException();
    }
  }

  /// Get permission tool arguments used to change files permissions
  List<String> getPermissionToolArgs(final Directory directory) {
    switch (this) {
      case OperatingSystem.windows:
        return <String>[directory.path, '/t', '/q', '/grant', 'Everyone:RX'];
      case OperatingSystem.macOs:
      case OperatingSystem.linux:
        // Look for a item of type file, for each of those files
        // make them executable.
        return <String>[
          directory.path,
          '-type',
          'f',
          '-exec',
          'chmod',
          '+x',
          '{}',
          ';',
        ];
      default:
        throw const UnsupportedOsException();
    }
  }
}

/// [Exception] that's thrown when the script is used on an [OperatingSystem]
/// that's not supported.
class UnsupportedOsException implements Exception {
  /// Const constructor so it's could be used in a const expression.
  const UnsupportedOsException();
}
