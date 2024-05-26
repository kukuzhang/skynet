-- love.load() 在游戏开始时调用一次，用于初始化
function love.load()
    socket = require("socket")
    local coroutine = require("coroutine")
    host = "8.134.75.23" -- 替换为你想要连接的服务器的域名
    port = 80 -- 替换为服务器监听的端口号
    client = nil
  
    if client == nil then
        client = socket.try( socket.connect(host, port) )
        client:settimeout(0)

        if client then
            print("Connected to server.")
            -- 发送数据到服务器
            client:send("Hello, server!")
        else
            print("Failed to connect to server.")
        end
    end
   

    local co = coroutine.create(function()
        local count = 0
        while true do
            lastMessage = "coroutine fresh 1!"
            count = count + 1
            local body, err = client:receive("*a") -- 读取全部响应
            lastMessage = "client:receive 1!"
            --lastMessage = body
            if body then
                -- 处理从服务器接收到的消息
                love.receivemessages(body, err,count)
            end
            delay(1)
        end

    end)

    coroutine.resume(co)
end

local function delay(seconds)
    local startTime = os.clock() -- 获取当前时间（CPU时间，以秒为单位）
    while true do
        coroutine.yield()
        local currentTime = os.clock()
        if currentTime - startTime >= seconds then
            break
        end
    end
end

-- love.update(dt) 每帧调用一次，用于更新游戏状态
function love.update(dt)
  

end

-- love.draw() 每帧调用一次，用于绘制
function love.draw()
    -- 清除屏幕
    love.graphics.clear(love.graphics.getBackgroundColor())

    -- 设置文本颜色和字体
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(love.graphics.newFont(14))

    -- 打印连接状态到屏幕
    if client then
        love.graphics.print("Connected to server.", 10, 10)
    else
        love.graphics.print("Not connected to server.", 10, 10)
    end

    -- 如果有来自服务器的消息，打印出来
    if lastMessage then
        love.graphics.print(lastMessage, 10, 30)
    end
end

function love.keypressed(key, scancode, isrepeat)
    -- 按键按下时，记录按键
    client:send("Key pressed: " .. key.."\n")
end

-- 处理从服务器接收到的消息
function love.receivemessages(message, data,count)
    lastMessage = message..data.." count:"..count
end


-- love.close() 在游戏关闭时调用，用于清理资源
function love.close()
    if client then
        client:close()
    end
end