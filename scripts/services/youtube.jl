function youtube_service(manifest)

    project_root = normpath(
        joinpath(
            @__DIR__,
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


register_url_service!(
    :youtube,
    youtube_service
)