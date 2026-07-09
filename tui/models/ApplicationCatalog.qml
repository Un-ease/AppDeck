import QtQuick
import Quickshell

QtObject {
    id: catalog

    property string query: ""
    property int limit: 200

    readonly property var applications: DesktopEntries.applications.values
    readonly property var results: buildResults(applications, query)
    readonly property var iconCache: ({})

    function normalized(value) {
        return String(value || "").trim().toLowerCase();
    }

    function matchScore(entry, needle) {
        if (!needle) return 0;

        const name = normalized(entry.name);
        const genericName = normalized(entry.genericName);
        const comment = normalized(entry.comment);
        const keywords = normalized((entry.keywords || []).join(" "));

        if (name === needle) return 0;
        if (name.indexOf(needle) === 0) return 1;
        if (name.indexOf(" " + needle) !== -1) return 2;
        if (name.indexOf(needle) !== -1) return 3;
        if (genericName.indexOf(needle) !== -1) return 4;
        if (keywords.indexOf(needle) !== -1) return 5;
        if (comment.indexOf(needle) !== -1) return 6;
        return -1;
    }

    function buildResults(source, value) {
        const needle = normalized(value);
        const matches = [];

        for (let i = 0; i < source.length; i++) {
            const application = source[i];
            if (!application || application.noDisplay || !application.name) continue;

            const score = matchScore(application, needle);
            if (score < 0) continue;

            matches.push({
                label: application.name,
                description: application.genericName || application.comment || "Application",
                icon: application.icon,
                kind: "✦",
                score: score,
                desktopEntry: application
            });
        }

        matches.sort(function(first, second) {
            if (first.score !== second.score) return first.score - second.score;
            return first.label.localeCompare(second.label);
        });

        return matches.slice(0, limit);
    }

    function resolvedIcon(iconName) {
        const icon = String(iconName || "");
        if (!icon) return "";
        if (iconCache[icon] !== undefined) {
            return iconCache[icon];
        }
        const path = Quickshell.iconPath(icon, true);
        iconCache[icon] = path;
        return path;
    }

    function launch(item) {
        if (item && item.desktopEntry) item.desktopEntry.execute();
    }
}
