using CSV
using DataFrames


function write_raw(
    records,
    manifest,
    service
)

    println("write_raw.jl")


    mkpath(
        manifest.output_value
    )


    filename_base = replace(
        manifest.source_name,
        r"[<>:\"/\\|?*]" => "_"
    )


    output_file = joinpath(
        manifest.output_value,
        filename_base * ".csv"
    )


    df = DataFrame(records)


    CSV.write(
        output_file,
        df
    )


    println(
        "records written: ",
        nrow(df)
    )

    println(
        "file written: ",
        output_file
    )


    return records
end


register_url_work_item!(
    :write_raw,
    write_raw
)

