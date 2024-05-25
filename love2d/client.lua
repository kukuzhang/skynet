package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;examples/?.lua"

if _VERSION ~= "Lua 5.4" then
	error "Use lua 5.4"
end

local socket = require "client.socket"

local host = "127.0.0.1" -- Skynet服务器的IP地址，这里假设为本地
local port = 80 -- Skynet服务器监听的端口号

-- 创建一个TCP套接字
local client = assert(socket.connect(host, port))

-- 连接成功后发送消息
client:send("Hello, Skynet!\n")

-- 接收来自服务器的响应
local response, err = client:receive()
if response then
    print("Received from server: " .. response)
else
    print("Error receiving data: " .. err)
end

-- 关闭连接
client:close()