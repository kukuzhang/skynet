-- client.lua
local skynet = require "skynet"

skynet.start(function()
    -- 连接到名为"ping"的服务
    local ping = skynet.localname.resolve("乒") -- 注意：这里的"乒"是服务名，需要与注册的服务名匹配
    
    -- 发送ping消息给ping服务
    skynet.call(ping, "lua", "ping")
    
    -- 等待并接收pong响应
    local response = skynet.call(ping, "lua", "ping")
    print("Received:", response)
end)