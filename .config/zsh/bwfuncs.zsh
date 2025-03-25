#!/bin/zsh

FUNCTION_DIR="$ZDOTDIR/functions"

# Create functions directory if not exists
mkdir -p $FUNCTION_DIR

# Define each function and create its file
declare -A functions

functions[bwlogin]='
# vim: ft=zsh
bwlogin() {
    local email="$1"
    bw login $email | tee /tmp/bw_output && echo $(grep BW_SESSION /tmp/bw_output | cut -d  -f2) > $ZDOTDIR/.bitwarden_session
}
'

functions[bwunlock]='
# vim: ft=zsh
bwunlock() {
    bw unlock --passwordenv BW_PASSWORD
}
'

functions[bwlogout]='
# vim: ft=zsh
bwlogout() {
    bw logout && rm -f $ZDOTDIR/.bitwarden_session
}
'

functions[bwlist]='
# vim: ft=zsh
bwlist() {
    source $ZDOTDIR/.bitwarden_session
    bw list items --session $BW_SESSION
}
'

functions[bwsearch]='
# vim: ft=zsh
bwsearch() {
    source $ZDOTDIR/.bitwarden_session
    bw list items --search "$1" --session $BW_SESSION
}
'

functions[bwcreatenote]='
# vim: ft=zsh
bwcreatenote() {
    source $ZDOTDIR/.bitwarden_session
    local note_name="$1"
    local note_content="$2"
    bw get template item | jq ".type = 2 | .secureNote.type = 0 | .notes = \"$note_content\" | .name = \"$note_name\"" | bw encode | bw create item --session $BW_SESSION
}
'

functions[bwattachfile]='
# vim: ft=zsh
bwattachfile() {
    source $ZDOTDIR/.bitwarden_session
    local item_id="$1"
    local file_path="$2"
    bw create attachment --file $file_path --itemid $item_id --session $BW_SESSION
}
'

functions[bwlock]='
# vim: ft=zsh
bwlock() {
    bw lock && unset BW_SESSION
}
'

functions[bwcommand]='
# vim: ft=zsh
bwcommand() {
    source $ZDOTDIR/.bitwarden_session
    bw "$@" --session $BW_SESSION
}
'

# Write each function to its own file
for function_name in ${(k)functions}; do
    echo "${functions[$function_name]}" > "$FUNCTION_DIR/$function_name"
    echo "Created function file: $FUNCTION_DIR/$function_name"
done
