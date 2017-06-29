local bricks = require 'bricks'

local group           = bricks.group
local text            = bricks.text
local checkbox        = bricks.checkbox
local spinner         = bricks.spinner
local button          = bricks.button
local text_input      = bricks.text_input
local radio_group     = bricks.radio_group
local radio_option    = bricks.radio_option
local dropdown_group  = bricks.dropdown_group
local dropdown_option = bricks.dropdown_option

local layout = bricks.layout({
    text({
        text = "Bricks Examples: Element Styling",
        tags = { "title" },
    }),
    group({"10", "10", "40", "80"}, {
        text("Checkboxes"),
        checkbox({0, 32, 32, 32}, {
            onchange = function(self, selected)
                self:layout():elementWithId("checkbox-result"):setText("selected: " .. tostring(selected))
            end,
            onload = function(self)
                self:onchange(self.selected)
            end
        }),
        text("checkbox-result", {32, 32, "100", "100"})
    }),
    group({"50", "20", "40", "80"}, {
        text("Buttons and Spinners"),
        spinner("spinner", {0, 32, 32, 32}, {
            visible = false,
        }),
        button({64, 32, "40", 32}, {
            onclick = function(self)
                local spinner = self:layout():elementWithId("spinner")
                spinner.visible = not spinner.visible
            end,
        }, {
            text({text = "Toggle Spinner"}),
        }),
    }),
    group({"10", "40", "40", "80"}, {
        text("Text Inputs"),
        text_input("textinput-input", {0, 32, "50", 32}, {
            onchange = function(self)
                local text = self:value()
                self:layout():elementWithId("textinput-result"):setText(string.format("input: %q", text))
            end,
        }),
        text("textinput-result", {0, 72, "100", 32}, {text = "input: \"\""}),
    }),
    group({"50", "40", "40", "80"}, {
        text("Radio Buttons"),
        radio_group("test-group", {
            onchange = function(self, selected)
                local text = self:value()
                self:layout():elementWithId("radio-result"):setText(string.format("selected: %q", text or ""))
            end,
        }, {
            radio_option({0, 32, 32, 32}, {
                group = "test-group",
                value = "1",
            }),
            radio_option({0, 64, 32, 32}, {
                group = "test-group",
                value = "2",
            }),
        }),
        text("radio-result", {0, 96, "100", 32}, {text = "selected: \"\""}),
    }),
    group({"50", "40", "40", "80"}, {
        text("New Elements"),
        radio_group("test-group", {
            onchange = function(self, selected)
                local text = self:value()
                self:layout():elementWithId("radio-result"):setText(string.format("selected: %q", text or ""))
            end,
        }, {
            radio_option({0, 32, 32, 32}, {
                group = "test-group",
                value = "1",
            }),
            radio_option({0, 64, 32, 32}, {
                group = "test-group",
                value = "2",
            }),
        }),
        text("radio-result", {0, 96, "100", 32}, {text = "selected: \"\""}),
    }),
})



local layout = bricks.layout({
    text({
        text = "Bricks Examples: Basic Elements",
        tags = { "title" },
    }),
    group({"10", "10", "40", "80"}, {
        text("Checkboxes"),
        checkbox({0, 32, 32, 32}, {
            onchange = function(self, selected)
                self:layout():elementWithId("checkbox-result"):setText("selected: " .. tostring(selected))
            end,
            onload = function(self)
                self:onchange(self.selected)
            end
        }),
        text("checkbox-result", {32, 32, "100", "100"}, {text = "selected: false"})
    }),
    group({"50", "10", "40", "80"}, {
        text("Buttons & Spinners"),
        spinner("spinner", {0, 32, 32, 32}, {
            visible = false,
        }),
        button({64, 32, "40", 32}, {
            onclick = function(self)
                local spinner = self:layout():elementWithId("spinner")
                spinner.visible = not spinner.visible
            end,
        }, {
            text("Toggle Spinner"),
        }),
    }),
    group({"10", "30", "40", "80"}, {
        text("Text Inputs"),
        text_input("textinput-input", {0, 32, "50", 32}, {
            placeholder = text("Placeholder text"),
            onchange = function(self)
                local text = self:value()
                self:layout():elementWithId("textinput-result"):setText(string.format("input: %q", text))
            end,
        }),
        text("textinput-result", {0, 72, "100", 32}, {text = "input: \"\""}),
    }),
    group({"50", "30", "40", "80"}, {
        text("Radio Buttons"),
        radio_group("test-group", {
            onchange = function(self, selected)
                local text = self:value()
                self:layout():elementWithId("radio-result"):setText(string.format("selected: %q", text or ""))
            end,
        }, {
            radio_option({0, 32, 32, 32}, {
                group = "test-group",
                value = "1",
            }),
            radio_option({0, 64, 32, 32}, {
                group = "test-group",
                value = "2",
            }),
        }),
        text("radio-result", {0, 96, "100", 32}, {text = "selected: \"\""}),
    }),
    group({"10", "60", "40", "80"}, {
        text("Dropdowns & Flashes"),
        dropdown_group({0, 32, "50", 32}, {
            placeholder = text("Dropdown"),
            onchange = function(self, selected)
                print(selected.value)
            end
        }, {
            dropdown_option({
                value = "1"
            }, {
                text({text = "Option 1"}),
            }),
            dropdown_option({
                value = "2"
            }, {
                text({text = "Option 2"}),
            }),
        })
    }),
})


layout:addStyle({
    ["text.title"] = {
        textColor = {0, 128, 128},
    },
    ["button"] = {
        backgroundColor = {0, 32, 32},
    },
    [".error"] = {
        textColor = {192, 64, 64},
    },
    ["[selected=true]"] = {
        borderColor = {192, 64, 64},
    },
})

return layout