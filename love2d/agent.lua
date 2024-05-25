local skynet = require "skynet"
local socket = require "skynet.socket"

local client_fd

local CMD = {}

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

function CMD.start(conf)
    skynet.error("New client from " .. conf.client .. " with fd " .. conf.addr)
    client_fd = conf.client
    skynet.fork(function()
		while true do
			send_package("abcabc")
            skynet.error("send back to client sleep 500")
			skynet.sleep(500)
		end
	end)
end

skynet.start(function()
    skynet.dispatch("lua", function(session,source,cmd,...)
        local f = assert(CMD[cmd])
        skynet.ret(skynet.pack(f(...)))
    end)
end)

