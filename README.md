# hooks

A project hooks tool for dart, flutter and other.

## Overview

A command-line tool that help you setup common hooks check for a project.

It's help you automate your code style check, tests result, branch naming and more before executing a code commit.

[license](https://github.com/bitsydarel/hooks/blob/master/LICENSE).

<br>

## Installation

For usage everywhere in the system.

```bash
pub global activate hooks
```

For usage only in the current package.

```bash
pub activate hooks
```

<br>

<br>

## Usage

```bash
hooks --project-type [project type] [local project directory]
```

Options:
--project-type Specify the type of project the script is run on
[dart] (default)             Static analytics for dart project
[flutter]                    Static analytics for flutter project

--commit-message-rule Specify the commit message rule (defaults to "^(?=[\w]).*")

--branch-naming-rule Specify the branch naming rule (defaults to "(^(?=[feature\/|release\/|hotfix\/][a-z\d]
+[-\/_\.]*[a-z\d]*)(?!.*[\@ ]).*)|^(?=(develop|master|main)$).*")

--[no-]code-style-check-enabled Enable code style check on pre-commit (defaults to on)

--[no-]unit-tests-Enabled Enable unit tests on pre-commit (defaults to on)

--[no-]help Print help message

<br>

<br>

## Example

Setup hooks for a dart/flutter the project.

```bash
hooks --project-type [dart/flutter] [project dir]
```

Setup hooks with a different commit message rule

```bash
hooks --project-type dart --commit-message-rule "^(?=[\@]).*" [project dir]
```

Setup hooks with a different branch naming rule

```bash
hooks --project-type dart --branch-naming-rule "^(?=[master,develop,beta,dev]).*" [project dir]
```

Setup hooks with code style check disabled on pre-commit

```bash
hooks --project-type dart --no-code-style-check-enabled [project dir]
```

Setup hooks with unit tests disabled on pre-commit

```bash
hooks --project-type dart --no-unit-tests-enabled [project dir]
```

<br>