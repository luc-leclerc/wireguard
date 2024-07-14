# ID: 776128ea-4a3b-4706-9f2e-9219f15446cb
# Intend: To run WireGuard with user without root, while still allowing it to run commands that requires root.
# Problem: The env. variables aren't passed to the script executed with sudo by default.
# Possible fix 1: To give access to preserve permission
## 1. Addind `SETENV:` to the script permissions, ex.:  "$USER ALL=(ALL) NOPASSWD:SETENV: ..":
## 2. And then calling it with -E option: 'sudo -E ./myScript.sh", otherwise, error message "sorry, you are not allowed to preserve the environment"
# Possible fix 2: To pass the environment variables as parameters
# Resolution: For sake of security, option 2 was picked because it requires less permissions.

# Here is helper function to help maintain the list
## To handle the parameters on the called script:
ITER=1; for i in $(grep -h -o -R -E "[A-Z_0-9]+" | grep -E "LEVEL3_[A-Z]" | sort | uniq); do echo "$i=\"\${$ITER}\""; ITER=$(expr $ITER + 1); done | xclip -sel cli

## To handle the parameters on the calling script:
grep -h -o -R -E "[A-Z_0-9]+" | grep -E "LEVEL3_[A-Z]" | sort | uniq | sed 's/^/"$/' | sed 's/$/"/' | tr '\n' ' ' | xclip -sel cli
