pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    property var windowList: []
    property bool refreshPending: false

    function refresh() {
        if (getClients.running) {
            refreshPending = true;
            return;
        }
        getClients.running = true;
    }

    function focusedWindowForWorkspace(workspaceId) {
        const wsWindows = root.windowList.filter(w => w.workspace && w.workspace.id === workspaceId);
        if (wsWindows.length === 0)
            return null;

        return wsWindows.reduce((best, win) => {
            const bestFocus = best?.focusHistoryID ?? Infinity;
            const winFocus = win?.focusHistoryID ?? Infinity;
            return winFocus < bestFocus ? win : best;
        }, null);
    }

    Process {
        id: getClients
        running: false
        command: ["hyprctl", "clients", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const text = this.text.trim();
                    if (text.length === 0)
                        return;
                    root.windowList = JSON.parse(text);
                } catch (err) {
                    console.error("Failed to parse Hyprland clients:", err);
                    root.windowList = [];
                }
            }
        }

        onExited: {
            if (root.refreshPending) {
                root.refreshPending = false;
                refreshTimer.restart();
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 50
        repeat: false
        onTriggered: root.refresh()
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name.endsWith("v2"))
                return;
            if (event.name.includes("workspace") || event.name.includes("window"))
                root.refresh();
        }
    }

    Component.onCompleted: refresh()
}
