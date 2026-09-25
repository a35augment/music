function playlist_index(
    state,
    manifest,
    service
)

    println("playlist_index.jl")

    println("service:   ", service.name)
    println("extractor: ", service.extractor)
    println("source:    ", manifest.source_value)


    args = String[
        service.extractor
    ]

    append!(
        args,
        service.playlist_index_args
    )

    push!(
        args,
        manifest.source_value
    )


    cmd = Cmd(args)


    println()
    println("command arguments:")

    for arg in args
        println("  ", arg)
    end

    println()


    output = read(
        cmd,
        String
    )


    entries = NamedTuple[]


    for line in split(
        chomp(output),
        '\n'
    )

        line = strip(line)

        isempty(line) && continue


        parts = split(
            line,
            ",";
            limit = 2
        )


        length(parts) == 2 || continue


        index_value = tryparse(
            Int,
            strip(parts[1])
        )


        video_id = strip(
            parts[2]
        )


        index_value === nothing && continue
        isempty(video_id) && continue


        push!(
            entries,
            (
                index = index_value,
                id = video_id
            )
        )
    end


    println(
        "entries found: ",
        length(entries)
    )


    return entries
end


register_url_work_item!(
    :playlist_index,
    playlist_index
)

