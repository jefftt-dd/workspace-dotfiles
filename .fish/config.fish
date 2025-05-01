# Base16 Shell
if status --is-interactive
    set BASE16_SHELL "$HOME/.config/base16-shell/"
    source "$BASE16_SHELL/profile_helper.fish"
end

base16-material

set -gx EDITOR nvim

# Vi mode
fish_vi_key_bindings

source ~/.aliases/common.fish
source ~/.aliases/ddog.fish
source ~/.aliases/ddog-libstreaming.fish

# plugins
# https://github.com/IlanCosman/tide
# https://github.com/jethrokuan/z
# https://github.com/PatrickF1/fzf.fish

# Don't exit with CTRL-D (lots of fat fingering from VIM)
bind -M insert \cd true

# fzf

fzf_configure_bindings  --directory=\ct
