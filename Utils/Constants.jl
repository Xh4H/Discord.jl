module Constants
    export WebSocketDetails, OPCodes

    # WebSocket
    gatewayVersion = "6"
    WebSocketDetails = Dict(
                            "url" => "wss://gateway.discord.gg",
                            "path" => "/?v=$gatewayVersion&encoding=json"
                        )

    heartbeatPayload = Dict(
                            "op" => 1,
                            "d" => nothing
                       )
   identifyDict(token::String) = Dict(
       "op" => 2,
       "d" => Dict(
           "token" => token,
           "properties" => Dict(
               "\$os" => "Julicord",
               "\$browser" => "Julicord",
               "\$device" => "Julicord"
           ),
           "presence" => Dict(
               "game" => Dict(
                   "name" => nothing,
                   "type" => 0
               ),
               "status" => "online"
           )
       )
   )

    OPCodes = Dict(
                0=> "DISPATCH",
                1=> "HEARBEAT",
                2=> "IDENTIFY",
                3=> "PRESENCE",
                4=> "VOICE_STATE",
                5=> "VOICE_PING",
                6=> "RESUME",
                7=> "RECONNECT",
                8=> "REQUEST_MEMBERS",
                9=> "INVALIDATE_SESSION",
                10=> "HELLO",
                11=> "HEARTBEAT_ACK",
                12=> "GUILD_SYNC",
            )
end
