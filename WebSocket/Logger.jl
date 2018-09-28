module WSLogger

    using Base
    import Dates

    function log(str::String, logType::String)
        now = Dates.Time(Dates.now())
        logType = uppercasefirst(logType)
        println("[JuliCord] [$logType] [$now] - $str") # [JuliCord] [Log] [12:25:01.604] - test
    end

end
