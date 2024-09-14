-- Emulator CPU 65C02

CPU = {}
CPU.__index = CPU

function CPU:new()
    local cpu = {
        memory = {}, 
        PC = 0x8000,  
        A = 0x00,     
        X = 0x00,     
        Y = 0x00,     
        SP = 0xFF,    
        P = 0x20,     
    }
    setmetatable(cpu, CPU)
    for i = 0, 0xFFFF do
        cpu.memory[i] = 0
    end
    return cpu
end

function CPU:reset()
    self.PC = self:read16(0xFFFC)
    self.SP = 0xFF
    self.A = 0x00
    self.X = 0x00
    self.Y = 0x00
    self.P = 0x20
end

function CPU:read8(addr)
    return self.memory[addr] or 0
end

function CPU:write8(addr, value)
    self.memory[addr] = value & 0xFF
end

function CPU:read16(addr)
    local low = self:read8(addr)
    local high = self:read8(addr + 1)
    return (high << 8) | low
end

function CPU:write16(addr, value)
    self:write8(addr, value & 0xFF)
    self:write8(addr + 1, (value >> 8) & 0xFF)
end

function CPU:load_program(program, start_address)
    for i = 1, #program do
        self.memory[start_address + i - 1] = program[i]
    end
    self.PC = start_address
end

function CPU:fetch()
    local opcode = self:read8(self.PC)
    self.PC = self.PC + 1
    return opcode
end

function CPU:execute()
    local opcode = self:fetch()

    if opcode == 0xA9 then  
        local value = self:fetch()
        self.A = value
        self:update_zero_and_negative_flags(self.A)

    elseif opcode == 0x85 then  
        local addr = self:fetch()
        self:write8(addr, self.A)

    elseif opcode == 0x86 then  
        local addr = self:fetch()
        self:write8(addr, self.X)

    elseif opcode == 0x84 then  
        local addr = self:fetch()
        self:write8(addr, self.Y)

    elseif opcode == 0xA2 then  
        local value = self:fetch()
        self.X = value
        self:update_zero_and_negative_flags(self.X)

    elseif opcode == 0xA0 then  
        local value = self:fetch()
        self.Y = value
        self:update_zero_and_negative_flags(self.Y)

    elseif opcode == 0x4C then  
        local addr = self:read16(self.PC)
        self.PC = addr

    elseif opcode == 0x6C then  
        local addr = self:read16(self.PC)
        self.PC = self:read16(addr)

    elseif opcode == 0xD0 then  
        local offset = self:fetch()
        if self.P & 0x02 ~= 0 then
            self.PC = self.PC + offset
        end

    elseif opcode == 0x10 then  
        local offset = self:fetch()
        if self.P & 0x80 ~= 0 then
            self.PC = self.PC + offset
        end

    elseif opcode == 0xE0 then  
        local value = self:fetch()
        if self.X ~= value then
            self.PC = self.PC + 1
        end

    elseif opcode == 0x00 then  
        print("Program ended")
        self:output_result()
        return false

    else
        print(string.format("Unknown opcode: %02X", opcode))
        return false
    end

    return true
end

function CPU:update_zero_and_negative_flags(value)
    if value == 0 then
        self.P = self.P | 0x02
    else
        self.P = self.P & 0xFD
    end

    if value & 0x80 ~= 0 then
        self.P = self.P | 0x80
    else
        self.P = self.P & 0x7F
    end
end

function CPU:run()
    while self:execute() do
        self:print_state()
    end
end

function CPU:print_state()
    print(string.format("PC: %04X, A: %02X, X: %02X, Y: %02X, P: %02X, SP: %02X", 
        self.PC, self.A, self.X, self.Y, self.P, self.SP))
    print(string.format("Memory[0x200]: %02X", self:read8(0x200)))
    print(string.format("Memory[0x400]: %02X", self:read8(0x400)))
end

function CPU:output_result()
    print("\n=== Text memory content (addresses $200 - $3FF) ===")
    for addr = 0x200, 0x7FF do
        local value = self:read8(addr)
        if value ~= 0 then
            io.write(string.char(value))
        else
            io.write(".")
        end
        if (addr - 0x200 + 1) % 32 == 0 then
            io.write("\n")
        end
    end

    print("\n=== Graphics memory content (addresses $800 - $1000) ===")
    for addr = 0x800, 0x1000 do
        local value = self:read8(addr)
        if value ~= 0 then
            io.write(string.format("%02X ", value))
        else
            io.write(".. ")
        end
        if (addr - 0x800 + 1) % 32 == 0 then
            io.write("\n")
        end
    end
end

function CPU:step_mode()
    print("Entering step mode...")
    while self:execute() do
        self:print_state()
        print("Press ENTER to execute next instruction or type 'quit' to stop:")
        local input = io.read()
        if input == 'quit' then break end
    end
end

function CPU:assembler_to_hex(asm_code)
    local opcodes = {
        LDA = 0xA9, STA = 0x85, STX = 0x86, STY = 0x84,
        LDX = 0xA2, LDY = 0xA0, JMP = 0x4C, JMPI = 0x6C,
        BEQ = 0xF0, BNE = 0xD0, BCC = 0x90, BCS = 0xB0,
        BMI = 0x30, BPL = 0x10, BVS = 0x70, BVC = 0x50,
        CMP = 0xC9, CPX = 0xE0, CPY = 0xC0,
        INX = 0xE8, INY = 0xC8, DEX = 0xCA, DEY = 0x88,
    }

    local program = {}
    for line in asm_code:gmatch("[^\r\n]+") do
        local instr, operand = line:match("(%S+)%s*(%S*)")
        if instr and opcodes[instr] then
            table.insert(program, opcodes[instr])
            if operand then
                if operand:match("^#") then
                    table.insert(program, tonumber(operand:sub(2), 16))
                elseif operand:match("^%$") then
                    table.insert(program, tonumber(operand:sub(2), 16))
                else
                    table.insert(program, tonumber(operand, 16))
                end
            end
        end
    end

    return program
end

local cpu = CPU:new()
cpu:reset()

print("Welcome to the 65C02 CPU emulator!")
print("Choose an option: ")
print("F - Load program from file")
print("H - Enter hex code manually")
print("A - Enter assembler code")

local choice = io.read()

if choice == 'F' then
    print("Enter the filename:")
    local filename = io.read()
    local file = io.open(filename, "rb")
    if file then
        local program = {}
        while true do
            local byte = file:read(1)
            if not byte then break end
            table.insert(program, string.byte(byte))
        end
        file:close()
        cpu:load_program(program, 0x8000)
        cpu:run()
    else
        print("Cannot open file.")
    end

elseif choice == 'H' then
    print("Enter hex code (press ENTER after each instruction, end with 'RUN'):")
    local program = {}
    while true do
        local line = io.read()
        if line == 'RUN' then break end
        for byte in line:gmatch("%S+") do
            table.insert(program, tonumber(byte, 16))
        end
    end
    cpu:load_program(program, 0x8000)
    cpu:run()

elseif choice == 'A' then
    print("Enter assembler code (press ENTER after each line, end with 'RUN'):")
    local asm_code = ""
    while true do
        local line = io.read()
        if line == 'RUN' then break end
        asm_code = asm_code .. line .. "\n"
    end
    local program = cpu:assembler_to_hex(asm_code)
    cpu:load_program(program, 0x8000)
    cpu:run()

else
    print("Invalid choice.")
end
