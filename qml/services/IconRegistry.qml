pragma Singleton
import QtQuick
import Quickshell

/*
    This registry is only used to get app details for wm classes.
*/

Singleton {
    id: registry

    property var classToIcon: ({})
    property var desktopIdToIcon: ({})
    property var nameToIcon: ({})

    function fileExists(path) {
        const req = new XMLHttpRequest();
        req.open("HEAD", "file://" + path, false);
        req.send();
        return req.status === 200;
    }

    function resolveIcon(className) {
        if (!className || className.length === 0)
            return "";

        const original = className;
        const normalized = className.toLowerCase();
        if (Quickshell.iconPath(original, true))
            return original;

        if (Quickshell.iconPath(normalized, true))
            return normalized;

        const dashed = normalized.replace(/\s+/g, "-");
        if (Quickshell.iconPath(dashed, true))
            return dashed;

        if (Quickshell.iconPath(normalized + "-symbolic", true))
            return normalized + "-symbolic";

        if (Quickshell.iconPath(dashed + "-symbolic", true))
            return dashed + "-symbolic";

        const ext = original.split(".").pop().toLowerCase();
        if (Quickshell.iconPath(ext, true))
            return ext;

        return "";
    }

    function iconForDesktopIcon(icon) {
        if (!icon)
            return "";

        // If it's already a URL, keep it
        if (icon.startsWith("file://") || icon.startsWith("qrc:/"))
            return icon;

        // Absolute filesystem path → convert to file URL
        if (icon.startsWith("/"))
            return "file://" + icon;

        // Try exact theme icon name first
        const exact = Quickshell.iconPath(icon, true);
        if (exact)
            return exact;

        // Symbolic fallback for themes like Adwaita that only ship -symbolic variants
        const symbolic = Quickshell.iconPath(icon + "-symbolic", true);
        if (symbolic)
            return symbolic;

        // Pixmaps fallback for apps that ship their icon outside the theme
        const exts = ["png", "svg", "xpm"];
        for (const ext of exts) {
            const path = "/usr/share/pixmaps/" + icon + "." + ext;
            if (fileExists(path))
                return "file://" + path;
        }

        return "";
    }

    // Try very aggressive matching so the running app always gets the same icon as launcher
    function iconForClass(id) {
        if (!id)
            return "";

        const lower = id.toLowerCase();

        // direct hits first
        if (classToIcon[lower])
            return iconForDesktopIcon(classToIcon[lower]);

        if (desktopIdToIcon[lower])
            return iconForDesktopIcon(desktopIdToIcon[lower]);

        if (nameToIcon[lower])
            return iconForDesktopIcon(nameToIcon[lower]);

        // fuzzy contains match against wmClass map
        for (let key in classToIcon) {
            if (lower.includes(key) || key.includes(lower))
                return iconForDesktopIcon(classToIcon[key]);
        }

        // fuzzy against desktop ids
        for (let key in desktopIdToIcon) {
            if (lower.includes(key) || key.includes(lower))
                return iconForDesktopIcon(desktopIdToIcon[key]);
        }

        // fuzzy against names
        for (let key in nameToIcon) {
            if (lower.includes(key) || key.includes(lower))
                return iconForDesktopIcon(nameToIcon[key]);
        }

        // final fallback to theme resolution
        const resolved = resolveIcon(id);
        return iconForDesktopIcon(resolved);
    }

    function registerApp(displayName, icon, wmClass, desktopId) {
        if (wmClass)
            classToIcon[wmClass.toLowerCase()] = icon;

        if (desktopId)
            desktopIdToIcon[desktopId.toLowerCase()] = icon;

        if (displayName)
            nameToIcon[displayName.toLowerCase()] = icon;

        // Hard aliases for apps with messy WM_CLASS values
        if (displayName.toLowerCase().includes("visual studio code") || icon.toLowerCase().includes("code")) {
            classToIcon["code"] = icon;
            classToIcon["code-oss"] = icon;
            classToIcon["code-url-handler"] = icon;
            desktopIdToIcon["code.desktop"] = icon;
            desktopIdToIcon["code-oss.desktop"] = icon;
        }
    }

    function buildRegistry() {
        const entries = DesktopEntries.applications.values;
        if (entries.length === 0)
            return;

        // Reset maps before rebuilding
        registry.classToIcon = {};
        registry.desktopIdToIcon = {};
        registry.nameToIcon = {};

        for (let entry of entries) {
            if (entry.noDisplay)
                continue;
            registry.registerApp(entry.name || "", entry.icon || "", entry.startupWMClass || "", entry.id || "");
        }
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            buildRegistry();
        }
    }

    Component.onCompleted: buildRegistry()
}
