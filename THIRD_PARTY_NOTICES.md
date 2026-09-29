# Third-Party Software Notices

This project uses third-party open-source software.

This document is provided as a convenience to identify known third-party software used by or associated with the project and to make licensing information easier for users, contributors, and distributors to locate.

Each third-party component remains subject to its own copyright notices, license terms, and other applicable notices. The license information distributed by the original project or package is authoritative.

The license for this project does not replace, modify, or relicense third-party software.

## Direct Julia Dependencies

The Julia project environment is defined by `Project.toml` and resolved by `Manifest.toml`.

Known direct dependencies currently include:

| Component     | Version | License |
| ------------- | ------- | ------- |
| CSV.jl        | 1.1.0   | MIT     |
| DataFrames.jl | 1.8.2   | MIT     |
| Revise.jl     | 3.17.1  | MIT     |

These packages may themselves depend on additional Julia packages. The exact resolved dependency tree for a particular project revision should be determined from `Manifest.toml`.

Third-party packages retain their original licenses.

## Julia

This project is designed to run using the Julia programming language.

Julia's primary source code is distributed under the MIT License.

Julia itself incorporates or depends on additional third-party software. Anyone redistributing Julia itself, a Julia runtime, or a bundled application containing Julia should review Julia's own license and third-party notices for the version being distributed.

Installing or using this project through Julia's package manager is not the same as this repository claiming ownership of or relicensing Julia.

## Deno

Deno is used as the JavaScript/TypeScript runtime for service-specific components of this project.

Deno is distributed under the MIT License.

Deno has its own dependency tree and may incorporate additional third-party software. Anyone redistributing or bundling the Deno runtime with this project should review the notices and licenses supplied with the version of Deno being distributed.

A locally installed Deno executable may be used during development without making that executable part of this repository.

## youtubei.js

The YouTube backend uses `youtubei.js`.

Current configured version:

`youtubei.js 18.1.0`

License:

MIT

Known runtime dependencies declared by this version include:

| Component          | License                                              |
| ------------------ | ---------------------------------------------------- |
| @bufbuild/protobuf | Apache-2.0 / BSD-3-Clause licensing applies upstream |
| fflate             | MIT                                                  |
| meriyah            | ISC                                                  |

These components remain subject to their respective upstream license terms.

Dependency versions and dependency trees may change when `youtubei.js` is updated. The project's Deno configuration and lockfile should be treated as the source for determining the version actually resolved by a particular project revision.

## Python Standard Library

The legacy/helper script `scripts/normalize_spotify.py` uses Python standard-library modules rather than separately installed Python packages.

Python itself is not distributed under this project's MIT License. If Python is bundled or redistributed as part of a future packaged distribution, Python's applicable license and third-party notices should be reviewed separately.

## Optional and External Tools

Some development workflows may use programs installed separately from this repository.

An external program should not be assumed to be covered by this project's MIT License merely because this project can invoke it.

This distinction is particularly important for prebuilt executables that may contain or link additional components under licenses different from the main source repository.

## Music Services and Trademarks

References to services such as YouTube, YouTube Music, Spotify, or other music platforms describe services with which this software may interact.

This project is not affiliated with, endorsed by, or sponsored by those services unless explicitly stated otherwise.

Names, trademarks, logos, APIs, content, and services remain subject to the rights and terms of their respective owners.

An open-source software license does not grant permission to use third-party copyrighted content or override the terms of a third-party service.

Users and distributors are responsible for determining which service terms and laws apply to their use of the software.

## Redistribution

The repository primarily contains project source code and dependency-resolution information.

Package managers may obtain third-party dependencies separately when the project is installed.

If a future release directly bundles third-party source code, libraries, executables, runtimes, or other artifacts, the applicable licenses should be reviewed before that release is distributed.

Some licenses may require preservation of copyright notices, license text, attribution, NOTICE material, source availability, or other conditions when the corresponding software is redistributed.

## Disclaimer

This document is an informational summary intended to make third-party licensing easier to discover.

It is not a substitute for the original license text, copyright notices, or other terms supplied by the respective copyright holders.

When this summary and an upstream license or notice differ, the upstream material governs the third-party software.
