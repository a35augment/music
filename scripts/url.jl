# ─────────────────────────────────────────
# REGISTRIES
# ─────────────────────────────────────────

if !isdefined(@__MODULE__, :URL_SERVICES)
    const URL_SERVICES = Dict{Symbol, Function}()
end

if !isdefined(@__MODULE__, :URL_WORK_ITEMS)
    const URL_WORK_ITEMS = Dict{Symbol, Function}()
end


function register_url_service!(
    name::Symbol,
    fn::Function
)

    URL_SERVICES[name] = fn

    return nothing
end


function register_url_work_item!(
    name::Symbol,
    fn::Function
)

    URL_WORK_ITEMS[name] = fn

    return nothing
end


# ─────────────────────────────────────────
# LOAD SERVICES
# ─────────────────────────────────────────

services_dir = joinpath(
    @__DIR__,
    "services"
)

if isdir(services_dir)

    for filename in readdir(services_dir)

        if endswith(filename, ".jl")

            include(
                joinpath(
                    services_dir,
                    filename
                )
            )
        end
    end
end


# ─────────────────────────────────────────
# LOAD WORK ITEMS
# ─────────────────────────────────────────

work_items_dir = joinpath(
    @__DIR__,
    "work_items"
)

if isdir(work_items_dir)

    for filename in readdir(work_items_dir)

        if endswith(filename, ".jl")

            include(
                joinpath(
                    work_items_dir,
                    filename
                )
            )
        end
    end
end


# ─────────────────────────────────────────
# URL PIPELINE
# ─────────────────────────────────────────

function run_url_job(manifest)

    println()
    println("URL PIPELINE")
    println("════════════════════════════════════════")
    println()


    if !haskey(
        URL_SERVICES,
        manifest.source_kind
    )

        error(
            "No URL service registered for: " *
            string(manifest.source_kind)
        )
    end


    service_builder =
        URL_SERVICES[manifest.source_kind]

    service =
        service_builder(manifest)


    println("service:   ", service.name)
    println("extractor: ", service.extractor)
    println("output:    ", manifest.output_value)
    println()


    state = nothing


    for work_item in manifest.work_items

        if !haskey(
            URL_WORK_ITEMS,
            work_item
        )

            error(
                "No URL work item registered for: " *
                string(work_item)
            )
        end


        println(
            "RUNNING WORK ITEM: ",
            work_item
        )

        println(
            "────────────────────────────────────────"
        )


        work_function =
            URL_WORK_ITEMS[work_item]


        state = work_function(
            state,
            manifest,
            service
        )


        println()
    end


    return state
end
