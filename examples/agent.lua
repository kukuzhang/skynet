local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd

function REQUEST:get()
	print("get", self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST:set()
	print("set", self.what, self.value)
	local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
end

function REQUEST:test()
--	print("test", self.key, self.val)
	 local r = skynet.call("SIMPLEDB", "lua", "get", self.key)
	 print("SIMPLEDB get", self.key, r)
end


function REQUEST:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	local r = f(args)
	if response then
		return response(r)
	end
end

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

skynet.register_protocol {
	name = "client",
	
    id = skynet.PTYPE_CLIENT,
	
    unpack = function (msg, sz)
		--local str = string.unpack(">s"..(#msg+1), msg)
        local str = skynet.tostring(msg, sz)
         print("Received unpack function msg:", str)
        return str
	end,

	dispatch = function (fd, _,  message,...)
		assert(fd == client_fd)	-- You can use fd to reply message
		skynet.ignoreret()	-- session is fd, don't call skynet.ret
		--skynet.trace()
        print("Received message:", message)
        
       local value = rawget(CMD, message)
        if value ~= nil then
            local f = CMD[message]
            send_package(f())
          else
            print("no CMD:"..message)
        end
       
		-- if type == "REQUEST" then
        --     print("Received message:", message)
		-- 	--local ok, result  = pcall(request, ...)
		-- 	 local f = CMD[message]
        --     if f then
        --         send_package(f)
		-- 		-- if result then
		-- 		-- 	send_package(result)
		-- 		-- end
		-- 	else
		-- 		skynet.error(result)
		-- 	end
		-- else
		-- 	assert(type == "RESPONSE")
		-- 	error "This example doesn't support request client"
		-- end
	end
}

function CMD.Ping()
    return "Pong"
end

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	skynet.fork(function()
		while true do
			send_package("abcabc")
			skynet.sleep(500)
		end
	end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		--skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
