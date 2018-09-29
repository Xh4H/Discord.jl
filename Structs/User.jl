module User
    export Self, serialize, construct

    mutable struct Self
        username::String
        id::String
        discriminator::String
        avatar::String
        bot::Bool
    end

    # Returns a Dictionary of the supplied User
    function _serialize(user)
        serialized = Dict()
        for i in fieldnames(Self)
            value = getfield(user, i)
            serialized[i] = value
        end
        return serialized
    end

    function construct(userData)
        wantedFields = fieldnames(Self)
        data  = []

        for i in wantedFields
            field = i |> String
            push!(data, userData[field])
        end
        user = Self(data...)
        return _serialize(user)
    end
end
