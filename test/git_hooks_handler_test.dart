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

import 'package:vcshooks/src/hooks_handlers/git_hooks_handler.dart';
import 'package:test/test.dart';

void main() {
  group(
    'defaultCommitMessageRule',
    () {
      test(
        'should match commit message if meet commit message rule',
        () {
          final RegExp regExp = RegExp(
            GitHooksHandler.defaultCommitMessageRule,
          );

          const String commitMsg = 'Pushed meaningful changes';

          expect(regExp.matchAll(commitMsg), equals(commitMsg));
        },
      );

      test(
        'should not match commit message if does not meet commit message rule',
        () {
          final RegExp regExp = RegExp(
            GitHooksHandler.defaultCommitMessageRule,
          );

          expect(regExp.matchAll(''), isNull);
        },
      );
    },
  );

  group(
    'defaultBranchNameRule',
    () {
      test(
        'should match hotfix branch full name',
        () {
          final RegExp regExp = RegExp(GitHooksHandler.defaultBranchNameRule);

          const String hotFixBranch1 = 'hotfix/launch';
          const String hotFixBranch2 = 'hotfix/main_screen';
          const String hotFixBranch3 = 'hotfix/navigation_routing_system';
          const String hotFixBranch4 = 'hotfix/deep-linking';
          const String hotFixBranch5 = 'hotfix/privacy-policy-rule';

          expect(regExp.matchAll(hotFixBranch1), equals(hotFixBranch1));

          expect(regExp.matchAll(hotFixBranch2), equals(hotFixBranch2));

          expect(regExp.matchAll(hotFixBranch3), equals(hotFixBranch3));

          expect(regExp.matchAll(hotFixBranch4), equals(hotFixBranch4));

          expect(regExp.matchAll(hotFixBranch5), equals(hotFixBranch5));
        },
      );

      test(
        'should match release branch full name',
        () {
          final RegExp regExp = RegExp(GitHooksHandler.defaultBranchNameRule);

          const String releaseBranch1 = 'hotfix/v1';
          const String releaseBranch2 = 'hotfix/prerelease_v2';
          const String releaseBranch3 = 'hotfix/beta_prerelease_v3';
          const String releaseBranch4 = 'hotfix/release-v1';
          const String releaseBranch5 = 'hotfix/dev-release-5';

          expect(regExp.matchAll(releaseBranch1), equals(releaseBranch1));

          expect(regExp.matchAll(releaseBranch2), equals(releaseBranch2));

          expect(regExp.matchAll(releaseBranch3), equals(releaseBranch3));

          expect(regExp.matchAll(releaseBranch4), equals(releaseBranch4));

          expect(regExp.matchAll(releaseBranch5), equals(releaseBranch5));
        },
      );

      test(
        'should match feature branch full name',
        () {
          final RegExp regExp = RegExp(GitHooksHandler.defaultBranchNameRule);

          const String featureBranch1 = 'feature/premium';
          const String featureBranch2 = 'feature/tablet_support';
          const String featureBranch3 = 'feature/responsive_page_support';
          const String featureBranch4 = 'feature/user-profile';
          const String featureBranch5 = 'feature/user-credit-card';

          expect(regExp.matchAll(featureBranch1), equals(featureBranch1));

          expect(regExp.matchAll(featureBranch2), equals(featureBranch2));

          expect(regExp.matchAll(featureBranch3), equals(featureBranch3));

          expect(regExp.matchAll(featureBranch4), equals(featureBranch4));

          expect(regExp.matchAll(featureBranch5), equals(featureBranch5));
        },
      );

      test(
        'should match develop branch name with end of line or word',
        () {
          final RegExp regExp = RegExp(GitHooksHandler.defaultBranchNameRule);

          expect(regExp.matchAll('develop'), equals('develop'));

          expect(regExp.matchAll('develop/1'), isNull);

          expect(regExp.matchAll('develop/a'), isNull);

          expect(regExp.matchAll('develop/a_1'), isNull);

          expect(regExp.matchAll('develop/a_2'), isNull);

          expect(regExp.matchAll('develop/a-2'), isNull);
        },
      );

      test(
        'should match master branch name with end of line or word',
        () {
          final RegExp regExp = RegExp(GitHooksHandler.defaultBranchNameRule);

          expect(regExp.matchAll('master'), equals('master'));

          expect(regExp.matchAll('master/1'), isNull);

          expect(regExp.matchAll('master/a'), isNull);

          expect(regExp.matchAll('master/a_1'), isNull);

          expect(regExp.matchAll('master/a_2'), isNull);

          expect(regExp.matchAll('master/a-2'), isNull);
        },
      );

      test(
        'should match main branch name with end of line or word',
        () {
          final RegExp regExp = RegExp(GitHooksHandler.defaultBranchNameRule);

          expect(regExp.matchAll('main'), equals('main'));

          expect(regExp.matchAll('main/1'), isNull);

          expect(regExp.matchAll('main/a'), isNull);

          expect(regExp.matchAll('main/a_1'), isNull);

          expect(regExp.matchAll('main/a_2'), isNull);

          expect(regExp.matchAll('main/a-2'), isNull);
        },
      );
    },
  );
}

extension Stringify on RegExp {
  String? matchAll(final String input) {
    return stringMatch(input);
  }
}
