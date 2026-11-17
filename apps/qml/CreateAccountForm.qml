import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    signal created(string name, string email, string password)
    signal backToLogin()
    property string nameValue: ""
    property string emailValue: ""
    property string passwordValue: ""
    spacing: 10
    TextField { Layout.fillWidth: true; placeholderText: "Your name"; onTextChanged: nameValue = text }
    TextField { Layout.fillWidth: true; placeholderText: "name@orbit.com"; onTextChanged: emailValue = text }
    TextField { Layout.fillWidth: true; placeholderText: "Password (10+ characters)"; echoMode: TextInput.Password; onTextChanged: passwordValue = text }
    Button {
        Layout.fillWidth: true; text: "Create Account"; highlighted: true
        onClicked: created(nameValue, emailValue, passwordValue)
    }
    Button { Layout.fillWidth: true; text: "Login instead"; onClicked: backToLogin() }
}
