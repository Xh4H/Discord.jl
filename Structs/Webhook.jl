module Webhook
    include("Structs.jl")
    export Self, serialize, construct

    mutable struct Self
        id::String
        guild_id::String
        channel_id::String
        user::Any # It can be nothing -> the user this webhook was created by (not returned when getting a webhook with its token)
        name::String
        avatar::String
        token::String
    end

    function construct(userData)
        return Structs.construct(userData, Self)
    end
end
