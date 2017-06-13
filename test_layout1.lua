local bricks = require 'bricks'

return bricks.layout({
    bricks.text({text = "Bricks Examples: Basic Elements"}),
    bricks.group({"10", "10", "40", "80"}, {
        bricks.text({text = "Checkboxes"}),
        bricks.checkbox({0, 32, 32, 32}, {
            onchange = function(self, selected)
                self:layout():elementWithId("checkbox-result"):setText("selected: " .. tostring(selected))
            end,
        }),
        bricks.text("checkbox-result", {32, 32, "100", "100"}, {text = "selected: false"})
    }),
    bricks.group({"50", "10", "40", "80"}, {
        bricks.text({text = "Buttons & Spinners"}),
        bricks.spinner("spinner", {0, 32, 32, 32}, {
            visible = false,
        }),
        bricks.button({64, 32, "40", 32}, {
            onclick = function(self)
                local spinner = self:layout():elementWithId("spinner")
                spinner.visible = not spinner.visible
            end,
        }, {
            bricks.text({text = "Toggle Spinner"}),
        }),
    }),
    bricks.group({"10", "30", "40", "80"}, {
        bricks.text({text = "Text Inputs"}),
        bricks.text_input("textinput-input", {0, 32, "50", 32}, {
            placeholder = bricks.text({text = "Placeholder text"}),
            onchange = function(self)
                local text = self:value()
                self:layout():elementWithId("textinput-result"):setText(string.format("input: %q", text))
            end,
        }),
        bricks.text("textinput-result", {0, 72, "100", 32}, {text = "input: \"\""}),
    }),
    bricks.group({"50", "30", "40", "80"}, {
        bricks.text({text = "Radio Buttons"}),
        bricks.radio_group("test-group", {
            onchange = function(self, selected)
                local text = self:value()
                self:layout():elementWithId("radio-result"):setText(string.format("selected: %q", text or ""))
            end,
        }, {
            bricks.radio_option({0, 32, 32, 32}, {
                group = "test-group",
                value = "1",
            }),
            bricks.radio_option({0, 64, 32, 32}, {
                group = "test-group",
                value = "2",
            }),
        }),
        bricks.text("radio-result", {0, 96, "100", 32}, {text = "selected: \"\""}),
    }),
    bricks.group({"10", "60", "40", "80"}, {
        bricks.text({text = "Dropdowns & Flashes"}),
        bricks.dropdown_group({0, 32, "50", 32}, {
            placeholder = bricks.text({text = "Dropdown"}),
        }, {
            bricks.dropdown_option({
                value = "1"
            }, {
                bricks.text({text = "Option 1"}),
            }),
            bricks.dropdown_option({
                value = "2"
            }, {
                bricks.text({text = "Option 2"}),
            }),
        })
    }),
})
