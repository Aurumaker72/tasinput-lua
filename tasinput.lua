local function folder(file)
    local s = debug.getinfo(2, 'S').source:sub(2)
    local p = file:gsub('[%(%)%%%.%+%-%*%?%^%$]', '%%%0'):gsub('[\\/]', '[\\/]') .. '$'
    return s:gsub(p, '')
end

dofile(folder('tasinput.lua') .. 'mupen-lua-ugui/mupen-lua-ugui.lua')
dofile(folder('tasinput.lua') .. 'mupen-lua-ugui-ext/mupen-lua-ugui-ext.lua')

local grid_size = 32
local mouse_wheel = 0
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
            x = Mupen_lua_ugui.internal.remap(input.X, -128, 127, 0, 1),
            y = Mupen_lua_ugui.internal.remap(-input.Y, -127, 128, 0, 1),
        },
    })
    input.X = Mupen_lua_ugui.numberbox({
        uid = 1,
        is_enabled = true,
        rectangle = grid(4, 0, 2),
        value = input.X,
        places = 3
    })
    input.X = Mupen_lua_ugui.internal.clamp(input.X, -128, 127)

    input.Y = Mupen_lua_ugui.numberbox({
        uid = 2,
        is_enabled = true,
        rectangle = grid(6, 0, 2),
        is_horizontal = false,
        value = input.Y,
        places = 3
    })
    input.Y = Mupen_lua_ugui.internal.clamp(input.Y, -127, 128)

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
        rectangle = grid(3, 6, 1),
        text = "Z",
        is_checked = input.Z
    })

    input.start = Mupen_lua_ugui.toggle_button({
        uid = 6,
        is_enabled = true,
        rectangle = grid(4, 6, 1),
        text = "S",
        is_checked = input.start
    })

    input.L = Mupen_lua_ugui.toggle_button({
        uid = 7,
        is_enabled = true,
        rectangle = grid(1, 5),
        text = "L",
        is_checked = input.L
    })

    input.R = Mupen_lua_ugui.toggle_button({
        uid = 8,
        is_enabled = true,
        rectangle = grid(6, 5),
        text = "R",
        is_checked = input.R
    })

    input.Cleft = Mupen_lua_ugui.toggle_button({
        uid = 9,
        is_enabled = true,
        rectangle = grid(0, 5),
        text = "C<",
        is_checked = input.Cleft
    })

    input.Cright = Mupen_lua_ugui.toggle_button({
        uid = 10,
        is_enabled = true,
        rectangle = grid(2, 5),
        text = "C>",
        is_checked = input.Cright
    })

    input.Cup = Mupen_lua_ugui.toggle_button({
        uid = 11,
        is_enabled = true,
        rectangle = grid(1, 4),
        text = "C^",
        is_checked = input.Cup
    })

    input.Cdown = Mupen_lua_ugui.toggle_button({
        uid = 12,
        is_enabled = true,
        rectangle = grid(1, 6),
        text = "Cv",
        is_checked = input.Cdown
    })

    input.left = Mupen_lua_ugui.toggle_button({
        uid = 13,
        is_enabled = true,
        rectangle = grid(5, 5),
        text = "D<",
        is_checked = input.left
    })

    input.right = Mupen_lua_ugui.toggle_button({
        uid = 14,
        is_enabled = true,
        rectangle = grid(7, 5),
        text = "D>",
        is_checked = input.right
    })

    input.up = Mupen_lua_ugui.toggle_button({
        uid = 15,
        is_enabled = true,
        rectangle = grid(6, 4),
        text = "D^",
        is_checked = input.up
    })

    input.down = Mupen_lua_ugui.toggle_button({
        uid = 16,
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

    BreitbandGraphics.fill_rectangle({
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
    Mupen_lua_ugui.begin_frame({
        mouse_position = {
            x = keys.xmouse,
            y = keys.ymouse,
        },
        wheel = mouse_wheel,
        is_primary_down = keys.leftclick,
        held_keys = keys,
    })
    mouse_wheel = 0
    joypad_data = process_gui(Mupen_lua_ugui.internal.deep_clone(joypad_data))

    Mupen_lua_ugui.end_frame()
end)

emu.atstop(function()
    wgui.resize(initial_size.width, initial_size.height)
end)
emu.atwindowmessage(function(_, msg_id, wparam, _)
    if msg_id == 522 then
        local scroll = math.floor(wparam / 65536)
        if scroll == 120 then
            mouse_wheel = 1
        elseif scroll == 65416 then
            mouse_wheel = -1
        end
    end
end)
