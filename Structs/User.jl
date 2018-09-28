module User

    mutable struct Self
        username::String
        id::String
        discriminator::String
        avatar::String
        bot::Bool
        mfa_enabled::Bool
        locale::String
        verified::Bool
        email::Any
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
