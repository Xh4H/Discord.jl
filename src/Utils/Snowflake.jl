module Snowflake
    DISCORD_EPOCH = 1420070400000
    
    function getUnix(snowflake::String)
        snowflakeNumber = parse(Int64, snowflake)

        return Int(round(((snowflakeNumber >> 22) + DISCORD_EPOCH)/ 1000))
    end
end
