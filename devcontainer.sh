#!/bin/bash

WORKSPACE_FOLDER="$(cd ../zmk && pwd)"

# Function to check if container is running
is_container_running() {
    devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" echo "Container is running" >/dev/null 2>&1
}

# Function to stop the devcontainer
stop_container() {
    if is_container_running; then
        devcontainer stop --workspace-folder "$WORKSPACE_FOLDER"
        echo "Devcontainer stopped"
    else
        echo "Devcontainer is not running"
    fi
}

# Function to connect to the devcontainer
connect_container() {
    if is_container_running; then
        devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" -- /bin/bash
    else
        echo "Devcontainer is not running. Use 'build' to start it first."
        exit 1
    fi
}

# Function to build
build() {
    if is_container_running; then
        echo "Devcontainer is already running"
    else
        devcontainer up --workspace-folder "$WORKSPACE_FOLDER"
        echo "Devcontainer daemon started"
    fi
    devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" bash /workspaces/zmk-config/draw.sh
    devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" bash /workspaces/zmk-config/build.sh
}

# Handle command line argument
case "${1:-build}" in
    stop)
        stop_container
        ;;
    connect)
        connect_container
        ;;
    draw)
        if ! is_container_running; then
            devcontainer up --workspace-folder "$WORKSPACE_FOLDER"
            echo "Devcontainer daemon started"
        fi
        devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" bash /workspaces/zmk-config/draw.sh
        ;;
    build)
        build
        ;;
    *)
        echo "Usage: $0 {stop|connect|build|draw}"
        echo "  stop    - Stop the devcontainer"
        echo "  connect - Connect interactively to the devcontainer"
        echo "  build   - Start the devcontainer and run build.sh (default)"
        echo "  draw    - Generate keymap SVG using keymap-drawer"
        exit 1
        ;;
esac
