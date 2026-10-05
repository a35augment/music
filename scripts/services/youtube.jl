# ============================================================
# YOUTUBE SERVICE
# Everything specific to YouTube belongs here.
# ============================================================


# ------------------------------------------------------------
# CALLABLE SERVICE
# ------------------------------------------------------------

function youtube_service(manifest)

    project_root = normpath(
        joinpath(
            @__DIR__,
            "..",
            "..",
            ".."
        )
    )


    return (
        name = :youtube,

        backend = :youtubejs,

        runtime = joinpath(
            project_root,
            "tools",
            "deno.exe"
        ),

        script = joinpath(
            project_root,
            "scripts",
            "backends",
            "youtube_music_backend.ts"
        )
    )
end


# ------------------------------------------------------------
# SERVICE DESCRIPTION
#
# The resolver reads this description.
# The resolver does not contain YouTube-specific rules.
# ------------------------------------------------------------

const YOUTUBE_SERVICE = (
    name = :youtube,

    hosts = (
        "youtube.com",
        "youtu.be"
    ),

    work_items = Symbol[
        :playlist_index,
        :video_metadata,
        :assemble_records
    ],

    output_kind = :raw,

    handler = youtube_service
)
