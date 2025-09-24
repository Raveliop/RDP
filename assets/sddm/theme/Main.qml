import QtQuick 2.12
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0
import Sddm 1.1

Rectangle {
  id: root
  width: 1920; height: 1080
  color: "#24292f"

  Image {
    id: bg
    anchors.fill: parent
    source: "background.jpg"
    fillMode: Image.PreserveAspectCrop
    cache: true
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    spacing: 16

    Image {
      source: "logo.png"
      width: 128; height: 128
      fillMode: Image.PreserveAspectFit
    }

    TextField {
      id: user
      placeholderText: qsTr("Utilisateur")
      text: Sddm.userModel.lastUser
      width: 320
      onAccepted: password.forceActiveFocus()
    }

    TextField {
      id: password
      placeholderText: qsTr("Mot de passe")
      echoMode: TextInput.Password
      width: 320
      onAccepted: login()
    }

    Button {
      text: qsTr("Se connecter")
      width: 320
      onClicked: login()
    }
  }

  function login() {
    var session = Sddm.sessionModel.currentIndex >= 0 ? Sddm.sessionModel.data(Sddm.sessionModel.currentIndex, Sddm.SessionModel.KeySession) : ""
    Sddm.login(user.text, password.text, session)
  }
}
