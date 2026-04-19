#!/bin/bash

case "$1" in
    --pop)
        dunstctl history-pop
        ;;
    --close)
        dunstctl close-all
        ;;
    *)
        # Default: pop last 5 notifications
        for i in {1..5}; do
            dunstctl history-pop
            sleep 0.2
        done
        ;;
esac
