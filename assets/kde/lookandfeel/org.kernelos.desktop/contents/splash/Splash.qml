import QtQuick 2.12

Rectangle {
  id: root
  width: 1920; height: 1080
  color: "#24292f"

  Image {
    anchors.fill: parent
    source: "file:///usr/share/wallpapers/KernelosDark/contents/images/3840x2160.jpg"
    fillMode: Image.PreserveAspectCrop
  }

  Rectangle {
    anchors.fill: parent
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#66000000" }
      GradientStop { position: 1.0; color: "#66000000" }
    }
  }

  Column {
    anchors.centerIn: parent
    spacing: 24
    Image {
      source: "logo.png"
      width: 220; height: 220
      fillMode: Image.PreserveAspectFit
      opacity: 0.0
      Behavior on opacity { NumberAnimation { duration: 600 } }
      Component.onCompleted: opacity = 1.0
    }
    Rectangle {
      width: 360; height: 6
      radius: 3
      color: "#1a000000"
      clip: true
      Rectangle {
        id: bar
        width: 120; height: 6
        radius: 3
        color: "#d8b9ff"
        x: -120
        SequentialAnimation on x {
          loops: Animation.Infinite
          NumberAnimation { from: -120; to: 360; duration: 1600; easing.type: Easing.InOutQuad }
        }
      }
    }
  }
}
