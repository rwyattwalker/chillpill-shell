pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Singleton {
    id: root

    // compositor stuff
    property string detectedCompositor: ""
    
    readonly property var backend: {
        if (detectedCompositor === "hyprland")
            return Hyprland
        return null
    }

    function require(compositors) {
        if (Array.isArray(compositors)) {
            return compositors.includes(detectedCompositor);
        }
        return compositors === detectedCompositor;
    }

    // Unified api
    property string title: backend?.title ?? ""
    property bool isFullscreen: backend?.isFullscreen ?? false
    property string layout: backend?.layout ?? "Tiled"
    property int focusedWorkspaceId: backend?.focusedWorkspaceId ?? 1
    property var workspaces: backend?.workspaces ?? []
    property var windowList: backend?.windowList ?? []
    property bool initialized: backend?.initialized ?? true
    property int workspaceCount: backend?.workspaceCount ?? 0
    property real screenW: backend?.screenW ?? 0
    property real screenH: backend?.screenH ?? 0
    property real screenScale: backend?.screenScale ?? 1
    readonly property Toplevel activeToplevel: ToplevelManager.activeToplevel

    function changeWorkspace(id) {
        backend?.changeWorkspace?.(id)
    }

    function changeWorkspaceRelative(delta) {
        backend?.changeWorkspaceRelative?.(delta)
    }

    function isWorkspaceOccupied(id) {
        return backend?.isWorkspaceOccupied?.(id) ?? false
    }

    function focusedWindowForWorkspace(id) {
        return backend?.focusedWindowForWorkspace?.(id) ?? null
    }

    // process to detect compositor
    Process {
        command: ["sh", "-c", "echo \"$XDG_CURRENT_DESKTOP $XDG_SESSION_DESKTOP\""]
        running: true

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return

                const val = data.trim().toLowerCase()

                if (val.includes("hyprland")) {
                    root.detectedCompositor = "hyprland"
                }
            }
        }
    }

    signal stateChanged()

    Connections {
        target: backend
        function onStateChanged() {
            root.stateChanged()
        }
    }

}
