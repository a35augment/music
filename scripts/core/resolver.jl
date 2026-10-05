# ============================================================
# SERVICE RESOLVER
# Resolve parsed URLs against the available service index.
# ============================================================


# ------------------------------------------------------------
# HOST MATCHING
# ------------------------------------------------------------

function host_matches_service(
    host,
    service_host
)

    normalized_host = lowercase(
        strip(host)
    )

    normalized_service_host = lowercase(
        strip(service_host)
    )


    return normalized_host == normalized_service_host ||
           endswith(
               normalized_host,
               "." * normalized_service_host
           )
end


# ------------------------------------------------------------
# URL SERVICE RESOLUTION
# ------------------------------------------------------------

function resolve_url_service(parsed_url)

    parsed_url === nothing && return nothing


    for service in URL_SERVICE_INDEX

        for service_host in service.hosts

            if host_matches_service(
                parsed_url.host,
                service_host
            )

                return service
            end
        end
    end


    return nothing
end


function resolve_url_service(url::AbstractString)

    return resolve_url_service(
        parse_url(url)
    )
end
