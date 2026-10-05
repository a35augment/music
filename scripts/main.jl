# ============================================================
# MUSIC IMPORTER
# Main orchestration / initialization layer
# ============================================================


# ------------------------------------------------------------
# COMPONENTS
# ------------------------------------------------------------

include(
    joinpath(
        @__DIR__,
        "core",
        "manifest.jl"
    )
)

include(
    joinpath(
        @__DIR__,
        "core",
        "parser.jl"
    )
)

include(
    joinpath(
        @__DIR__,
        "core",
        "service_registry.jl"
    )
)

include(
    joinpath(
        @__DIR__,
        "core",
        "resolver.jl"
    )
)

include(
    joinpath(
        @__DIR__,
        "interface",
        "console.jl"
    )
)

include(
    joinpath(
        @__DIR__,
        "consumers",
        "url.jl"
    )
)

include(
    joinpath(
        @__DIR__,
        "consumers",
        "folder.jl"
    )
)


# ------------------------------------------------------------
# PROJECT
# ------------------------------------------------------------

const PROJECT_ROOT = normpath(
    joinpath(
        @__DIR__,
        ".."
    )
)


# ============================================================
# URL MANIFEST
# ============================================================

function create_url_manifest(
    source_value,
    source_name,
    service
)

    # --------------------------------------------------------
    # COMPLETE SHIPPING LABEL
    #
    # Service-specific manifest defaults come from the
    # resolved service description.
    # --------------------------------------------------------

    work_items = copy(
        service.work_items
    )


    output_kind =
        service.output_kind


    output_value = joinpath(
        PROJECT_ROOT,
        String(service.name),
        String(output_kind)
    )


    return build_manifest(

        job_type = :url,

        work_items = work_items,

        source_kind = service.name,
        source_value = source_value,
        source_name = source_name,

        output_kind = output_kind,
        output_value = output_value
    )
end


# ============================================================
# FOLDER / BATCH MANIFEST
# ============================================================

function create_folder_manifest(
    source_value,
    source_name
)

    source_kind =

        if isdir(source_value)

            :directory

        elseif isfile(source_value)

            :file

        else

            :unknown

        end


    if source_kind == :unknown
        return nothing
    end


    # A folder job does not resolve URL services here.
    # folder.jl can feed every discovered URL back through
    # parse_url(...) + resolve_url_service(...), giving each
    # URL its own normal URL manifest.

    return build_manifest(

        job_type = :folder,

        work_items = Symbol[],

        source_kind = source_kind,
        source_value = source_value,
        source_name = source_name,

        output_kind = :none,
        output_value = ""
    )
end


# ============================================================
# MANIFEST CREATION
# ============================================================

function create_manifest(
    job_type,
    source_value,
    source_name;
    service = nothing
)

    if job_type == :url

        service === nothing && return nothing


        return create_url_manifest(
            source_value,
            source_name,
            service
        )


    elseif job_type == :folder

        return create_folder_manifest(
            source_value,
            source_name
        )
    end


    return nothing
end


# ============================================================
# TOP-LEVEL JOB DISPATCH
#
# This dispatches job TYPES only.
# It does not dispatch URL services.
# ============================================================

function dispatch_manifest(
    manifest;
    service = nothing
)

    if manifest.job_type == :url

        service === nothing && error(
            "URL job has no resolved service."
        )


        return run_url_job(
            manifest,
            service
        )


    elseif manifest.job_type == :folder

        return run_folder_job(
            manifest
        )
    end


    error(
        "Unsupported job type: $(manifest.job_type)"
    )
end


# ============================================================
# MAIN
# ============================================================

function main()

    # --------------------------------------------------------
    # INTERFACE
    # --------------------------------------------------------

    show_start()


    source_value =
        prompt_source()


    if isempty(
        strip(source_value)
    )

        show_error(
            "No input entered."
        )

        return nothing
    end


    # --------------------------------------------------------
    # PARSE INPUT
    # --------------------------------------------------------

    parsed_input = parse_input(
        source_value
    )


    if parsed_input.job_type == :unknown

        show_error(
            "Input was not recognized as a URL or existing file/folder path."
        )

        return nothing
    end


    # --------------------------------------------------------
    # RESOLVE URL SERVICE
    #
    # main.jl knows only that URL jobs require a service.
    # It does not know any YouTube/Spotify/etc. host rules.
    # --------------------------------------------------------

    service = nothing


    if parsed_input.job_type == :url

        service = resolve_url_service(
            parsed_input.url
        )


        if service === nothing

            show_error(
                "No supported service owns URL host: $(parsed_input.url.host)"
            )

            return nothing
        end
    end


    # --------------------------------------------------------
    # HUMAN-READABLE NAME
    # --------------------------------------------------------

    source_name =
        prompt_source_name(
            parsed_input.job_type
        )


    if isempty(
        strip(source_name)
    )

        show_error(
            "Source name cannot be empty."
        )

        return nothing
    end


    # --------------------------------------------------------
    # CREATE COMPLETE SHIPPING LABEL
    # --------------------------------------------------------

    manifest = create_manifest(
        parsed_input.job_type,
        parsed_input.source_value,
        source_name;
        service = service
    )


    if manifest === nothing

        show_error(
            "A manifest could not be created for this source."
        )

        return nothing
    end


    # --------------------------------------------------------
    # DISPLAY COMPLETED SHIPPING LABEL
    # --------------------------------------------------------

    show_manifest(
        manifest
    )


    # --------------------------------------------------------
    # SHIP
    #
    # The URL service was resolved once, above.
    # The resolved callable is passed forward directly.
    # --------------------------------------------------------

    result = dispatch_manifest(
        manifest;
        service = service
    )


    # --------------------------------------------------------
    # END
    # --------------------------------------------------------

    show_end()


    return result
end


# ============================================================
# START
# ============================================================

main()
