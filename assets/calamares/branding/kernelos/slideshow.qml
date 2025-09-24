import QtQuick 2.0

Rectangle {
  width: 800; height: 600
  color: "#24292f"

  Image {
    anchors.fill: parent
    source: "banner.jpg"
    fillMode: Image.PreserveAspectCrop
    opacity: 0.2
  }

  Column {
    anchors.centerIn: parent
    spacing: 16
    Image { source: "logo.png"; width: 160; height: 160; fillMode: Image.PreserveAspectFit }
    Text { text: "Installation de KERNELOS 24.04 LTS"; color: "#ffffff"; font.pointSize: 18 }
    Text { text: "Merci de patienter..."; color: "#d8b9ff"; font.pointSize: 14 }
  }
}
