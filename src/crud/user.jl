function retrieve(::Type{User}, c::Client, user::Integer)
    return if me(c) !== nothing && me(c).id == user
        get_current_user(c)
    else
        get_user(c, user)
    end
end

update(c::Client; kwargs...) = modify_current_user(c; kwargs...)
