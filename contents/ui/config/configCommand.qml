import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.ScrollablePage {

  id: commandConfigPage

  property alias cfg_updateInterval: updateIntervalSpin.value
  property string cfg_checkActiveCommand: checkActiveCommandInput.text
  property string cfg_countActiveCommand: countActiveCommandInput.text
  property string cfg_countAllCommand: countAllCommandInput.text
  property string cfg_listCommand: listCommandInput.text

  ColumnLayout {
    anchors {
      left: parent.left
      top: parent.top
      right: parent.right
    }

    Kirigami.FormLayout {
      wideMode: false
      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "General"
      }
    }

    Kirigami.FormLayout {
      Controls.SpinBox {
        id: updateIntervalSpin
        Kirigami.FormData.label: "Update every: "
        from: 1
        to: 1440 // 1 day
        editable: true
        textFromValue: (value) => value + " minute(s)"
        valueFromText: (text) => parseInt(text)
      }
    }

    Kirigami.FormLayout {
      wideMode: false
      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Checck & count"
      }
    }

    Kirigami.FormLayout {
      wideMode: false
      Controls.TextField {
        id: checkActiveCommandInput
        Kirigami.FormData.label: "Check if docker is running command: "
      }
      Controls.TextField {
        id: countActiveCommandInput
        Kirigami.FormData.label: "Count active containers command: "
      }
      Controls.TextField {
        id: countAllCommandInput
        Kirigami.FormData.label: "Count all containers command: "
      }
      Controls.TextField {
        id: listCommandInput
        Kirigami.FormData.label: "List containers command: "
      }
    }
  }
}
