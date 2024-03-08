{ pkgs, nix2nvimrc, ... }:
{
  configs.bufferline = {
    after = [ "leader" ];
    plugins = [ pkgs.vimPlugins.bufferline-nvim ];
    setup = { };
    keymaps = map (nix2nvimrc.toKeymap { silent = true; }) [
      [ "n" "<Leader>b" "<Cmd>BufferLinePick<CR>" { } ]
    ];
  };
}
