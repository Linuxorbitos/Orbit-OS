import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    signal goLogin()
    signal goCreate()
    signal finished()
    signal backWelcome()
    property int step: 0
    property string language: "English (United States)"
    property string selectedNetwork: "Skip for now"

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width - 50, 570)
            spacing: 18

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "🪐  ORBIT"
                color: "#ff9b22"
                font.pixelSize: 38
                font.bold: true
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: ["Welcome to Orbit", "Connect to Wi-Fi", "Choose how to continue", "Create your Orbit account", "Setup complete!"][root.step]
                color: "white"; font.pixelSize: 28; font.bold: true
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: ["Explore. Create. Belong.", "Connect to a network or continue offline.", "Sign in or create a new account.", "Use an @orbit.com address.", "You're ready to explore Orbit."][root.step]
                color: "#cdb9e5"; font.pixelSize: 15
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 20
                color: "#b51a1025"
                border.color: "#783ab0"
                implicitHeight: formColumn.implicitHeight + 42
                ColumnLayout {
                    id: formColumn
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 14

                    StackLayout {
                        Layout.fillWidth: true
                        currentIndex: root.step
                        ColumnLayout {
                            Label { text: "Language"; color: "white" }
                            ComboBox {
                                Layout.fillWidth: true
                                model: ["English (United States)", "English (United Kingdom)", "Español", "Français", "Deutsch"]
                                onActivated: root.language = currentText
                            }
                        }
                        ColumnLayout {
                            Label { text: "Available network (demo selector)"; color: "white" }
                            ComboBox {
                                Layout.fillWidth: true
                                model: ["OrbitNet", "HomeWiFi", "Guest", "Skip for now"]
                                onActivated: root.selectedNetwork = currentText
                            }
                            Label { text: "Network connection is not configured by this UI prototype."; color: "#cdb9e5"; wrapMode: Text.WordWrap }
                        }
                        ColumnLayout {
                            Label { text: "Already have an Orbit account?"; color: "white" }
                            Button { text: "Sign In"; Layout.fillWidth: true; onClicked: root.goLogin() }
                            Label { text: "New to Orbit?"; color: "white" }
                            Button { text: "Create Account"; Layout.fillWidth: true; highlighted: true; onClicked: root.goCreate() }
                        }
                        CreateAccountForm {
                            onCreated: function(name, email, password) {
                                orbitBackend.createAccount(name, email, password)
                            }
                            onBackToLogin: root.goLogin()
                        }
                        ColumnLayout {
                            Label { text: "Orbit is ready, " + "welcome!"; color: "white"; font.pixelSize: 18 }
                            Button { text: "Start using Orbit"; Layout.fillWidth: true; highlighted: true; onClicked: root.finished() }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Back"
                    visible: root.step > 0 && root.step !== 2 && root.step !== 3
                    onClicked: root.step--
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: root.step === 0 ? "Next  →" : root.step === 1 ? "Next  →" : "Continue"
                    visible: root.step < 2
                    highlighted: true
                    onClicked: root.step++
                }
            }
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 9
                Repeater {
                    model: 5
                    Rectangle { width: 9; height: 9; radius: 5; color: index === root.step ? "#ff9b22" : "#684b80" }
                }
            }
        }
    }
}
