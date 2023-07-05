function folder(thisFileName)
    local str = debug.getinfo(2, 'S').source:sub(2)
    return (str:match('^.*/(.*).lua$') or str):sub(1, -(thisFileName):len() - 1)
end

dofile(folder('tasinput.lua') .. 'mupen-lua-ugui/mupen-lua-ugui.lua')


Mupen_lua_ugui.spinner = function(control)
    local width = 15
    local value = control.value

    value = math.min(value, control.maximum)
    value = math.max(value, control.minimum)

    local new_text = Mupen_lua_ugui.textbox({
        uid = control.uid,
        is_enabled = true,
        rectangle = {
            x = control.rectangle.x,
            y = control.rectangle.y,
            width = control.rectangle.width - width * 2,
            height = control.rectangle.height,
        },
        text = tostring(value),
    })

    if tonumber(new_text) then
        value = tonumber(new_text)
    end

    if control.is_horizontal then
        if (Mupen_lua_ugui.button({
                uid = control.uid + 1,
                is_enabled = value > control.minimum,
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width - width * 2,
                    y = control.rectangle.y,
                    width = width,
                    height = control.rectangle.height,
                },
                text = "-",
            }))
        then
            value = value - 1
        end

        if (Mupen_lua_ugui.button({
                uid = control.uid + 1,
                is_enabled = value < control.maximum,
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width - width,
                    y = control.rectangle.y,
                    width = width,
                    height = control.rectangle.height,
                },
                text = "+",
            }))
        then
            value = value + 1
        end
    else
        if (Mupen_lua_ugui.button({
                uid = control.uid + 1,
                is_enabled = value < control.maximum,
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width - width * 2,
                    y = control.rectangle.y,
                    width = width * 2,
                    height = control.rectangle.height / 2,
                },
                text = "+",
            }))
        then
            value = value + 1
        end

        if (Mupen_lua_ugui.button({
                uid = control.uid + 1,
                is_enabled = value > control.minimum,
                rectangle = {
                    x = control.rectangle.x + control.rectangle.width - width * 2,
                    y = control.rectangle.y + control.rectangle.height / 2,
                    width = width * 2,
                    height = control.rectangle.height / 2,
                },
                text = "-",
            }))
        then
            value = value - 1
        end
    end

    return value
end


local function remap(value, from1, to1, from2, to2)
    return (value - from1) / (to1 - from1) * (to2 - from2) + from2
end

