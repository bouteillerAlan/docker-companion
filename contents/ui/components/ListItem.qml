import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kquickcontrolsaddons as KQuickControlsAddons
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore

PlasmaExtras.ExpandableListItem {
  id: root

  required property int index

  // Docker container properties directly injected from the model
  required property string name
  required property string id
  required property string status
  required property string state
  required property bool isRunning
  required property string image
  required property string localVolumes
  required property string networks
  required property string ports
  required property string size

  property list<string> currentContainerDetails

  // Map property names to icons
  property var iconMapping: {
    "ID": "username-copy",
    "Image": "kpackagekit-updates",
    "Status": "dialog-information",
    "State": isRunning ? "media-playback-start" : "media-playback-stop",
    "Size": "transform-scale",
    "Volumes": "disk-quota",
    "Networks": "network-wired-activated",
    "Ports": "kdeconnect-tray"
  }

  property color nameColor: Kirigami.Theme.textColor
  property color sourceColor: Kirigami.Theme.disabledTextColor
  property color runningColor: Kirigami.Theme.positiveTextColor
  property color stoppedColor: Kirigami.Theme.negativeTextColor

  icon: isRunning ? "media-playback-start" : "media-playback-stop"
  title: name
  subtitle: infoText()
  isBusy: false
  isDefault: isRunning

  defaultActionButtonAction: QQC2.Action {
    icon.name: root.isRunning ? "media-playback-stop" : "media-playback-start"
    text: root.isRunning ? i18n("Stop") : i18n("Start")
    onTriggered: function() {
      // todo add cmd
      console.log("Toggle container:", id);
    }
  }

  // Container details in expandable section
  customExpandedViewContent: Component {
    id: expandedView

    ColumnLayout {
      spacing: 0

      KQuickControlsAddons.Clipboard {
        id: clipboard
      }

      PlasmaExtras.Menu {
        id: contextMenu
        property string text

        function show(visualParent, text, x, y) {
          this.visualParent = visualParent;
          this.text = text;
          open(x, y);
        }

        PlasmaExtras.MenuItem {
          text: i18n("Copy")
          icon: "edit-copy-symbolic"
          enabled: contextMenu.text !== ""
          onClicked: clipboard.content = contextMenu.text
        }
      }

      // Details
      MouseArea {
        Layout.fillWidth: true
        Layout.preferredHeight: detailsGrid.implicitHeight

        acceptedButtons: Qt.RightButton
        activeFocusOnTab: repeater.count > 0

        Accessible.description: {
          var description = [];
          for (var i = 0; i < root.currentContainerDetails.length; i += 2) {
            description.push(root.currentContainerDetails[i]);
            description.push(": ");
            description.push(root.currentContainerDetails[i + 1]);
            description.push("; ");
          }
          return description.join('');
        }

        onPressed: function(mouse) {
          var item = detailsGrid.childAt(mouse.x, mouse.y);
          if (!item || !item.isContent) {
            return; // only let users copy the value on the right
          }

          contextMenu.show(this, item.text, mouse.x, mouse.y);
        }

        Loader {
          anchors.fill: parent
          active: parent.activeFocus
          asynchronous: true
          z: -1
          sourceComponent: PlasmaExtras.Highlight {
            hovered: true
          }
        }

        GridLayout {
          id: detailsGrid
          width: parent.width
          columns: 3
          rowSpacing: Kirigami.Units.smallSpacing
          columnSpacing: Kirigami.Units.largeSpacing

          // icon
          Repeater {
            id: rowRepeater
            model: Math.floor(root.currentContainerDetails.length / 2)
            Kirigami.Icon {
              Layout.row: index
              Layout.column: 0
              Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
              source: root.iconMapping[root.currentContainerDetails[index * 2]] || "dialog-question"
            }
          }

          // title
          Repeater {
            model: Math.floor(root.currentContainerDetails.length / 2)
            PlasmaComponents.Label {
              Layout.row: index
              Layout.column: 1
              Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
              text: root.currentContainerDetails[index * 2] + ":"
              font: Kirigami.Theme.smallFont
              opacity: 1
              elide: Text.ElideNone
              textFormat: Text.StyledText
            }
          }

          // label
          Repeater {
            model: Math.floor(root.currentContainerDetails.length / 2)
            PlasmaComponents.Label {
              Layout.row: index
              Layout.column: 2
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
              text: root.currentContainerDetails[index * 2 + 1]
              font: Kirigami.Theme.smallFont
              opacity: 0.6
              elide: Text.ElideRight
              textFormat: Text.StyledText
            }
          }
        }
      }

      Component.onCompleted: {
        root.createContent();
      }
    }
  }

  function createContent() {
    const details = [];

    details.push(i18n("ID"));
    details.push(id);

    details.push(i18n("Image"));
    details.push(image);

    details.push(i18n("Status"));
    details.push(status);

    details.push(i18n("State"));
    details.push(state);

    details.push(i18n("Size"));
    details.push(size);

    details.push(i18n("Volumes"));
    details.push(localVolumes);

    details.push(i18n("Networks"));
    details.push(networks);

    details.push(i18n("Ports"));
    details.push(ports);

    currentContainerDetails = details;
  }

  function infoText() {
    const labels = [];

    if (isRunning) {
      labels.push(i18n("Running"));
    } else {
      labels.push(i18n("Stopped"));
    }

    labels.push(status);

    if (image) {
      labels.push(image);
    }

    return labels.join(" · ");
  }
}
