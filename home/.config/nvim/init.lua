-- Ctrl+Shift+C copies the selection to the laptop's clipboard. kitty on the laptop
-- passes the key on while the user variable in_editor is set (kitty.conf). Over SSH,
-- Neovim copies with OSC 52, which kitty writes to the clipboard.
vim.keymap.set("v", "<C-S-c>", '"+y')

local function set_in_editor(on)
	local value = on and "=MQ==" or ""
	vim.api.nvim_chan_send(vim.v.stderr, "\027]1337;SetUserVar=in_editor" .. value .. "\007")
end
vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
	callback = function() set_in_editor(true) end,
})
vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
	callback = function() set_in_editor(false) end,
})
