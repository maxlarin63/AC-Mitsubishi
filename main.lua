-- Modbus TCP QuickApp for HC3
-- Created for Indome.ee / Kuuno

-- SETTINGS --
local ip = "192.168.1.12"
local port = 4001

-- Device init
function QuickApp:onInit()
  self:debug("✅ QuickApp initialized")
  self:updateView("lblRoomTemp", "text", "--")
  self:updateView("lblSetpointTemp", "text", "--")
  
  -- Start periodic updates every 60 seconds
  self:startUpdateTimer()
end

function QuickApp:startUpdateTimer()
  local function loop()
	self:Update()
	setTimeout(loop, 60 * 1000)  -- 60 seconds
  end

  loop()  -- Start the first run
end

-- Quiet button ------------------

function QuickApp:Quiet()
  self:debug("🔕 'Quiet' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x02, 0x00, 0x02)
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		  
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
--Quiet button end ----------------


-- Weak button ---------------------

function QuickApp:Weak()
  self:debug("💨 'Weak' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  -- Modbus function 6 (Write Single Register) to register 3, value 3
	  local payload = string.char(0x01, 0x06, 0x00, 0x02, 0x00, 0x03)
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		  
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end

-- Weak button end ------------------


--Strong -----------------------------

function QuickApp:Strong()
  self:debug("💨 'Strong' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x02, 0x00, 0x05) -- Strong = value 5
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
--Strong button end -----------------

-- Very strong ---------------
function QuickApp:VeryStrong()
  self:debug("💨 'Very Strong' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  -- Build Modbus payload
	  local payload = string.char(0x01, 0x06, 0x00, 0x02, 0x00, 0x06) -- Write 6 to register 3
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
-- Very strong end ---------------------

-- Setpoint + -----

function QuickApp:SetpointPlus()
  self:debug("➕ 'Setpoint+' button pressed")

  local current = self.currentSetpoint or 19.0
  local newValue = math.floor((current * 10) + 5)

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x01, math.floor(newValue / 256), newValue % 256)
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
-- Setpoint + end --------

-- Setpoint - -----

function QuickApp:SetpointMinus()
  self:debug("➖ 'Setpoint-' button pressed")

  local current = self.currentSetpoint or 19.0
  local newValue = math.floor((current * 10) - 5)

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x01, math.floor(newValue / 256), newValue % 256)
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end

-- Setpoint - end --------

-- Position1 -----

function QuickApp:Position1()
  self:debug("🔁 'Position 1' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x03, 0x00, 0x01) -- func=6, start=4, value=1
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end

--Position 1 end ---

-- Position2 -----

function QuickApp:Position2()
  self:debug("🔁 'Position 2' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x03, 0x00, 0x02) -- func=6, start=4, value=2
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end

--Position 2 end ---

-- Position3 -----

function QuickApp:Position3()
  self:debug("🔁 'Position 3' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x03, 0x00, 0x03) -- func=6, start=4, value=3
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end

--Position 3 end ---

-- Position4 -----

function QuickApp:Position4()
  self:debug("🔁 'Position 4' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x03, 0x00, 0x04) -- func=6, start=4, value=4
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end

--Position 4 end ---

-- Position Auto -----

function QuickApp:PositionAuto()
  self:debug("🔁 'Position Auto' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)
	  local payload = string.char(0x01, 0x06, 0x00, 0x03, 0x00, 0x07) -- func=6, start=4, value=7
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end

--Position Auto end ---

-- Mode Auto ---------------
function QuickApp:ModeAuto()
  self:debug("🅰️ 'Auto' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x00, 0x00, 0x08)
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
--Mode Auto end ---------------

--Mode Heat -----------
function QuickApp:ModeHeat()
  self:debug("🔥 'ModeHeat' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x00, 0x00, 0x01)
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
-- Mode Heat ------

--Mode Dry
function QuickApp:ModeDry()
  self:debug("💧 'ModeDry' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x00, 0x00, 0x02)
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
--Mode Dry end

--ModeFan
function QuickApp:ModeFan()
  self:debug("🌀 'ModeFan' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x00, 0x00, 0x07) -- Write 7 to register 1
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
--ModeFan end

--Mode Cool
function QuickApp:ModeCool()
  self:debug("❄️ 'ModeCool' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x00, 0x00, 0x03) -- Write 3 to register 1
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
-- Mode Cool end

--Mode Power ON
function QuickApp:ModePowerOn()
  self:debug("🔌 'ModePowerOn' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x07, 0x00, 0x01) -- Write 1 to register 8
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
-- Mode Powwr On end

--Mode Power Off

function QuickApp:ModePowerOff()
  self:debug("⛔ 'ModePowerOff' button pressed")

  local sock = net.TCPSocket()
  local ip = self.ip or "192.168.1.12"
  local port = self.port or 4001

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)

	  local payload = string.char(0x01, 0x06, 0x00, 0x07, 0x00, 0x00) -- Write 0 to register 8
	  local crc = self:getCRC(payload)
	  local packet = payload .. crc

	  self:debug("📤 Sending raw: " .. tostring(packet))
	  self:debug("📤 Sending hex: " .. self:hextostring(packet))

	  sock:write(packet)

	  sock:read({
		success = function(data)
		  self:debug("📥 Received raw: " .. tostring(data))
		  self:debug("📥 Received hex: " .. self:hextostring(data))
		  sock:close()
		  fibaro.sleep(1500)
		  self:Update()
		end,
		error = function(message)
		  self:debug("⚠️ Read error: " .. message)
		  sock:close()
		end
	  })
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	  sock:close()
	end
  })
end
--Mode Power Off end





-- Converts string to hex representation
function QuickApp:hextostring(str, spacer)
  return (
	string.gsub(str, "(.)",
	  function (c)
		return string.format("%02X%s", string.byte(c), spacer or " ")
	  end)
  )
end

-- CRC16 calculator (Modbus RTU)
function QuickApp:getCRC(data)
  local crc = 0xFFFF
  for i = 1, #data do
	crc = bit32.bxor(crc, data:byte(i))
	for _ = 1, 8 do
	  if crc % 2 == 1 then
		crc = bit32.rshift(crc, 1)
		crc = bit32.bxor(crc, 0xA001)
	  else
		crc = bit32.rshift(crc, 1)
	  end
	end
  end
  return string.char(crc % 256, math.floor(crc / 256))
end

-- Decode Modbus response for 1 register (2 bytes)
function QuickApp:parseValue(data)
  local len = string.len(data)
  if len >= 7 then
	local byte1 = string.byte(data, 4)
	local byte2 = string.byte(data, 5)
	return byte1 * 256 + byte2  -- ✅ This is a number
  else
	return nil
  end
end

-- Build Modbus request payload
function QuickApp:buildPayload(func, start, len)
  local payload = string.char(0x01, func)
	  .. string.char(math.floor(start / 256), start % 256)
	  .. string.char(math.floor(len / 256), len % 256)
  local crc = self:getCRC(payload)
  return payload .. crc
end

-- Update button
function QuickApp:Update()
  self:debug("🔁 'Update' button pressed")

  local sock = net.TCPSocket()

  local commands = {
	{label = "lblSetpointTemp", func = 3, start = 1, len = 1},
	{label = "lblRoomTemp", func = 4, start = 0, len = 1},
	{label = "lblPowerList", func = 3, start = 7, len = 1, list = {[1] = "ON", [0] = "OFF"}},
	{label = "lblVaneList", func = 3, start = 3, len = 1, list = {
	  [0] = "Auto", [1] = "Pos 1", [2] = "Pos 2",
	  [3] = "Pos 3", [4] = "Pos 4", [5] = "Pos 5", [7] = "Swing"
	}},
	{label = "lblSpeedList", func = 3, start = 2, len = 1, list = {
	  [0] = "Auto", [2] = "Quiet", [3] = "Weak",
	  [5] = "Strong", [6] = "V. Strong"
	}},
	{label = "lblModeList", func = 3, start = 0, len = 1, list = {
	  [1] = "Heat", [2] = "De-Hum", [3] = "Cool",
	  [7] = "Vent", [8] = "Auto"
	}}
  }

  local function buildPayload(func, start, len)
	local payload = string.char(0x01, func)
		.. string.char(math.floor(start / 256), start % 256)
		.. string.char(math.floor(len / 256), len % 256)
	local crc = self:getCRC(payload)
	return payload .. crc
  end

  local function parseValue(data, list)
	if #data >= 5 then
	  local byte1 = data:byte(4)
	  local byte2 = data:byte(5)
	  local value = byte1 * 256 + byte2
	  if list then
		return list[value] or ("?" .. tostring(value))
	  else
		return value
	  end
	else
	  return "ERR"
	end
  end

  local function processNextCommand(index)
	if index > #commands then
	  sock:close()
	  self:debug("✅ All commands processed.")
	  return
	end

	local cmd = commands[index]
	local payload = buildPayload(cmd.func, cmd.start, cmd.len)

	self:debug("📤 Sending raw to " .. cmd.label .. ": " .. tostring(payload))
	self:debug("📤 Sending hex to " .. cmd.label .. ": " .. self:hextostring(payload))

	sock:write(payload)

	sock:read({
	  success = function(data)
  self:debug("📥 Received raw from " .. cmd.label .. ": " .. tostring(data))
  self:debug("📥 Received hex from " .. cmd.label .. ": " .. self:hextostring(data))

  local byte3, byte4 = data:byte(4), data:byte(5)
  if byte3 and byte4 then
	local rawValue = byte3 * 256 + byte4
	local displayValue

	if cmd.label == "lblSetpointTemp" or cmd.label == "lblRoomTemp" then
	  displayValue = string.format("%.1f °C", rawValue / 10)

	  if cmd.label == "lblSetpointTemp" then
		self.currentSetpoint = rawValue / 10
		self:debug("📡 Stored current setpoint: " .. tostring(self.currentSetpoint))
	  end

	elseif cmd.list then
	  displayValue = cmd.list[rawValue] or ("?" .. tostring(rawValue))
	else
	  displayValue = tostring(rawValue)
	end

	self:debug("📊 " .. cmd.label .. " = " .. displayValue)
	self:updateView(cmd.label, "text", displayValue)
  else
	self:debug("⚠️ Incomplete data received from " .. cmd.label)
	self:updateView(cmd.label, "text", "ERR")
  end

  processNextCommand(index + 1)
end
	})
  end

  sock:connect(ip, port, {
	success = function()
	  self:debug("✅ Connected to " .. ip .. ":" .. port)
	  processNextCommand(1)
	end,
	error = function(message)
	  self:debug("❌ Connection error: " .. message)
	end
  })
end
