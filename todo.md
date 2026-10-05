Music importer: structural audit and running work log
Updated: 2026-10-05. Status: design audit during backend refactor. Source files were inspected, not modified. This file is intended to hold decisions, remaining work, rationale, and verification evidence together.
Confirmed intent
- Main receives input and coordinates URL parsing, service resolution, user work selection, and label creation.
- The URL parser supplies generic URL components. The resolver matches those against service cards in a registry, without service-specific elseif branches.
- youtube.jl supplies the YouTube service card: identity, recognition information, available work, and connection to execution configuration.
- Available work and selected work are different. Main displays the service's available jobs and records only the user's selections on the label.
- Job implementations and resource-specific acceptance policy are deferred. Titles, artists, and albums are examples of future user choices, not finalized job IDs.
- The supplied URL is sufficient source information for the label at this stage. Resource type and playlist ID need not be label fields. A later backend may derive an ID internally.
- The label must be immutable after Main hands it off. Interpret the earlier ambiguous sentence about appending in light of this explicit final requirement. Later results and status belong in separate records associated with the job ID.
- Main should remain service-agnostic and job-agnostic, while understanding the common service-card and manifest contracts.
- Keep backend execution outside Main's preparation logic. No claim of an unhackable process is justified by nesting functions or validating a URL.
Observed structure
main.jl includes manifest.jl, parser.jl, service_registry.jl, resolver.jl, console.jl, url.jl, and folder.jl, then calls main().
main() obtains source_value, calls parse_input, resolves URL service with resolve_url_service(parsed_input.url), obtains source_name, creates and shows a manifest, then calls dispatch_manifest. URL jobs are passed to run_url_job(manifest, service).
create_url_manifest reads service.work_items, service.output_kind, and service.name. It copies the entire work_items vector; no user selection occurs in the supplied Main. It constructs the output path as PROJECT_ROOT / service.name / output_kind.
build_manifest is a constructor function, not a stored source of job data. It adds uuid4() as job_id and returns a named tuple containing the values Main supplies. Main orchestrates creation; manifest.jl performs construction.
run_url_job calls service_definition.handler(manifest). youtube_service currently ignores that argument and returns name, backend, runtime, and script. The consumer then initializes state = nothing and invokes each registered function as work_function(state, manifest, service), replacing state with its returned value.
The URL_WORK_ITEMS dictionary provides name-to-function lookup. It is already a form of dispatch without an elseif chain. Registry loading and service matching are separate concerns.
Current field ownership
Field	Producer	Reader / use
service.hosts	YouTube card	Resolver, exact host or subdomain match
service.name	YouTube card	Main -> source_kind; output path; consumer display
service.work_items	YouTube card	Main currently copies all; desired behavior is a selectable catalog
service.output_kind	YouTube card	Main -> output_kind and output path
service.handler	YouTube card	URL consumer calls it to obtain execution configuration
job_id	build_manifest via uuid4()	Available for correlation; not currently used by shown consumer
source_value	User, trimmed by parser	Manifest; future work/backend input
source_name	User via console prompt	Manifest; not a fetched playlist name
output_value	Main	Manifest, later consumer
backend/runtime/script	youtube_service	Passed to each work function; absent from label
state	Work functions	Accumulated separately from manifest


