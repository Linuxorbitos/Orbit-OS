import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    property string userName: "Orbit User"
    signal openApp(string appName)
    signal openSettings()
    signal openMenu()
    signal logout()

    Image {
        anchors.fill: parent
        source: "../../../assets/wallpapers/orbit-wallpaper.svg"
        fillMode: Image.PreserveAspectCrop
    }
    Column {
        anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 22; spacing: 18
        Repeater {
            model: ["🗑  Trash", "📁  Files", "🛍  App Store", "🌐  Orbit Browser", "⚙  Settings"]
            delegate: Button {
                text: modelData
                onClicked: {
                    if (index === 0) openApp("Trash")
                    else if (index === 4) openSettings()
                    else openApp(modelData.split("  ")[1])
                }
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom; width: parent.width; height: 58
        color: "#e5160d27"; border.color: "#a34aff"
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16
            Button { text: "🟣  " + userName + "  ▾"; onClicked: profileMenu.open() }
            Item { Layout.fillWidth: true }
            Label { text: Qt.formatDateTime(new Date(), "ddd, MMM d  •  h:mm AP"); color: "white" }
        }
    }

    Button {
        anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 18
        text: "☰  All Apps"
        onClicked: appMenu.open()
    }

    Popup {
        id: appMenu
        x: parent.width - width - 18; y: 65; width: 440; height: 390
        background: Rectangle { color: "#241438"; radius: 16; border.color: "#a34aff" }
        contentItem: ColumnLayout {
            Label { text: "All Applications"; color: "white"; font.pixelSize: 22 }
            TextField { id: search; Layout.fillWidth: true; placeholderText: "Search apps..." }
            GridLayout {
                Layout.fillWidth: true; columns: 3
                Repeater {
                    model: ["App Store", "Orbit Browser", "Settings", "Clock", "Files", "Calculator", "Calendar", "Music", "Photos", "Terminal", "Weather", "Trash"]
                    delegate: Button {
                        visible: search.text.length === 0 || modelData.toLowerCase().includes(search.text.toLowerCase())
                        text: modelData
                        onClicked: { appMenu.close(); openApp(modelData) }
                    }
                }
            }
        }
    }
    Menu {
        id: profileMenu
        MenuItem { text: "Account"; onTriggered: openSettings() }
        MenuItem { text: "Log out"; onTriggered: logout() }
    }
}
