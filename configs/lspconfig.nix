{ config, pkgs, lib, nix2nvimrc, ... }:
let
  inherit (nix2nvimrc) luaExpr;
  inherit (config) hasLang;
in
{
  configs.lspconfig = {
    after = [
      "global"
      "lsp-status"
      "cmp"
    ];
    plugins = [ pkgs.vimPlugins.nvim-lspconfig ];
    lspconfig = {
      servers =
        let
          lang_server = {
            javascript.tsserver = { };
            bash.bashls = { };
            nix.nixd = { };
            rust.rust_analyzer = { };
            yaml.yamlls = { };
            lua.lua_ls.config.settings.Lua = ./sumneko_lua.config.lua;
            xml.lemminx.config.filetypes = [ "xslt" ];
            python.pyright = { };
            # dhall-lsp-server is broken
            #dhall.dhall_lsp_server.pkg = pkgs.dhall-lsp-server;
            json.jsonls.config.cmd = [ "json-languageserver" "--stdio" ];
            cpp.clangd = { };
            beancount.beancount = { };
            go.gopls = { };
            vue.volar = { };
          };
        in
        builtins.foldl'
          (old: lang: old // lang_server.${lang})
          { }
          (builtins.filter hasLang (builtins.attrNames lang_server));

      capabilities = luaExpr "require'cmp_nvim_lsp'.default_capabilities(vim.tbl_extend('keep', vim.lsp.protocol.make_client_capabilities(), require'lsp-status'.capabilities))";

      keymaps = map (nix2nvimrc.toKeymap { silent = true; }) [
        [ "n" "gD" (luaExpr "vim.lsp.buf.declaration") { desc = "Goto declaration"; } ]
        [ "n" "gd" (luaExpr "vim.lsp.buf.definition") { desc = "Goto definition"; } ]
        [ "n" "K" (luaExpr "vim.lsp.buf.hover") { desc = "Show hover"; } ]
        [ "n" "gi" (luaExpr "vim.lsp.buf.implementation") { desc = "Goto implementation"; } ]
        [ "n" "<C-k>" (luaExpr "vim.lsp.buf.signature_help") { desc = "Show signature help"; } ]
        [ "n" "<Leader>wa" (luaExpr "vim.lsp.buf.add_workspace_folder") { desc = "Add workspace folder"; } ]
        [ "n" "<Leader>wr" (luaExpr "vim.lsp.buf.remove_workspace_folder") { desc = "Remove workspace folder"; } ]
        [ "n" "<Leader>wl" (luaExpr "function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end") { desc = "List workspace folder"; } ]
        [ "n" "<Leader>D" (luaExpr "vim.lsp.buf.type_definition") { desc = "Goto definition"; } ]
        [ "n" "<Leader>rn" (luaExpr "vim.lsp.buf.rename") { desc = "Rename"; } ]
        [ "n" "<Leader>ca" (luaExpr "vim.lsp.buf.code_action") { desc = "Code actions"; } ]
        [ "n" "gr" (luaExpr "vim.lsp.buf.references") { desc = "Select codGoto definition"; } ]
      ];

      on_attach = ./lspconfig-on_attach.lua;
    };
  };

  wrapper.env.PATH.values = [ ]
    ++ lib.optional (hasLang "javascript") "${pkgs.nodePackages.typescript-language-server}/bin"
    ++ lib.optional (hasLang "rust") "${pkgs.rust-analyzer}/bin"
    ++ lib.optionals (hasLang "nix") [ "${pkgs.nixd}/bin" "${pkgs.nixpkgs-fmt}/bin" ]
    ++ lib.optional (hasLang "bash") "${pkgs.nodePackages.bash-language-server}/bin"
    ++ lib.optional (hasLang "yaml") "${pkgs.nodePackages.yaml-language-server}/bin"
    ++ lib.optional (hasLang "lua") "${pkgs.sumneko-lua-language-server}/bin"
    ++ lib.optional (hasLang "xml") "${pkgs.lemminx}/bin"
    ++ lib.optional (hasLang "python") "${pkgs.nodePackages.pyright}/bin"
    ++ lib.optional (hasLang "json") "${pkgs.nodePackages.vscode-json-languageserver-bin}/bin"
    ++ lib.optional (hasLang "cpp") "${pkgs.clang-tools}/bin"
    ++ lib.optional (hasLang "beancount") "${pkgs.beancount-language-server}/bin"
    ++ lib.optionals (hasLang "go") [ "${pkgs.gopls}/bin" "${pkgs.go}/bin" ]
    ++ lib.optional (hasLang "vue") "${pkgs.nodePackages.volar}/bin"
  ;
}
