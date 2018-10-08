@from_dict struct Ban
    reason::Union{String, Missing}
    user::User
end
