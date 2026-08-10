import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.services

RowLayout {
    Layout.fillWidth: false
    spacing: 4 * Config.paddingScale

    Repeater {
        model: Config.maxWorkspaces // max workspace buttons/texts to show

        delegate: Rectangle {
            id: wsButton

            required property int index
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            property string activeBg: "#4d5258"
            property string inactiveBg: "#393c41"

            Layout.preferredWidth: 17.5 * Config.pillScale
            Layout.preferredHeight: Layout.preferredWidth
            radius: 8 * Config.pillScale
            color: isActive ? activeBg : inactiveBg

            // animate color transition on workspace switch
            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }

            Text {
                anchors.centerIn: parent
                text: wsButton.index + 1
                visible: false
                color: wsButton.isActive ? "#ffffff" : "#dae0ea"
                font {
                    family: Theme.fontFamily
                    pixelSize: 11 * Config.pillScale
                    weight: 300
                }
            }

            // Icon container
            ClippingRectangle {
                id: iconContainer
                anchors.centerIn: parent
                width: 17
                height: 17
                color: "transparent"
                radius: 15
                clip: true

                IconImage {
                    id: appIcon

                    anchors.fill: parent
                    visible: source !== ""
                    source: {
                        const win = WorkspaceWindows.focusedWindowForWorkspace(index + 1);
                        if (!win)
                            return "";
                        const entry = DesktopEntries.heuristicLookup(win.class);
                        if (entry && entry.icon)
                            return IconRegistry.iconForDesktopIcon(entry.icon);
                        return IconRegistry.iconForClass(win.class);
                    }
                }
            }

            // clickable text buttons
            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (wsButton.index + 1 + "})"))
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
