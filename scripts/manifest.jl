using UUIDs


function build_manifest(;
    job_type,
    work_items,
    source_kind,
    source_value,
    source_name,
    output_kind,
    output_value
)

    return (
        job_id = uuid4(),

        job_type = job_type,
        work_items = work_items,

        source_kind = source_kind,
        source_value = source_value,
        source_name = source_name,

        output_kind = output_kind,
        output_value = output_value
    )
end


function show_manifest(manifest)

    println()
    println("JOB MANIFEST")
    println("════════════════════════════════════════")
    println()

    println("JOB")
    println("────────────────────────────────────────")
    println("job_id:     ", manifest.job_id)
    println("job_type:   ", manifest.job_type)
    println("work_items: ", manifest.work_items)

    println()
    println("SOURCE")
    println("────────────────────────────────────────")
    println("kind:       ", manifest.source_kind)
    println("value:      ", manifest.source_value)
    println("name:       ", manifest.source_name)

    println()
    println("OUTPUT")
    println("────────────────────────────────────────")
    println("kind:       ", manifest.output_kind)
    println("value:      ", manifest.output_value)

    println()
    println("════════════════════════════════════════")
end

