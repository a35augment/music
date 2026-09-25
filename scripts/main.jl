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
        "service_registry.jl"
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
# INPUT DETECTION
# ============================================================

function is_url(value)

    cleaned_value = lowercase(
        strip(value)
    )

    return startswith(
        cleaned_value,
        "http://"
    ) ||
    startswith(
        cleaned_value,
        "https://"
    )
end


function is_filepath(value)

    cleaned_value = strip(value)

    return isfile(cleaned_value) ||
           isdir(cleaned_value)
end


function detect_job_type(value)

    if is_url(value)

        return :url

    elseif is_filepath(value)

        return :folder

    end

    return :unknown
end


# ============================================================
# URL MANIFEST
# ============================================================

function create_url_manifest(
    source_value,
    source_name
)

    # --------------------------------------------------------
    # RESOLVE SERVICE
    #
    # Ask the registered URL services which service owns
    # this URL.
    #
    # main.jl does not know about:
    #
    #   youtube.com
    #   spotify.com
    #   soundcloud.com
    #   deezer.com
    #
    # That knowledge belongs to each registered service.
    # --------------------------------------------------------

    service =
        resolve_url_service(
            source_value
        )


    if service === nothing

        return nothing
    end


    # --------------------------------------------------------
    # COMPLETE SHIPPING LABEL
    #
    # The service registration tells main which work items
    # belong on a normal manifest for this service.
    #
    # We COPY the list onto the manifest.
    #
    # url.jl will later execute this list.
    # url.jl does NOT change it.
    # --------------------------------------------------------

    work_items =
        copy(
            service.work_items
        )


    # --------------------------------------------------------
    # OUTPUT
    # --------------------------------------------------------

    output_kind =
        service.output_kind


    output_value =
        joinpath(
            PROJECT_ROOT,
            String(service.name),
            String(output_kind)
        )


    # --------------------------------------------------------
    # BUILD COMPLETE MANIFEST
    # --------------------------------------------------------

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

    # --------------------------------------------------------
    # IDENTIFY LOCAL SOURCE
    # --------------------------------------------------------

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


    # --------------------------------------------------------
    # FOLDER JOB
    #
    # A folder job is a top-level routing job.
    #
    # It does not decide URL service work items here.
    #
    # folder.jl will prepare individual URL inputs.
    # Each URL input will then receive its own complete
    # URL manifest through the normal initialization path.
    # --------------------------------------------------------

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
    source_name
)

    if job_type == :url

        return create_url_manifest(
            source_value,
            source_name
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
# TOP-LEVEL DISPATCH
# ============================================================

function dispatch_manifest(
    manifest
)

    if manifest.job_type == :url

        return run_url_job(
            manifest
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
    # DETECT TOP-LEVEL JOB TYPE
    # --------------------------------------------------------

    job_type =
        detect_job_type(
            source_value
        )


    if job_type == :unknown

        show_error(
            "Input was not recognized as a URL or existing file/folder path."
        )

        return nothing
    end


    # --------------------------------------------------------
    # HUMAN-READABLE NAME
    #
    # This only fills:
    #
    # SOURCE
    #   name: ...
    # --------------------------------------------------------

    source_name =
        prompt_source_name(
            job_type
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

    manifest =
        create_manifest(
            job_type,
            source_value,
            source_name
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
    # From this point forward the manifest is treated as
    # complete and immutable.
    # --------------------------------------------------------

    result =
        dispatch_manifest(
            manifest
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