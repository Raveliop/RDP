import QtQuick 2.12
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0
import Sddm 1.1

Rectangle {
  id: root
  width: 1920; height: 1080
  color: "#24292f"

  Image {
    anchors.fill: parent
    source: "background.jpg"
    fillMode: Image.PreserveAspectCrop
  }

  Rectangle {
    anchors.fill: parent
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#55000000" }
      GradientStop { position: 1.0; color: "#66000000" }
    }
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    spacing: 20
    anchors.margins: 24

    Image {
      source: "logo.png"
      width: 148; height: 148
      fillMode: Image.PreserveAspectFit
    }

    Rectangle {
      width: 420; height: 120
      radius: 12
      color: "#1a000000"
      border.color: "#3a3f46"
      border.width: 1

      Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        TextField {
          id: user
          placeholderText: qsTr("Utilisateur")
          text: Sddm.userModel.lastUser
          width: parent.width
          height: 36
        }

        TextField {
          id: password
          placeholderText: qsTr("Mot de passe")
          echoMode: TextInput.Password
          width: parent.width
          height: 36
          onAccepted: login()
        }
      }
    }

    Button {
      text: qsTr("Se connecter")
      width: 420
      height: 40
      background: Rectangle { radius: 8; color: "#d8b9ff" }
      contentItem: Text { text: parent.parent.text; color: "#24292f"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 16 }
      onClicked: login()
    }
  }

  function login() {
    var session = Sddm.sessionModel.currentIndex >= 0 ? Sddm.sessionModel.data(Sddm.sessionModel.currentIndex, Sddm.SessionModel.KeySession) : ""
    Sddm.login(user.text, password.text, session)
  }
}
