import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "components"

ApplicationWindow {
    id: win
    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 620
    visible: true
    title: "Orbit OS"
    color: "#10091f"

    property string page: "setupWelcome"
    property string setupMode: "choose"
    property string userName: "Orbit User"
    property string currentApp: ""
    property string wallpaper: "qrc:/wallpaper"
    property bool menuOpen: false
    property string selectedSetting: "Personalization"

    Connections {
        target: orbitBackend
        function onError(message) { notice.text = message; notice.open() }
        function onAccountCreated(name) { win.userName = name; setupFlow.step = 4; win.page = "setupFinished" }
        function onLoginSucceeded(name) { win.userName = name; win.page = "desktop" }
    }

    Component.onCompleted: {
        // First-run always starts in setup in this prototype.
        page = "setupWelcome"
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#10091f" }
            GradientStop { position: 0.55; color: "#21103b" }
            GradientStop { position: 1; color: "#351044" }
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: {
            if (page.startsWith("setup")) return 0
            if (page === "desktop") return 1
            if (page === "login") return 2
            return 1
        }

        Item {
            id: setupPage
            SetupFlow {
                id: setupFlow
                anchors.fill: parent
                onGoLogin: win.page = "login"
                onGoCreate: { setupFlow.step = 3; win.page = "setupCreate" }
                onFinished: win.page = "desktop"
                onBackWelcome: win.page = "setupWelcome"
            }
        }

        Item {
            id: desktopPage
            Desktop {
                anchors.fill: parent
                userName: win.userName
                onOpenApp: function(appName) { win.currentApp = appName; appDialog.open() }
                onOpenSettings: { win.currentApp = "Settings"; appDialog.open() }
                onOpenMenu: win.menuOpen = !win.menuOpen
                onLogout: win.page = "login"
            }
        }

        Item {
            id: loginPage
            LoginScreen {
                anchors.fill: parent
                onSignIn: function(email, password) { orbitBackend.login(email, password) }
                onCreateAccount: { setupFlow.step = 3; win.page = "setupCreate" }
                onBack: win.page = "setupWelcome"
            }
        }
    }

    Dialog {
        id: appDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(620, win.width - 50)
        title: win.currentApp
        standardButtons: Dialog.Close
        background: Rectangle { color: "#211332"; radius: 18; border.color: "#a34aff" }
        contentItem: AppWindow {
            appName: win.currentApp
            onOpenSettings: { appDialog.close(); win.currentApp = "Settings"; appDialog.open() }
        }
    }

    Popup {
        id: notice
        anchors.centerIn: Overlay.overlay
        width: 420
        height: 110
        property alias text: noticeText.text
        background: Rectangle { color: "#2b1740"; radius: 12; border.color: "#ff9d24" }
        contentItem: Label { id: noticeText; color: "white"; wrapMode: Text.WordWrap; verticalAlignment: Text.AlignVCenter }
    }
}
