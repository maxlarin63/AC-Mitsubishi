-- Modbus TCP QuickApp for HC3
-- Created for Indome.ee / Kuuno
-- Polished and refactored for readability and maintainability

-- SETTINGS --
local ip   -- = "10.0.1.4"
local port -- = "4001"

-- Device init
function QuickApp:onInit()
   __TAG = "QA_MODBUS_AC_" .. plugin.mainDeviceId

	self:trace("✅ QuickApp initialized")
	self:updateView("lblRoomTemp", "text", "--")
	self:updateView("lblSetpointTemp", "text", "--")

	ip   = self:getVariable("device_ip")
	port = self:getVariable("device_port")

	if not ip or ip == "" then
		self:error("❌ Device IP is not set")
		ip =  "10.0.1.4"
	end

	if not port or port == "" then
		self:error("❌ Device Port is not set")
		port =  "4001"
	end
	self:trace("✅ Device IP: " .. ip .. " port: " .. port)


	-- Start periodic updates every 60 seconds
	self:startUpdateTimer()
end

function QuickApp:startUpdateTimer()
	local function loop()
		self:Update()
		setTimeout(loop, 60 * 1000) -- 60s
	end
	loop()
end

--------------------------------------------------------
-- 🔧 COMMON UTILITIES
--------------------------------------------------------

-- Converts string to hex representation
function QuickApp:hextostring(str, spacer)
	return (string.gsub(str, "(.)",
		function(c) return string.format("%02X%s", string.byte(c), spacer or " ") end))
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

-- Build Modbus request payload
function QuickApp:buildPayload(func, reg, value)
	local payload = string.char(0x01, func)
		.. string.char(math.floor(reg / 256), reg % 256)
		.. string.char(math.floor(value / 256), value % 256)
	return payload .. self:getCRC(payload)
end

-- Generic Modbus command sender
function QuickApp:sendModbusCommand(label, func, reg, value, callback)
	local sock = net.TCPSocket()
	local payload = self:buildPayload(func, reg, value)

	sock:connect(ip, tonumber(port), {
		success = function()
			self:debug("📡 Sending " .. label .. ": " .. self:hextostring(payload))
			sock:write(payload)

			sock:read({
				success = function(data)
					self:debug("📥 Received (" .. label .. "): " .. self:hextostring(data))
					sock:close()
					fibaro.sleep(1500)
					if callback then callback(data) end
					self:Update()
				end,
				error = function(message)
					self:error("❌ Read error: " .. message)
					sock:close()
				end
			})
		end,
		error = function(message)
			self:error("❌ Connection error: " .. message)
			sock:close()
		end
	})
end

--------------------------------------------------------
-- 🔘 BUTTON HANDLERS
--------------------------------------------------------

-- Fan speeds
function QuickApp:Quiet()       self:sendModbusCommand("Quiet",       0x06, 0x0002, 0x0002) end
function QuickApp:Weak()        self:sendModbusCommand("Weak",        0x06, 0x0002, 0x0003) end
function QuickApp:Strong()      self:sendModbusCommand("Strong",      0x06, 0x0002, 0x0005) end
function QuickApp:VeryStrong()  self:sendModbusCommand("VeryStrong",  0x06, 0x0002, 0x0006) end

-- Setpoints
function QuickApp:SetpointPlus()
	local current = self.currentSetpoint or 19.0
	local newValue = math.floor((current * 10) + 5)
	self:sendModbusCommand("Setpoint+", 0x06, 0x0001, newValue)
end

function QuickApp:SetpointMinus()
	local current = self.currentSetpoint or 19.0
	local newValue = math.floor((current * 10) - 5)
	self:sendModbusCommand("Setpoint-", 0x06, 0x0001, newValue)
end

-- Vane positions
function QuickApp:Position1()    self:sendModbusCommand("Position1",   0x06, 0x0003, 0x0001) end
function QuickApp:Position2()    self:sendModbusCommand("Position2",   0x06, 0x0003, 0x0002) end
function QuickApp:Position3()    self:sendModbusCommand("Position3",   0x06, 0x0003, 0x0003) end
function QuickApp:Position4()    self:sendModbusCommand("Position4",   0x06, 0x0003, 0x0004) end
function QuickApp:PositionAuto() self:sendModbusCommand("PositionAuto",0x06, 0x0003, 0x0007) end

