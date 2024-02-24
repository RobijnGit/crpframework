local MATRIX_AND = {{0, 0}, {0, 1}}
local MATRIX_OR = {{0, 1}, {1, 1}}
local HEXES = '0123456789abcdef'

local math_floor = math.floor
local math_random = math.random
local string_sub = string.sub
local to_number = tonumber
local assert = assert
local type = type

local function BITWISE(x, y, matrix)
    local z = 0
    local pow = 1
    while x > 0 or y > 0 do
        z = z + (matrix[x % 2 + 1][y % 2 + 1] * pow)
        pow = pow * 2
        x = math_floor(x / 2)
        y = math_floor(y / 2)
    end
    return z
end

local function INT2HEX(x)
    local s, base = '', 16
    local d
    while x > 0 do
        d = x % base + 1
        x = math_floor(x / base)
        s = string_sub(HEXES, d, d) .. s
    end
    while #s < 2 do
        s = "0" .. s
    end
    return s
end

function GenerateUUID(hwaddr)
    local bytes = {math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255), math_random(0, 255)}

    if hwaddr then
        assert(type(hwaddr) == "string", "Expected hex string, got " .. type(hwaddr))
        local i, str = #hwaddr, hwaddr
        hwaddr = ""
        while i > 0 and #hwaddr < 12 do
            local c = str:sub(i, i):lower()
            if HEXES:find(c, 1, true) then
                hwaddr = c .. hwaddr
            end
            i = i - 1
        end
        assert(#hwaddr == 12, "Provided string did not contain at least 12 hex characters, retrieved '" .. hwaddr .. "' from '" .. str .. "'")

        bytes[11] = to_number(hwaddr:sub(1, 2), 16)
        bytes[12] = to_number(hwaddr:sub(3, 4), 16)
        bytes[13] = to_number(hwaddr:sub(5, 6), 16)
        bytes[14] = to_number(hwaddr:sub(7, 8), 16)
        bytes[15] = to_number(hwaddr:sub(9, 10), 16)
        bytes[16] = to_number(hwaddr:sub(11, 12), 16)
    end

    bytes[7] = BITWISE(bytes[7], 0x0f, MATRIX_AND)
    bytes[7] = BITWISE(bytes[7], 0x40, MATRIX_OR)
    bytes[9] = BITWISE(bytes[9], 0x3f, MATRIX_AND)
    bytes[9] = BITWISE(bytes[9], 0x80, MATRIX_OR)
    return INT2HEX(bytes[1]) .. INT2HEX(bytes[2]) .. INT2HEX(bytes[3]) .. INT2HEX(bytes[4]) .. "-" .. INT2HEX(bytes[5]) .. INT2HEX(bytes[6]) .. "-" .. INT2HEX(bytes[7]) .. INT2HEX(bytes[8]) .. "-" .. INT2HEX(bytes[9]) .. INT2HEX(bytes[10]) .. "-" .. INT2HEX(bytes[11]) .. INT2HEX(bytes[12]) .. INT2HEX(bytes[13]) .. INT2HEX(bytes[14]) .. INT2HEX(bytes[15]) .. INT2HEX(bytes[16])
end