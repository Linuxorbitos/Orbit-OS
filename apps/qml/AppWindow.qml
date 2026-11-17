import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    property string appName: "App"
    signal openSettings()
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 20; spacing: 14
        Label { text: appName; color: "#ff9b22"; font.pixelSize: 26; font.bold: true }
        Loader {
            Layout.fillWidth: true; Layout.fillHeight: true
            sourceComponent: {
                if (appName === "Settings") return settingsComponent
                if (appName === "App Store") return storeComponent
                if (appName === "Orbit Browser") return browserComponent
                if (appName === "Clock") return clockComponent
                if (appName === "Calculator") return calculatorComponent
                return genericComponent
            }
        }
    }

    Component {
        id: settingsComponent
        ColumnLayout {
            property string section: "Personalization"
            RowLayout {
                Repeater {
                    model: ["Personalization", "Account", "Security", "Advanced", "Drivers"]
                    Button { text: modelData; onClicked: section = modelData }
                }
            }
            Label { text: section; color: "white"; font.pixelSize: 21 }
            Label {
                color: "#d5c4e8"; wrapMode: Text.WordWrap
                text: section === "Personalization" ? "Choose Orbit wallpapers, purple/orange accents, and desktop appearance."
                    : section === "Account" ? "Manage your local Orbit profile. Cloud accounts are not enabled in this prototype."
                    : section === "Security" ? "Local passwords are stored as PBKDF2 hashes. Production security needs a reviewed server."
                    : section === "Drivers" ? "Detect hardware and review Ubuntu-supported driver recommendations. Scanning is read-only; installation is not automatic."
                    : "Software updates and reset options are planned. No destructive reset action is enabled."
            }
            Loader {
                Layout.fillWidth: true
                active: section === "Drivers"
                sourceComponent: driversComponent
            }
            Button { visible: section !== "Drivers"; text: "Check for Software Updates"; onClicked: Qt.openUrlExternally("https://ubuntu.com/tutorials/upgrading-ubuntu-desktop") }
            Button { visible: section === "Personalization"; text: "Wallpaper: Orbit Space"; onClicked: {} }

            Component {
                id: driversComponent
                ColumnLayout {
                    spacing: 10
                    RowLayout {
                        Button { text: "Scan Hardware"; highlighted: true; onClicked: driverOutput.text = orbitBackend.scanHardware() }
                        Button { text: "Recommendations"; onClicked: driverOutput.text = orbitBackend.driverRecommendations() }
                    }
                    TextArea {
                        id: driverOutput
                        Layout.fillWidth: true
                        Layout.preferredHeight: 230
                        readOnly: true
                        color: "#f5efff"
                        wrapMode: TextArea.Wrap
                        placeholderText: "Choose Scan Hardware to inspect this computer."
                        background: Rectangle { color: "#160d25"; radius: 8; border.color: "#8f45bd" }
                    }
                    Label {
                        Layout.fillWidth: true
                        text: "Driver installation is deliberately handled through the reviewed Orbit Drivers CLI. Review the package plan and APT transaction before approving any system changes."
                        color: "#cdb9e5"
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
    Component {
        id: storeComponent
        ColumnLayout {
            Label { text: "Discover apps from Flathub"; color: "white"; font.pixelSize: 20 }
            Label { text: "Browse open-source desktop applications. Install integration is a future milestone."; color: "#d5c4e8"; wrapMode: Text.WordWrap }
            Button { text: "Browse Flathub"; highlighted: true; onClicked: Qt.openUrlExternally("https://flathub.org") }
        }
    }
    Component {
        id: browserComponent
        ColumnLayout {
            Label { text: "DuckDuckGo"; color: "white"; font.pixelSize: 24 }
            TextField { id: query; Layout.fillWidth: true; placeholderText: "Search the web with DuckDuckGo..." }
            Button { text: "Search"; highlighted: true; onClicked: Qt.openUrlExternally("https://duckduckgo.com/?q=" + encodeURIComponent(query.text)) }
            Label { text: "This prototype opens searches in your system browser."; color: "#d5c4e8" }
        }
    }
    Component {
        id: clockComponent
        ColumnLayout {
            Label { text: Qt.formatDateTime(new Date(), "h:mm:ss AP"); color: "white"; font.pixelSize: 42 }
            Label { text: Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy"); color: "#d5c4e8" }
        }
    }
    Component {
        id: calculatorComponent
        ColumnLayout {
            property string display: "0"
            Label { text: display; color: "white"; font.pixelSize: 34 }
            GridLayout {
                columns: 4
                Repeater {
                    model: ["7","8","9","÷","4","5","6","×","1","2","3","−","C","0",".","+","="]
                    Button { text: modelData; onClicked: display = modelData === "C" ? "0" : display + modelData }
                }
            }
        }
    }
    Component {
        id: genericComponent
        ColumnLayout {
            Label { text: appName + " is part of the Orbit app collection."; color: "white"; wrapMode: Text.WordWrap }
            Label { text: "This starter app will receive its own implementation in a later release."; color: "#d5c4e8"; wrapMode: Text.WordWrap }
        }
    }
}
