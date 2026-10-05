# ============================================================
# SERVICE INDEX
#
# This file is intentionally an index, not a dispatcher.
# It only loads the services the project provides and exposes
# them to resolver.jl.
# ============================================================


# ------------------------------------------------------------
# AVAILABLE SERVICES
# ------------------------------------------------------------

include(
    joinpath(
        @__DIR__,
        "..",
        "consumers",
        "services",
        "youtube.jl"
    )
)


# ------------------------------------------------------------
# URL SERVICE INDEX
#
# Add another service by:
#   1. adding its service file above
#   2. adding its service description below
#
# No execution routing belongs here.
# ------------------------------------------------------------

const URL_SERVICE_INDEX = (
    YOUTUBE_SERVICE,
)
