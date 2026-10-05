# ============================================================
# INPUT PARSER
# Parse user input into a stable structure for main/resolver.
# ============================================================


# ------------------------------------------------------------
# URL PARSING
# ------------------------------------------------------------

function parse_url(value)

    cleaned_value = strip(value)


    url_match = match(
        r"^(https?)://([^/?#]+)([^?#]*)(?:\?([^#]*))?(?:#.*)?$"i,
        cleaned_value
    )


    if url_match === nothing
        return nothing
    end


    scheme = lowercase(
        url_match.captures[1]
    )


    authority = lowercase(
        url_match.captures[2]
    )


    # Remove optional user-info before the host.
    host_port = split(
        authority,
        '@';
        limit = 2
    )[end]


    # URL services in this project are domain based.
    # Strip a normal :port suffix while leaving bracketed IPv6 alone.
    host =
        if startswith(host_port, "[")
            host_port
        else
            split(
                host_port,
                ':';
                limit = 2
            )[1]
        end


    path = something(
        url_match.captures[3],
        ""
    )


    query = something(
        url_match.captures[4],
        ""
    )


    return (
        scheme = scheme,
        host = host,
        path = path,
        query = query,
        raw = cleaned_value
    )
end


# ------------------------------------------------------------
# INPUT TYPE DETECTION
# ------------------------------------------------------------

function is_url(value)

    return parse_url(value) !== nothing
end


function is_filepath(value)

    cleaned_value = strip(value)

    return isfile(cleaned_value) ||
           isdir(cleaned_value)
end


function parse_input(value)

    cleaned_value = strip(value)


    parsed_url = parse_url(
        cleaned_value
    )


    if parsed_url !== nothing

        return (
            job_type = :url,
            source_value = cleaned_value,
            url = parsed_url
        )
    end


    if is_filepath(cleaned_value)

        return (
            job_type = :folder,
            source_value = cleaned_value,
            url = nothing
        )
    end


    return (
        job_type = :unknown,
        source_value = cleaned_value,
        url = nothing
    )
end


function detect_job_type(value)

    return parse_input(value).job_type
end
