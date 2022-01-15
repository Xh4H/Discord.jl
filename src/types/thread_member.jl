"""
A thread member.
More details [here](https://discord.com/developers/docs/resources/channel#thread-member-object).
"""
struct ThreadMember
    id::Optional{Snowflake}
    user_id::Optional{Snowflake}
    join_timestamp::DateTime
    flags::Int
end
@boilerplate ThreadMember :constructors :docs :lower :merge :mock
