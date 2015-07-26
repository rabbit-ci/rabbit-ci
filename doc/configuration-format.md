---
spec-version: 0.0.1
---

# Rabbit CI Project Configuration

This document specifies the requirements for a Rabbit CI project
configuration. A project configuration describes how a project should
be built on Rabbit CI.

***

The configuration consists of a unix style line ending (LF), UTF-8
encoded [YAML][http://yaml.org] document in the root directory of a
project's Git repository, named: `.rabbitci.yaml`.

The configuration MUST contain a `spec-version` field set to the
version of this specification that it complies with.

The configuration MUST contain a `name` field set to a string which
contains any alphanumerical characters, underscores `_`, hypens `-`,
or forward slashes `/`.

The configuration MAY contain a `human-name` field set to a unicode
string. This field is used in place of the `name` field on specific
pages.

The configuration MAY contain a `github` field set to a string in the
format of: `:owner/:repo`. This field is used to provide GitHub
specific functionality to Rabbit CI projects.

## Worker definitions

Workers are environments that Rabbit CI builds can run in. They are
defined under a `workers` field in the configuration.

The configuration MUST contain a `workers` field set to a list of
workers.

A worker MUST contain a `name` field set to a string which contains
any alphanumerical characters, underscores `_`, hypens `-`, or forward
slashes `/`.

A worker MUST contain an `os` field set to the operating system that
the worker runs (e.g. `ubuntu`).

A worker MUST contain a `platform` field set to the platform that the
worker runs (e.g. `linux`).

A worker MUST contain a `vm` field describing a [VM](#vm-definitions).

A worker MUST contain a `setup` field set to a script that will be run
on the worker. NOTE: This is _not_ a path to the script, this is the
script itself.

A worker MAY contain a `file_deps` field set to a list of files that
will require a rebuild of the worker whenever they change
(e.g. Gemfile.lock).

### VM definitions

A VM MUST contain a `type` field. Currently the only available type is
"vagrant".

A Vagrant VM MUST contain a `box` field that is a valid Vagrant box.

A Vagrant VM MAY contain a `memory` field that is the about of RAM to
allocate to the VM specified in the format: `#GB` where `#` is one or
more of digits. The default is determined by the Rabbit CI server.

A Vagrant VM MAY contain a `cpu_cores` field that is the number of CPU
cores to allocate to the VM. The default is determined by the Rabbit
CI server.

A Vagrant VM MAY contain a `disk` field that is the amount of storage
to provide to the VM. The default is determined by the Rabbit CI
server.

## Step definitions

The configuration MUST contain a `steps` field set to a list of steps.

A step MUST contain a `name` field set to a string which contains
any alphanumerical characters, underscores `_`, hypens `-`, or forward
slashes `/`.

A step MUST contain a `command` field set to a script that will be run
on the worker. NOTE: This is _not_ a path to the script, this is the
script itself.

A step MUST contain a `workers` field set to a list of the names of
workers that it will run on.
