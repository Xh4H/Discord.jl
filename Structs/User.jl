module User
    export Self, serialize
    mutable struct Self
        username::String
        id::String
        discriminator::String
        avatar::String
        bot::Bool
    end

    # Returns a Dictionary of the supplied User
    function serialize(user)
        serialized = Dict()
        for i in fieldnames(Self)
            value = getfield(user, i)
            serialized[i] = value
        end
        return serialized
    end
end
