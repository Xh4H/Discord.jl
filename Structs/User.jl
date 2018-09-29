module User
    include("Structs.jl")
    export Self, serialize, construct

    mutable struct Self
        username::String
        id::String
        discriminator::String
        avatar::String
        bot::Bool
    end

    function construct(data)
        return Structs.construct(data, Self)
    end
end