Audit findings
1. Missing selection stage: service.work_items currently doubles as catalog and mandatory run list. Proposed vocabulary: service.available_work_items and manifest.work_items. Exact names remain a design proposal.
2. Mutability: copy(vector) prevents sharing with the card but still permits modification. Freeze the selected Symbol sequence to a tuple in build_manifest, and validate/canonicalize every other field there. An immutable struct with mutable fields has the same nested-mutation problem. Language-level immutability does not protect against hostile code controlling the process.
3. Handler semantics: handler is currently a configuration factory, not the actual playlist executor. Proposed name: prepare_service or execution_context. Its current destination youtube_service fits that role. Do not point it directly at the TS filename or back at run_url_job.
4. Executor already exists: run_url_job is the second aggregation point for label, resolved service configuration, registry, and state. Its responsibilities can be tightened without adding another coordinator yet.
5. Preflight: check all selected job IDs are supported by the resolved service and registered before running any work. Current code discovers a missing job only when iteration reaches it, possibly after earlier work has run.
6. Job dependencies unresolved: the state chain means jobs may depend on earlier results. Future selectable goals (titles/artists/albums) may share acquisition prerequisites. Define that distinction before implementing arbitrary selection; do not implement the jobs in this audit.
7. Backend mismatch: YouTube configuration points to scripts/backends/youtube_music_backend.ts, but supplied TS is youtube_music_probe(2).ts. Actual intended repository filename/location must be reconciled.
8. Runtime portability: configuration hardcodes tools/deno.exe. This is a Windows-specific path assumption. No provided runtime artifact verifies it.
9. Missing bridge: supplied code does not show a work function invoking Deno, supplying source_value, checking exit status, or decoding stdout JSON. TS emits a JSON array to stdout and progress to stderr; Julia runner expects each work function to return state. Those are the contracts to connect later.
10. Probe behavior: TS currently fetches a playlist and continuation pages, emitting all coded metadata fields, independent of manifest work selections. This is a probe, not proof the user-selection architecture is integrated.
11. Input scope discrepancy: parse_input also accepts existing files/directories; desired URL-only entry gate would need to bypass/separate that branch. Preserve batch behavior only if explicitly wanted.
12. Startup versus execution: url.jl auto-includes all .jl files under work_items during startup, before main() validates a URL. Julia include evaluates top-level expressions. Loading definitions alone need not execute jobs, but side effects in loaded files can run before the gate. Moving parser include earlier does not fix that. Prefer explicit trusted registration with side-effect-free definitions.
13. Parser is a structural regex, not comprehensive URL validation. A local mirror accepted https://youtube.com:bad/ and resolved it after discarding the port. Host support and resource support are different gates; resource policy remains deferred.
14. Registry ambiguity: resolver returns the first match. Future overlapping cards should be rejected at registration or have an explicit precedence policy.
15. Global work registry: register_url_work_item! overwrites duplicate names. Establish duplicate rejection or service-scoped IDs before adding conflicting implementations.
16. Output isolation: all current YouTube raw jobs get the same output directory. Decide later whether consumers isolate artifacts by job_id; do not assume source_name isolates them.
17. Execution protection: a deeper function or separate file is an organizational boundary. If protection against hostile code is required, identify the threat and use a separate process with limited OS permissions and validated requests. Do not introduce that infrastructure before its purpose is understood.
Test evidence and limits
No Julia or Deno executable was found in PATH. Uploaded files are flat copies, not the include hierarchy used by Main. console.jl, folder.jl, work implementations, runtime, and dependency configuration were not provided. Therefore no Julia integration run or live playlist fetch was performed.
A Python mirror extracted the regex from supplied parser.jl and reproduced its relevant host handling/matching rules for these simple cases. This tests the rule examples, not Julia execution:
Input	Parse	Resolve
Supplied YouTube playlist URL	Yes	youtube
not a url	No	N/A
https://youtube.com.evil.example/playlist?list=x	Yes	No match
https://www.youtube.com/	Yes	youtube; resource handling deferred
https://youtube.com:bad/	Yes in current regex	youtube; malformed port missed


Supplied URL: https://www.youtube.com/playlist?list=PLEeG8EVUQbZKpylHbpB-Etps7F_YneKiG
Expected parser fields: scheme=https; host=www.youtube.com; path=/playlist; query=list=PLEeG8EVUQbZKpylHbpB-Etps7F_YneKiG; raw=the trimmed URL.
The isolated playlistIdFromInput function was extracted from the attached TS, its two type annotations removed, and run under Node without importing youtubei.js or fetching data. It returned PLEeG8EVUQbZKpylHbpB-Etps7F_YneKiG for the supplied URL and rejected the YouTube homepage. This verifies local identifier extraction only, not playlist existence, access, or library behavior.
By static trace, in an otherwise correctly arranged project with an empty work registry, run_url_job obtains configuration then errors on playlist_index. It never reaches a TS invocation in the supplied consumer itself.
Work queue
- [x] Trace Main's use of the provided parser and resolver.
- [x] Identify manifest construction and field provenance.
- [x] Locate existing execution aggregation point.
- [x] Trace supplied URL and probe identifier extraction locally, with runtime limits recorded.
- [ ] Agree on service-card vocabulary: available_work_items, execution-context factory, and existing recognition/output fields.
- [ ] Add user selection between service resolution and manifest construction.
- [ ] Define empty selection, duplicates, ordering, and cancellation behavior.
- [ ] Freeze selected work to a tuple and canonicalize/validate label fields centrally.
- [ ] Decide whether job_id also denotes the run, or whether later retries need distinct run_id values. Current uuid4() already supplies a unique job identity.
- [ ] Add executor preflight for the whole selected list before any job call.
- [ ] Align backend filename and runtime configuration; define the Julia-to-TS invocation/result contract.
- [ ] Decide URL-only versus separate batch entry routes.
- [ ] Make startup registration explicit and free of job-execution side effects.
- [ ] Define registry collision behavior and card-match ambiguity policy.
- [ ] Later: define user goals versus prerequisite jobs and shared acquisition, avoiding redundant network requests.
- [ ] Later: resource acceptance rules, error/result statuses, output isolation, rate-limit handling, and any process isolation justified by a concrete threat model.
Proposed next probe
Use one temporary registered work function that performs no network request: it receives state, manifest, and execution context; returns an observation; and demonstrates that changing the manifest work sequence fails. Exercise selection -> freeze -> preflight -> invocation with one selected job, unregistered job, and empty selection. This is a structural probe, not a real music job. Implement only after the contract is understood.
Reference semantics
- Julia immutable objects may contain mutable fields: https://docs.julialang.org/en/v1/manual/types/
- Julia include evaluates source in the including module: https://docs.julialang.org/en/v1.12/manual/code-loading/
Change history
- 2026-10-05: Initial audit and running log created from eight supplied files and explicit user clarifications. No project source changes made.
