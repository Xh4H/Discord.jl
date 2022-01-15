"""
Metadata from a thread.
More details [here](https://discord.com/developers/docs/resources/channel#thread-metadata-object).
"""
struct ThreadMetadata
    archived::Bool
    auto_archive_duration::Int
    archive_timestamp::DateTime
    locked::Bool
    invitable::Optional{Bool}
end
@boilerplate ThreadMetadata :constructors :docs :lower :merge :mock
