#!/usr/bin/zsh

# Log input arguments for debugging (optional)
echo "Wrapper invoked with arguments: $@" >> ~/tmp/.nvim_wrapper.log

# Detect the mode (diff, merge, pager)
case "$1" in
    difftool|diff)
        # Ensure LOCAL and REMOTE are set for diffs
        if [ -z "$LOCAL" ] || [ -z "$REMOTE" ]; then
            echo "Error: LOCAL and REMOTE must be set for diff/difftool mode." >&2
            exit 1
        fi
        # Launch Neovim in diff mode
        nvim -c 'set ft=diff' -c 'BaleiaColorize' -d "$LOCAL" "$REMOTE" -c 'BaleiaColorize'
        ;;
    mergetool|merge)
        # Ensure LOCAL, REMOTE, and MERGED are set for merges
        if [ -z "$LOCAL" ] || [ -z "$REMOTE" ] || [ -z "$MERGED" ]; then
            echo "Error: LOCAL, REMOTE, and MERGED must be set for merge/mergetool mode." >&2
            exit 1
        fi
        # Launch Neovim in merge mode
        nvim -c 'set ft=diff' -c 'BaleiaColorize' -d "$LOCAL" "$REMOTE" "$MERGED" -c 'BaleiaColorize'
        ;;
    pager)
        # Use Neovim as a pager
        nvim -c 'set ft=diff' -c 'BaleiaColorize' -
        ;;
    *)
        # Handle unsupported modes
        echo "Unsupported mode: $1" >&2
        exit 1
        ;;
esac
