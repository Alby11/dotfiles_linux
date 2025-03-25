#!/usr/bin/env zsh

# Function to handle Ctrl-C interrupt
# This function is called when the user presses Ctrl-C
function ctrl_c() {
    # Prompt the user to enter 'nil' to drop to normal prompt
    echo -e "\rEnter 'nil' to drop to normal prompt"
    read -r input
    # If the user enters 'nil', display a message and exit
    if [[ $input == 'nil' ]]; then
        echo "Non-Tmux choice, loading profile..."
        # Kill the countdown process to stop the timer
        kill $countdown_pid 2>/dev/null
        exit 1
    fi
}

# Trap Ctrl-C signal and call ctrl_c function
# This ensures that the ctrl_c function is called when the user presses Ctrl-C
trap ctrl_c SIGINT

echo "Existing tmux sessions:"

# Get the list of tmux sessions with detailed information
output=()
session_names=()
index=1
# Read each line of the tmux list-sessions output
while read -r line; do
    # Extract the session name from the line
    session_name=$(echo "$line" | awk -F: '{print $1}')
    # Get detailed information about the session
    session_info=$(tmux display-message -p -t "$session_name" '#{session_windows} windows, created at #{session_created}, attached: #{session_attached}')
    # Get the session creation time
    session_created=$(tmux display-message -p -t "$session_name" '#{session_created}')
    # Convert the session creation time to a human-readable format
    human_readable_time=$(date -d @"$session_created" '+%Y/%m/%d %H:%M:%S')
    # Add the line to the output array
    output+=("$line")
    # Add the session name to the session_names array
    session_names+=("$session_name")
    # Display the session information with index
    echo "$index - $line"
    echo "${session_info}, created at ${human_readable_time}"
    echo "----------------------------------------"
    index=$((index + 1))
done < <(tmux list-sessions -F '#S: #I:#P #W [#F] #T #L')

# Get the number of tmux sessions
no_of_terminals=${#output[@]}

# Display the list of tmux sessions
echo "Choose the terminal to attach: "

# Set the timeout for user input in seconds
timeout_seconds=20

echo
echo "...Or create a new session by entering a name (at least one non-digit) for it (in $timeout_seconds seconds)"

# Countdown timer in the background
(
    # Loop to display the countdown timer
    for ((i=$timeout_seconds; i>0; i--)); do
        # Display the remaining time in red if 5 seconds or less
        if (( i <= 5 )); then
            echo -ne "\e[31m$i seconds remaining...\e[0m\r"
        else
            echo -ne "$i seconds remaining...\r"
        fi
        sleep 1
    done
    echo
) &
# Store the process ID of the countdown timer
countdown_pid=$!

# Ensure the countdown process is killed on exit
trap "kill $countdown_pid 2>/dev/null" EXIT

# Read user input with a timeout
read -t $timeout_seconds -r input

# Kill the countdown process after reading the input
kill $countdown_pid 2>/dev/null

# Handle user input
if [[ -z $input ]]; then
    # No input, display a message and exit
    echo "Non-Tmux choice, loading profile..."
    exit 1
elif [[ $input == 'nil' ]]; then
    # Input is 'nil', display a message and exit
    echo "Non-Tmux choice, loading profile..."
    exit 1
elif [[ $input =~ ^[0-9]+$ ]] && (( input > 0 && input <= no_of_terminals )); then
    # Input is a valid number, attach to the selected tmux session
    echo "Chosen session $input: ${session_names[input - 1]}"
    tmux attach -t "${session_names[input - 1]}"
elif [[ $input =~ ^[0-9]+$ ]]; then
    # Input is a number but not a valid session number, display a message and exit
    echo "Invalid session number, loading profile..."
    exit 1
else
    # Input is a name, create a new tmux session with the given name
    tmux new-session -s "$input"
fi

exit 0
