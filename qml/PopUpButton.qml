import QtQuick 2.12
import Lomiri.Components 1.3

Button {
   property string texth
   property alias textSize: label.textSize
   property alias textColor: label.color
   height: units.gu(10)
   Label {
      id: label
      anchors {
         centerIn: parent
         margins: units.gu(1)
      }
      width: parent.width - units.gu(2)
      text: parent.texth
      wrapMode: Text.Wrap
      horizontalAlignment: Text.AlignHCenter
      font.pointSize: units.dp(12)
      color: "white"
   }
}
