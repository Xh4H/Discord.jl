"""
A permission overwrite.
More details [here](https://discordapp.com/developers/docs/resources/channel#overwrite-object).
"""
@from_dict struct Overwrite
    id::Snowflake
    type::String
    allow::Int
    deny::Int
end
