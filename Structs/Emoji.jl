module Emoji
    include("Structs.jl")

    mutable struct Self
        id::String
        name::String
        roles::Array
        user::Any
        require_colons::Bool
        managed::Bool
        animated::Bool
    end

    function construct(EmojiData)
        return Structs.construct(userData, Self)
    end
end
