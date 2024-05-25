-- local skynet = require "skynet"
-- local socket = require "skynet.socket"
-- local agent = {}


-- skynet.start(function()
--     skynet.error("Skynet server start")

--     -- 监听一个端口，等待一个连接
--     local socketid = socket.listen("0.0.0.0", 80)
--     skynet.error("Listen socket :", "0.0.0.0", 80)

--     -- 等待客户端连接
--     socket.start(socketid, function(fd, addr)
--         skynet.error(string.format("%s connected, pass it to agent :%08x", addr, skynet.self()))
--         agent[fd]= skynet.newservice("agent")
--         skynet.call(agent[fd], "lua", "start",{client = fd,addr = addr})
--     end)
-- end)

local skynet = require "skynet"
local socket = require "skynet.socket"

local client = {}

function bordcase(msg)
    for i = 1, #client do
        socket.write(client[i], msg)
    end
end

function connect(fd, addr)
  --start connect
  socket.start(fd)
  print("socket.start");
  table.insert(client,fd)

  --message
  while true do
    local readdata = socket.read(fd)
    --recv
    if readdata ~= nil then
      print(fd.." recv "..readdata)
      bordcase(readdata)
      
    --disconnect
    else
      print(fd.." close")
      socket.close(fd)
    end
  end
end

local count = 0
skynet.start(function()
  local listenfd = socket.listen("0.0.0.0", 80)
  socket.start(listenfd, connect)
  skynet.fork(function()
        while true do
            count = count + 1
            bordcase(count.."heart\n")
            skynet.sleep(100)
        end
    end)

end)
