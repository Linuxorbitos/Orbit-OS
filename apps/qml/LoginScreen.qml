import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    signal signIn(string email, string password)
    signal createAccount()
    signal back()
    property string emailValue: ""
    property string passwordValue: ""

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 460)
        spacing: 16
        Label { text: "🪐"; color: "#ff9b22"; font.pixelSize: 60; Layout.alignment: Qt.AlignHCenter }
        Label { text: "Orbit"; color: "#ff9b22"; font.pixelSize: 38; font.bold: true; Layout.alignment: Qt.AlignHCenter }
        Label { text: "Sign in to your Orbit account"; color: "white"; font.pixelSize: 20; Layout.alignment: Qt.AlignHCenter }
        TextField { Layout.fillWidth: true; placeholderText: "Email (ends with @orbit.com)"; onTextChanged: emailValue = text }
        TextField { Layout.fillWidth: true; placeholderText: "Password"; echoMode: TextInput.Password; onTextChanged: passwordValue = text }
        Button { Layout.fillWidth: true; text: "Sign In"; highlighted: true; onClicked: signIn(emailValue, passwordValue) }
        Label { text: "or"; color: "#cdb9e5"; Layout.alignment: Qt.AlignHCenter }
        // This button deliberately routes to the Create Account step in the setup wizard.
        Button { Layout.fillWidth: true; text: "Create Account"; onClicked: createAccount() }
        Button { Layout.fillWidth: true; text: "Back to setup"; onClicked: back() }
    }
}
