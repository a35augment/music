# Music Pipeline

A personal music-data pipeline for importing, preserving, and processing playlist metadata from multiple music services.

The project is primarily written in **Julia**, with **Deno / TypeScript** used where service-specific JavaScript tooling is useful.

> **Status:** Work in progress. The project is currently being reorganized around a manifest-driven pipeline architecture.

## Project Documents

- [License](LICENSE) — license covering this project's source code.
- [Dependency Licenses and Third-Party Notices](THIRD_PARTY_NOTICES.md) — information about known third-party software, dependencies, licenses, and redistribution considerations.
- [Julia Project](Project.toml) — direct Julia project dependencies and project configuration.
- [Julia Manifest](Manifest.toml) — resolved Julia dependency environment.
- [Deno Configuration](deno.json) — Deno and TypeScript dependency configuration.
- [Deno Lockfile](deno.lock) — resolved Deno dependency versions.

## Contents

- [Goal](#goal)
- [Job Manifests](#job-manifests)
- [Input Types](#input-types)
- [Service Architecture](#service-architecture)
- [YouTube Acquisition](#youtube-acquisition)
- [Raw Data Philosophy](#raw-data-philosophy)
- [Repository Structure](#repository-structure)
- [Local Music Data](#local-music-data)
- [Technologies](#technologies)
- [Development](#development)
- [Current Status](#current-status)
- [Planned Direction](#planned-direction)
- [Dependency Licenses](#dependency-licenses)
- [License](#license)

## Goal

The long-term goal is to build a service-independent pipeline that can accept music sources such as playlist URLs or collections of URLs and route them through the appropriate acquisition and processing components.

Instead of putting service-specific logic into the main program, the project separates:

- user input and orchestration
- job descriptions
- service detection
- acquisition backends
- individual work items
- raw data storage
- later normalization and processing

The basic model is:

```text
USER INPUT
    ↓
DETECT INPUT TYPE
    ↓
RESOLVE SERVICE
    ↓
CREATE JOB MANIFEST
    ↓
DISPATCH JOB
    ↓
EXECUTE WORK ITEMS
    ↓
RAW MUSIC DATA
```

## Job Manifests

Work is represented by a manifest describing **what should happen**, rather than recording execution history.

A manifest currently contains:

```text
JOB
────────────────────────
job_id
job_type
work_items

SOURCE
────────────────────────
source_kind
source_value
source_name

OUTPUT
────────────────────────
output_kind
output_value
```

Each job receives a UUID automatically.

For example, a YouTube playlist job can conceptually contain work such as:

```julia
[
    :playlist_index,
    :video_metadata,
    :write_raw
]
```

The manifest acts like a shipping label: once created, downstream components use it to determine what work should be performed.

## Input Types

The importer is being designed to support two top-level input patterns.

### URL

A single playlist URL creates an individual URL job.

```text
playlist URL
    ↓
service resolution
    ↓
URL manifest
    ↓
service work items
    ↓
raw output
```

### Folder / Batch

A local file or directory can represent a collection of inputs.

```text
folder / collection
    ↓
batch job
    ↓
discover individual inputs
    ↓
create URL jobs
    ↓
normal URL pipeline
```

A folder job is therefore a **producer of URL jobs**, rather than a separate implementation of the acquisition pipeline.

## Service Architecture

`main.jl` is intended to remain service-independent.

It should not need hardcoded knowledge of domains such as:

```text
youtube.com
spotify.com
soundcloud.com
deezer.com
```

Instead, registered services determine whether they own a URL and define the work required for that service.

This keeps orchestration separate from service-specific behavior and makes additional services easier to add later.

## YouTube Acquisition

The current development work focuses on YouTube Music playlist metadata.

The acquisition flow is conceptually:

```text
YouTube playlist
    ↓
playlist index
    ↓
video IDs
    ↓
individual video metadata
    ↓
assemble/write records
    ↓
youtube/raw/
```

The project uses `youtubei.js` through Deno for YouTube-specific access.

The Deno dependency configuration is defined in:

```text
deno.json
```

with dependency resolution recorded by:

```text
deno.lock
```

## Raw Data Philosophy

Raw acquisition data is intended to preserve what the source returned.

At acquisition time the pipeline does **not** attempt to:

- deduplicate songs
- normalize metadata
- match tracks between services
- silently remove unavailable entries
- merge duplicate playlist entries

Those operations belong to later processing stages.

This keeps acquisition data separate from interpretation and transformation.

## Repository Structure

The project is currently undergoing a directory and architecture refactor.

The current local project contains:

```text
music/
├── .gitignore
├── README.md
├── LICENSE
├── THIRD_PARTY_NOTICES.md
│
├── Project.toml
├── Manifest.toml
├── deno.json
├── deno.lock
│
├── scripts/
│   ├── main.jl
│   ├── manifest.jl
│   ├── folder.jl
│   ├── url.jl
│   ├── normalize_spotify.py
│   │
│   ├── backends/
│   │   └── youtube_music_probe.ts
│   │
│   ├── services/
│   │   ├── spotify.jl
│   │   └── youtube.jl
│   │
│   └── work_items/
│       ├── playlist_index.jl
│       ├── video_metadata.jl
│       └── write_raw.jl
│
├── spotify/
│   └── raw/
│
└── youtube/
    └── raw/
```

Backup files, local tools, generated raw data, and other development-only files may exist locally while remaining excluded from Git.

The architecture is still evolving. A future Julia package layout may move reusable program components into a conventional `src/` structure while keeping development and utility scripts separate.

## Local Music Data

Raw playlist and music-library data is intentionally excluded from Git.

For example:

```text
spotify/raw/
youtube/raw/
```

remain available as directories in the repository, while their generated contents are ignored.

This allows the source code and directory structure to be synchronized through GitHub without publishing the personal music library used during development.

Users can provide their own supported playlist sources to the importer rather than relying on the developer's local music data.

## Technologies

Current components include:

- **Julia** — orchestration and pipeline logic
- **CSV.jl** — CSV data handling
- **DataFrames.jl** — structured data processing
- **Revise.jl** — Julia development workflow
- **Deno** — JavaScript/TypeScript runtime
- **TypeScript** — service/backend integration
- **youtubei.js** — YouTube / YouTube Music interaction
- **Git / GitHub** — source control and remote development

## Development

The main entry point is currently:

```text
scripts/main.jl
```

Its responsibility is orchestration:

```text
receive input
    ↓
understand input
    ↓
resolve the responsible service
    ↓
create a complete JobManifest
    ↓
dispatch the manifest
```

The actual service work belongs in downstream components rather than being implemented directly in `main.jl`.

The Julia environment for the project is defined by:

```text
Project.toml
Manifest.toml
```

This keeps the project's Julia dependencies separate from the developer's global Julia environment and provides a reproducible dependency set for development on other systems.

## Current Status

The project has already proven several individual concepts, including:

- playlist indexing
- individual video metadata retrieval
- manifest creation
- work-item based jobs
- service-oriented URL routing
- raw output separation
- dedicated Julia project dependency management

Current development is focused on consolidating those pieces into the new orchestration architecture and removing remaining hardcoded assumptions.

## Planned Direction

Near-term work includes:

- complete the `main.jl` architecture refactor
- finalize service registration and service resolution
- complete URL job dispatch
- complete folder/batch job production
- transition the project toward a conventional installable Julia package structure
- make installation and external runtime requirements reproducible
- make the development environment reproducible on additional machines
- preserve raw source data before later normalization stages

Future stages can then build on the raw acquisition pipeline for normalization, comparison, matching, and other music-library operations.

## Dependency Licenses

This project uses third-party open-source software distributed under its own license terms.

Known dependency licensing information and relevant redistribution considerations are documented in [Dependency Licenses and Third-Party Notices](THIRD_PARTY_NOTICES.md).

That document is provided as an informational summary. The license files and notices distributed by the respective third-party projects remain authoritative.

## License

This project is licensed under the MIT Modern Variant.

See [LICENSE](LICENSE) for the complete license terms.