local function deep_clone(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[deep_clone(k, s)] = deep_clone(v, s) end
    return res
end

local grid_size = 32

local initial_size = wgui.info()
wgui.resize(initial_size.width + (grid_size * 8), initial_size.height)


local joypad_data = {
    X = 0,
    Y = 0,
    Cleft = false,
    Cright = false,
    Cup = false,
    Cdown = false,
    left = false,
    right = false,
    up = false,
    down = false,
    A = false,
    B = false,
    R = false,
    Z = false,
    L = false,
    start = false,
}
local function grid(x, y, x_span, y_span)
    if not x_span then
        x_span = 1
    end
    if not y_span then
        y_span = 1
    end

    return {
        x = initial_size.width + (grid_size * x),
        y = (grid_size * y),
        width = grid_size * x_span,
        height = grid_size * y_span,
    }
end
local function process_gui(input)
    Mupen_lua_ugui.joystick({
        uid = 0,
        is_enabled = true,
        rectangle = grid(0, 0, 4, 4),
        position = {
            x = remap(input.X, -128, 127, 0, 1),
            y = remap(-input.Y, -127, 128, 0, 1),
        },
    })
    input.X = Mupen_lua_ugui.spinner({
        uid = 1,
        is_enabled = true,
        rectangle = grid(4, 0, 2),
        is_horizontal = true,
        value = input.X,
        minimum = -128,
        maximum = 127
    })

    input.Y = Mupen_lua_ugui.spinner({
        uid = 2,
        is_enabled = true,
        rectangle = grid(6, 0, 2),
        is_horizontal = false,
        value = input.Y,
        minimum = -127,
        maximum = 128
    })

    input.A = Mupen_lua_ugui.toggle_button({
        uid = 3,
        is_enabled = true,
        rectangle = grid(4, 4, 2),
        text = "A",
        is_checked = input.A
    })

    input.B = Mupen_lua_ugui.toggle_button({
        uid = 4,
        is_enabled = true,
        rectangle = grid(2, 4, 2),
        text = "B",
        is_checked = input.B
    })

    input.Z = Mupen_lua_ugui.toggle_button({
        uid = 5,
        is_enabled = true,
        rectangle = grid(3, 6, 2),
        text = "Z",
        is_checked = input.Z
    })

    input.L = Mupen_lua_ugui.toggle_button({
        uid = 6,
        is_enabled = true,
        rectangle = grid(1, 5),
        text = "L",
        is_checked = input.L
    })

    input.R = Mupen_lua_ugui.toggle_button({
        uid = 7,
        is_enabled = true,
        rectangle = grid(6, 5),
        text = "R",
        is_checked = input.R
    })

    input.Cleft = Mupen_lua_ugui.toggle_button({
        uid = 8,
        is_enabled = true,
        rectangle = grid(0, 5),
        text = "C<",
        is_checked = input.Cleft
    })

    input.Cright = Mupen_lua_ugui.toggle_button({
        uid = 9,
        is_enabled = true,
        rectangle = grid(2, 5),
        text = "C>",
        is_checked = input.Cright
    })

    input.Cup = Mupen_lua_ugui.toggle_button({
        uid = 10,
        is_enabled = true,
        rectangle = grid(1, 4),
        text = "C^",
        is_checked = input.Cup
    })

    input.Cdown = Mupen_lua_ugui.toggle_button({
        uid = 11,
        is_enabled = true,
        rectangle = grid(1, 6),
        text = "Cv",
        is_checked = input.Cdown
    })

    input.left = Mupen_lua_ugui.toggle_button({
        uid = 12,
        is_enabled = true,
        rectangle = grid(5, 5),
        text = "D<",
        is_checked = input.left
    })

    input.right = Mupen_lua_ugui.toggle_button({
        uid = 13,
        is_enabled = true,
        rectangle = grid(7, 5),
        text = "D>",
        is_checked = input.right
    })

    input.up = Mupen_lua_ugui.toggle_button({
        uid = 14,
        is_enabled = true,
        rectangle = grid(6, 4),
        text = "D^",
        is_checked = input.up
    })

    input.down = Mupen_lua_ugui.toggle_button({
        uid = 15,
        is_enabled = true,
        rectangle = grid(6, 6),
        text = "Dv",
        is_checked = input.down
    })

    return input
end


emu.atinput(function()
    joypad.set(1, joypad_data)
end)

emu.atupdatescreen(function()
    if not joypad_data then
        print("skipping screen update, as there's no joystick data")
        return
    end
    local size = wgui.info()

    BreitbandGraphics.renderers.d2d.fill_rectangle({
        x = initial_size.width,
        y = 0,
        width = size.width - initial_size.width,
        height = initial_size.height,
    }, {
        r = 240,
        g = 240,
        b = 240,
    })

    local keys = input.get()
    Mupen_lua_ugui.begin_frame(BreitbandGraphics.renderers.d2d, Mupen_lua_ugui.stylers.windows_10, {
        pointer = {
            position = {
                x = keys.xmouse,
                y = keys.ymouse,
            },
            is_primary_down = keys.leftclick,
        },
        keyboard = {
            held_keys = keys,
        },
    })
    joypad_data = process_gui(deep_clone(joypad_data))

    Mupen_lua_ugui.end_frame()
end)

emu.atstop(function()
    wgui.resize(initial_size.width, initial_size.height)
end)
