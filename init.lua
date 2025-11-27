-- Additional Keymaps
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex, { desc = "Go to netrw" })
vim.keymap.set("n", "<leader>o", vim.cmd.so, { desc = "Source file" })
vim.keymap.set("n", "<leader>w", vim.cmd.w, { desc = "Save file" })
vim.keymap.set("n", "<leader>q", vim.cmd.q, { desc = "Quit file" })
vim.keymap.set("n", "<C-n>", vim.cmd.NvimTreeToggle, { desc = "Open Neovim Tree" })
vim.keymap.set("i", "<C-n>", vim.cmd.NvimTreeToggle, { desc = "Open Neovim Tree" })
vim.keymap.set("n", "<C-e>", vim.cmd.NvimTreeFocus, { desc = "Open Neovim Tree" })
vim.keymap.set("i", "<C-e>", vim.cmd.NvimTreeFocus, { desc = "Open Neovim Tree" })
vim.keymap.set("n", "<leader>dd", function()
	-- vim.cmd[[bdelete]]
	vim.cmd("q!")
	vim.cmd("mode")
end, { desc = "Delete buffer" })
vim.keymap.set({ "n", "i", "v" }, "<C-q>", function()
	vim.cmd("q!")
end, { desc = "Force quit" })
vim.o.clipboard = "unnamedplus"

-- Lazy Package Manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Vim opts
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.softtabstop = 2
		vim.bo.expandtab = true
	end,
})

local file_management = {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({})
		end,
	},
}

local pre_lsp = {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				highlight = { enable = true },
				indent = { enable = true },
				auto_tag = { enable = true },
				auto_install = true,
				-- ensure_installed = "all",
			})
		end,
	},
}

local severity = vim.diagnostic.severity

local keymap = vim.keymap -- for conciseness
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf, silent = true }

		-- set keybinds
		opts.desc = "Show LSP references"
		keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

		opts.desc = "Go to declaration"
		keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

		opts.desc = "Show LSP definition"
		keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show lsp definition

		opts.desc = "Show LSP implementations"
		keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

		opts.desc = "Show LSP type definitions"
		keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

		opts.desc = "See available code actions"
		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection
		-- opts.desc = "Show diagnostics in location list"
		-- keymap.set({ "n", "v" }, "<leader>ds", function()
		-- 	vim.diagnostic.setloclist()
		-- end, opts)

		vim.keymap.set("n", "<leader>ds", function()
			require("telescope.builtin").diagnostics({ bufnr = 0 })
		end, { desc = "Telescope diagnostics for current buffer" })

		opts.desc = "Smart rename"
		keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

		opts.desc = "Show buffer diagnostics"
		keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

		opts.desc = "Show line diagnostics"
		keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

		opts.desc = "Go to previous diagnostic"
		keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, opts) -- jump to previous diagnostic in buffer
		--
		opts.desc = "Go to next diagnostic"
		keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, opts) -- jump to next diagnostic in buffer

		opts.desc = "Show documentation for what is under cursor"
		keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

		opts.desc = "Restart LSP"
		keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
	end,
})

vim.diagnostic.config({
	signs = {
		text = {
			[severity.ERROR] = " ",
			[severity.WARN] = " ",
			[severity.HINT] = "󰠠 ",
			[severity.INFO] = " ",
		},
	},
	-- virtual_text = true,
	virtual_text = {
		prefix = " ",
	},
	update_in_insert = false,
	float = {
		border = "rounded",
		focusable = false,
		style = "minimal",
		source = "always",
	},
})

local lsp_config = {
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"clangd",
				"rust_analyzer",
				"tailwindcss",
				"vtsls",
				"cssls",
				"html",
				"lua_ls",
				"svelte",
				"jdtls",
			},
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
}

-- vim.lsp.config["vtsls"] = {
-- 	cmd = { "typescript-language-server", "--stdio" },
-- 	-- filetypes is optional; by default it's set in lspconfig
-- 	-- filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
-- 	settings = {},
-- 	on_init = function(client, _)
-- 		client.handlers["textDocument/publishDiagnostics"] = function() end
-- 	end,
-- }
-- vim.lsp.enable("svelte", "cssls", "html", "ts_ls", "lua_ls" )

local lsp_extras = {
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "1.*",
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "super-tab",

				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = { auto_show = false },
				ghost_text = { enabled = true, show_with_menu = true },
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				path = {
					trailing_slash = true,
					label_trailing_slash = true,
				},
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
			windows = {
				documentation = {
					border = "rounded",
					winhighlight = "NormalFloat:CmpDoc,FloatBorder:CmpDocBorder",
				},
			},
			opts_extend = { "sources.default" },
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				js = { "prettierd", "prettier", stop_after_first = true },
				ts = { "prettierd", "prettier", stop_after_first = true },
				jsx = { "prettierd", "prettier", stop_after_first = true },
				tsx = { "prettierd", "prettier", stop_after_first = true },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		},
	},
	-- {
	-- 	"esmuellert/nvim-eslint",
	-- 	config = function()
	-- 		require("nvim-eslint").setup({})
	-- 	end,
	-- },
}

local utils = {
	{
		"lewis6991/gitsigns.nvim",
	},
}
-- Functions
local function transparency()
	-- Normal UI
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })

	--Telescope
	vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
	vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
	vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none" })
	vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none" })

	-- Remove background from NvimTree and its UI elements
	vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { bg = "none", fg = "#444444" }) -- optional, customize

	vim.api.nvim_set_hl(0, "TSContext", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TSNote", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TSWarning", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TSDanger", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TSKeyword", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TSVariable", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "@keyword", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "@variable", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "@tag", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "@markup", { bg = "NONE" })

	-- Diagnostic
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "none", fg = "#7aa2f7" })
	vim.api.nvim_set_hl(0, "DiagnosticSignError", { bg = "none", fg = "#f7768e" })
	vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { bg = "none", fg = "#e0af68" })
	vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { bg = "none", fg = "#7aa2f7" })
	vim.api.nvim_set_hl(0, "DiagnosticSignHint", { bg = "none", fg = "#9ece6a" })
	-- Error (red)
	vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", {
		fg = "#F7768E",
		bg = "none",
	})

	-- Warning (yellow)
	vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", {
		fg = "#e0af68",
		bg = "none",
	})

	-- Info (blue)
	vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", {
		fg = "#7AA2F7",
		bg = "none",
	})

	-- Hint (cyan)
	vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", {
		fg = "#1ABC9C",
		bg = "none",
	})
end

local aesthetics = {
	{
		"folke/tokyonight.nvim",
		config = function()
			-- vim.cmd.colorscheme("tokyonight")
			vim.cmd([[colorscheme tokyonight]])
			transparency()
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			theme = "tokyonight",
		},
	},
}

local one_liners = {
	{
		"tpope/vim-fugitive",
	},
	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({})
		end,
	},
	{
		"stevearc/dressing.nvim",
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
}

require("lazy").setup({
	file_management,
	pre_lsp,
	aesthetics,
	one_liners,
	lsp_config,
	lsp_extras,
	utils,
	-- spec = {},
	change_detection = { notify = false },
})
