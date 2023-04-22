Hooks:PostHook(MenuMainState, "at_enter", "VoidUIInfobox_Check_dependency", function(self, ...)
    if not VoidUI then
        local menu_options = {
            [1] = {
                text = managers.localization:text("VoidUI_IB_install_depencency"),
                callback = function() os.execute("cmd /c start https://modworkshop.net/mod/20997") end,
            },
            [2] = {
                text = managers.localization:text("VoidUI_IB_quit"),
                callback = function() os.exit() end,
                is_cancel_button = true,
            },
        }
        local menu = QuickMenu:new(
            managers.localization:text("VoidUI_IB_missing_dependency_title"),
            managers.localization:text("VoidUI_IB_missing_dependency_desc"),
            menu_options
        )
        menu:Show()
    end
end)