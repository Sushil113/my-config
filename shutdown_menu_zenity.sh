#!/bin/bash
# shutdown_menu_zenity.sh

ACTION=$(zenity --list \
    --title="Shut Down Computer" \
    --text="What do you want the computer to do?" \
    --width=600 --height=380 \
    --column="Action" --column="Description" \
    "Shut down" "Closes all apps and turns off the PC" \
    "Restart" "Closes all apps and restarts the PC" \
    "Suspend" "Saves your work and goes into low-power mode" \
    "Hibernate" "Saves your work to disk and powers off" \
    "Log Out" "Closes your apps and signs you out")

case $ACTION in
    "Shut down")
        shutdown -h now
        ;;
    "Restart")
        shutdown -r now
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Hibernate")
        systemctl hibernate
        ;;
    "Log Out")
        gnome-session-quit --no-prompt
        ;;
esac