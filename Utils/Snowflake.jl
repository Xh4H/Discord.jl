module Snowflake
    DISCORD_EPOCH = 1420070400000
    function getUnix(snowflake::String)
        snowflake = parse(Int64, snowflake)
        timestamp = Integer(snowflake >> 22) + DISCORD_EPOCH
        timestampString = repr(timestamp)

        return SubString(timestampString, 1, length(timestampString) - 3)
    end
end
