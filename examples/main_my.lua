local skynet = require "skynet"

local function handle_client(socket)
    skynet.error("New client connected")
    while true do
        local message, size = socket:read()
        if message then
            skynet.error("Received: " .. message)
            -- 发送pong响应
            socket:write("pong")
        else
            -- 如果没有接收到消息，客户端可能已经断开连接
            skynet.error("Client disconnected")
            break
        end
    end
end

skynet.start(function()
    -- 创建socket
    local socket = skynet.socket()
    
    -- 绑定到0.0.0.0的80端口
    socket:bind("0.0.0.0", 80)
    -- 开始监听连接
    socket:listen(8) -- 监听队列大小

    skynet.error("Listen on 80 port")

    -- 接受连接
    while true do
        local client = socket:accept()
        if client then
            -- 为每个连接创建一个新的协程来处理
            skynet.fork(handle_client, client)
        end
    end
end)