pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Templates as T

import org.kde.coreaddons as KCoreAddons
import org.kde.kcmutils as KCMUtils

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.plasmoid

// property var iconMapping: {
//     "ID": "username-copy",
//     "Image": "kpackagekit-updates",
//     "Status": "dialog-information",
//     "State": isRunning ? "media-playback-start" : "media-playback-stop",
//     "Size": "transform-scale",
//     "Volumes": "disk-quota",
//     "Networks": "network-wired-activated",
//     "Ports": "kdeconnect-tray"
//   }
//
//   property color nameColor: Kirigami.Theme.textColor
//   property color sourceColor: Kirigami.Theme.disabledTextColor
//   property color runningColor: Kirigami.Theme.positiveTextColor
//   property color stoppedColor: Kirigami.Theme.negativeTextColor


PlasmaExtras.ExpandableListItem {
  id: dockerItem

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

  function copy(text) {
    plasmoid.nativeInterface.clipboardContents = text;
  }

  Rectangle {
    id: hoverOverlay
    anchors.fill: parent
    z: -1  // behind the content
    color: mouseArea.containsMouse ? Qt.rgba(Kirigami.Theme.hoverColor.r, Kirigami.Theme.hoverColor.g, Kirigami.Theme.hoverColor.b, 0.25) : "transparent"
    radius: Kirigami.Units.smallSpacing
    Behavior on color {
      ColorAnimation {
        duration: 150
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    // Don't eat clicks — let underlying items handle them
    acceptedButtons: Qt.NoButton
  }

  // header
  icon: isRunning ? "media-playback-start" : "media-playback-stop"
  title: name
  subtitle: id
  isBusy: mainWindow.expanded && main.isOnUpdate

  // btn next to header
  defaultActionButtonAction: Action {
    id: stateChangeButton
    enabled: true
    icon.name: isRunning ? "media-playback-stop" : "media-playback-start"
    text: isRunning ? i18n("Stop") : i18n("Start")
    onTriggered: isRunning ? cmdSource.exec(`docker stop ${id}`) : cmdSource.exec(`docker start ${id}`)
  }
  showDefaultActionButtonWhenBusy: false

  // list of btn for infos
  contextualActions: [
    Action {
      text: `ID: ${id}`
      icon.name: iconMapping["ID"]
      onTriggered: copy(id)
    },
    Action {
      text: `Image: ${image}`
      icon.name: iconMapping["Image"]
      onTriggered: copy(image)
    },
    Action {
      text: `Status: ${status}`
      icon.name: iconMapping["Status"]
      onTriggered: copy(status)
    },
    Action {
      text: `Size: ${size}`
      icon.name: iconMapping["Size"]
      onTriggered: copy(size)
    },
    Action {
      text: `Local vlm: ${localVolumes}`
      icon.name: iconMapping["Volumes"]
      onTriggered: copy(localVolumes)
    },
    Action {
      text: `Networks: ${networks}`
      icon.name: iconMapping["Networks"]
      onTriggered: copy(networks)
    },
    Action {
      text: `Ports: ${ports}`
      icon.name: iconMapping["Ports"]
      onTriggered: copy(ports)
    }
  ]

}
