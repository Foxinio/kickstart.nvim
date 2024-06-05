-- Define your plugin module
local MyPlugin = {}

-- Initialize your global state
MyPlugin.state = {
    counter = 0,
    settings = {
        option1 = true,
        option2 = "value"
    }
}

-- Define functions to manipulate the state
function MyPlugin.increment_counter()
    MyPlugin.state.counter = MyPlugin.state.counter + 1
    print("Counter:", MyPlugin.state.counter)
end

function MyPlugin.toggle_option(option)
    MyPlugin.state.settings[option] = not MyPlugin.state.settings[option]
    print(option .. " toggled:", MyPlugin.state.settings[option])
end

-- Return the module
return MyPlugin
