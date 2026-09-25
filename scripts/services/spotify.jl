function spotify_service(manifest)

    return (
        name = :spotify,
        extractor = :spotify
    )
end


register_url_service!(
    :spotify,
    spotify_service
)

