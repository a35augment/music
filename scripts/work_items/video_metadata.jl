function empty_video_record(entry)

    return (
        playlist_index = entry.index,
        video_id = entry.id,
        title = "",
        uploader = "",
        channel = "",
        artist = "",
        track = "",
        album = "",
        release_date = "",
        duration = ""
    )
end


function get_one_video_metadata(
    entry,
    manifest,
    service
)

    video_url =
        "https://www.youtube.com/watch?v=" *
        entry.id


    args = String[
        service.extractor,
        "--skip-download",
        "--no-warnings",
        "--print",
        "%(id)s\t%(title)s\t%(uploader)s\t%(channel)s\t%(artist)s\t%(track)s\t%(album)s\t%(release_date)s\t%(duration)s",
        video_url
    ]


    cmd = Cmd(args)


    println(
        "metadata: ",
        entry.index,
        " | ",
        entry.id
    )


    output = read(
        ignorestatus(cmd),
        String
    )


    line = strip(output)


    if isempty(line)

        println(
            "unavailable: ",
            entry.index,
            " | ",
            entry.id
        )

        return empty_video_record(
            entry
        )
    end


    parts = split(
        line,
        '\t';
        keepempty = true
    )


    while length(parts) < 9

        push!(
            parts,
            ""
        )
    end


    return (
        playlist_index = entry.index,
        video_id = strip(parts[1]),
        title = strip(parts[2]),
        uploader = strip(parts[3]),
        channel = strip(parts[4]),
        artist = strip(parts[5]),
        track = strip(parts[6]),
        album = strip(parts[7]),
        release_date = strip(parts[8]),
        duration = strip(parts[9])
    )
end


function video_metadata(
    entries,
    manifest,
    service
)

    println("video_metadata.jl")
    println("service: ", service.name)
    println("entries received: ", length(entries))
    println()


    worker_count = 4


    println(
        "channel metadata workers: ",
        worker_count
    )

    println()


    # ─────────────────────────────────────
    # JOB CHANNEL
    # ─────────────────────────────────────

    jobs = Channel{Tuple{Int, Any}}(
        length(entries)
    )


    # One guaranteed result slot
    # for every input entry.
    records = Vector{NamedTuple}(
        undef,
        length(entries)
    )


    # ─────────────────────────────────────
    # LOAD JOBS
    # ─────────────────────────────────────

    for (slot, entry) in enumerate(entries)

        put!(
            jobs,
            (
                slot,
                entry
            )
        )
    end


    close(
        jobs
    )


    # ─────────────────────────────────────
    # CHANNEL WORKERS
    # ─────────────────────────────────────

    @sync begin

        for worker_id in 1:worker_count

            @async begin

                for (slot, entry) in jobs

                    println(
                        "worker ",
                        worker_id,
                        " -> ",
                        entry.index
                    )


                    record = try

                        get_one_video_metadata(
                            entry,
                            manifest,
                            service
                        )

                    catch err

                        println(
                            "worker failure: ",
                            entry.index,
                            " | ",
                            entry.id,
                            " | ",
                            typeof(err)
                        )


                        empty_video_record(
                            entry
                        )
                    end


                    # Each job owns exactly one slot.
                    records[slot] = record


                    println(
                        "worker ",
                        worker_id,
                        " <- ",
                        entry.index,
                        " complete"
                    )
                end
            end
        end
    end


    println()

    println(
        "metadata records collected: ",
        length(records)
    )


    return records
end


register_url_work_item!(
    :video_metadata,
    video_metadata
)