-- Modes
function QuickApp:ModeAuto()     self:sendModbusCommand("ModeAuto",    0x06, 0x0000, 0x0008) end
function QuickApp:ModeHeat()     self:sendModbusCommand("ModeHeat",    0x06, 0x0000, 0x0001) end
function QuickApp:ModeDry()      self:sendModbusCommand("ModeDry",     0x06, 0x0000, 0x0002) end
function QuickApp:ModeFan()      self:sendModbusCommand("ModeFan",     0x06, 0x0000, 0x0007) end
function QuickApp:ModeCool()     self:sendModbusCommand("ModeCool",    0x06, 0x0000, 0x0003) end

-- Power
function QuickApp:ModePowerOn()  self:sendModbusCommand("PowerOn",     0x06, 0x0007, 0x0001) end
function QuickApp:ModePowerOff() self:sendModbusCommand("PowerOff",    0x06, 0x0007, 0x0000) end

--------------------------------------------------------
-- 🔄 UPDATE LOOP
--------------------------------------------------------

function QuickApp:Update()
	if self.isUpdating then
		self:debug("⏳ Update already in progress, marking pending.")
		self.pendingUpdateRequested = true
		return
	end

	self.isUpdating = true
	self.pendingUpdateRequested = false
	self:debug("🔄 Update triggered")

	local sock = net.TCPSocket()

	local function finish()
		if sock then
			pcall(function() sock:close() end)
			sock = nil
		end

		local shouldRestart = self.pendingUpdateRequested
		self.isUpdating = false
		self.pendingUpdateRequested = false

		if shouldRestart then
			self:debug("🔁 Running pending update.")
			self:Update()
		end
	end

	local commands = {
		{label="lblSetpointTemp", func=3, start=1, len=1},
		{label="lblRoomTemp",     func=4, start=0, len=1},
		{label="lblPowerList",    func=3, start=7, len=1, list={[1]="⚡ ON",[0]="⭕ OFF"}},
		{label="lblVaneList",     func=3, start=3, len=1, list={[0]="🔄 Auto",[1]="📍 Pos1",[2]="📍 Pos2",[3]="📍 Pos3",[4]="📍 Pos4",[5]="📍 Pos5",[7]="↔️ Swing"}},
		{label="lblSpeedList",    func=3, start=2, len=1, list={[0]="🔄 Auto",[2]="🤫 Quiet",[3]="💨 Weak",[5]="💨💨 Strong",[6]="💨💨💨 V.Strong"}},
		{label="lblModeList",     func=3, start=0, len=1, list={[1]="🔥 Heat",[2]="💧 Dry",[3]="❄️ Cool",[7]="🌀 Vent",[8]="🔄 Auto"}}
	}

	local function buildReadPayload(func, start, len)
		local payload = string.char(0x01, func)
			.. string.char(math.floor(start / 256), start % 256)
			.. string.char(math.floor(len / 256), len % 256)
		return payload .. self:getCRC(payload)
	end

	local function processNextCommand(index)
		if index > #commands then
			self:debug("✅ All update commands processed.")
			finish()
			return
		end

		local cmd = commands[index]
		local payload = buildReadPayload(cmd.func, cmd.start, cmd.len)

		self:debug("📡 Reading " .. cmd.label .. ": " .. self:hextostring(payload))
		sock:write(payload)

		sock:read({
			success = function(data)
				self:debug("📥 Got " .. cmd.label .. ": " .. self:hextostring(data))
				if #data >= 5 then
					local rawValue = data:byte(4)*256 + data:byte(5)
					local displayValue

					if cmd.label == "lblSetpointTemp" or cmd.label == "lblRoomTemp" then
						local emoji = (cmd.label == "lblSetpointTemp") and "🎯" or "🌡️"
						displayValue = string.format("%s %.1f °C", emoji, rawValue/10)
						if cmd.label == "lblSetpointTemp" then
							self.currentSetpoint = rawValue/10
							self:debug("💾 Stored setpoint: " .. tostring(self.currentSetpoint))
						end
					elseif cmd.list then
						displayValue = cmd.list[rawValue] or ("❓ ?" .. rawValue)
					else
						displayValue = tostring(rawValue)
					end

					self:updateView(cmd.label, "text", displayValue)
				else
					self:updateView(cmd.label, "text", "❌ ERR")
				end

				processNextCommand(index+1)
			end,
			error = function(msg)
				self:error("❌ Read error: " .. msg)
				finish()
			end
		})
	end

	sock:connect(ip, tonumber(port), {
		success = function()
			self:debug("✅ Connected for update.")
			processNextCommand(1)
		end,
		error = function(msg)
			self:error("❌ Connection error: " .. msg)
			finish()
		end
	})
end
