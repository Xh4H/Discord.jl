module Structs
    function construct(what, intoWhat)
        wantedFields = fieldnames(intoWhat)
        data  = []

        for i in wantedFields
            field = i |> String
            push!(data, what[field])
        end

        result = intoWhat(data...)
        serialized = Dict()
        
        for i in fieldnames(intoWhat)
            serialized[i] = getfield(result, i)
        end

        return serialized
    end
end
