import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

import "components" as Components

PlasmaExtras.Representation {
  id: full

  focus: true
  anchors.fill: parent
  Layout.minimumHeight: 200
  Layout.minimumWidth: 200
  Layout.maximumWidth: 400

  property var dividerColor: Kirigami.Theme.textColor
  property var dividerOpacity: 0.1
  property string totalActive: "0"
  property string total: "0"
  property string dockerList: ""
  property bool isActive: false
  property bool isUpdating: false
  property bool onError: false
  property string errorMessage: ""

  Connections {
    target: cmdSource
    function onSigIsUpdating(status) {
      full.isUpdating = status
    }
    function onSigIsActive(active) {
      full.isActive = active
    }
    function onSigCountAll(count) {
      full.total = count
    }
    function onSigCountActive(count) {
      full.totalActive = count
    }
    function onSigList(list) {
      dockerListModel.clear()
      injectList(list)
    }
    function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
      if (stderr !== '') {
        full.onError = true
        full.errorMessage = stderr
      }
    }
  }

  function refresh() {
    if (!isActive  ) main.checkIsActive()
  }

  function injectList(list) {
    const lines = list.split("\n")
    const datas = []
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      if (line.trim() !== "") {
        try {
          const containerData = JSON.parse(line)
          const name = containerData.Names || "unknown"
          const id = containerData.ID || "unknown"
          const status = containerData.Status || "unknown"
          const state = containerData.State || "unknown"
          const image = containerData.Image || "unknown"
          const localVolumes = containerData.LocalVolumes || "unknown"
          const networks = containerData.Networks || "unknown"
          const ports = containerData.Ports || "unknown"
          const size = containerData.Size || "unknown"
          const isRunning = state === "running"
          datas.push({
            "name": name,
            "id": id,
            "status": status,
            "state": state,
            "isRunning": isRunning,
            "image": image,
            "localVolumes": localVolumes,
            "networks": networks,
            "ports": ports,
            "size": size
          })
        } catch (error) {
          console.log("Error parsing JSON line:", error)
        }
      }
    }
    datas.sort((a, b) => {
      if (a.isRunning !== b.isRunning) {
        return b.isRunning - a.isRunning
      }
      return a.name.localeCompare(b.name)
    })
    dockerListModel.append(datas)
  }

  ListModel { id: dockerListModel }

  // topbar
  RowLayout {
    id: header
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    width: parent.width

    RowLayout {
      Layout.alignment: Qt.AlignLeft
      spacing: 0

      Controls.Label {
        height: Kirigami.Units.iconSizes.medium
        text: 'Active ' + full.totalActive + ' - Overall ' + full.total
      }
    }

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: 0

      PlasmaComponents.BusyIndicator {
        id: busyIndicatorUpdateIcon
        visible: isUpdating && dockerList !== ""
      }

      PlasmaComponents.BusyIndicator {
        id: busyIndicatorCheckUpdatesIcon
        visible: isUpdating
      }

      PlasmaComponents.ToolButton {
        id: checkUpdatesIcon
        height: Kirigami.Units.iconSizes.medium
        icon.name: "view-refresh-symbolic"
        display: PlasmaComponents.AbstractButton.IconOnly
        text: i18n("Refresh list")
        visible: !isUpdating
        onClicked: main.checkIsActive()
        PlasmaComponents.ToolTip {
          text: parent.text
        }
      }
    }
  }

  // separator
  Rectangle {
    id: headerSeparator
    anchors.top: header.bottom
    width: parent.width
    height: 1
    color: Kirigami.Theme.textColor
    opacity: 0.25
    visible: true
  }

  // page view for the list
  Kirigami.ScrollablePage {
    id: scrollView
    visible: !isUpdating && !onError
    background: Rectangle {
      anchors.fill: parent
      color: "transparent"
    }
    anchors.top: headerSeparator.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    ListView {
      id: packageView
      anchors.rightMargin: Kirigami.Units.gridUnit
      model: dockerListModel
      highlight: PlasmaExtras.Highlight {}
      highlightMoveDuration: Kirigami.Units.shortDuration
      highlightResizeDuration: Kirigami.Units.shortDuration
      delegate: Components.ListItem {}
    }
  }

  PlasmaExtras.PlaceholderMessage {
    id: upToDateLabel
    text: i18n("Docker is not running !")
    anchors.centerIn: parent
    visible: !isActive && dockerList === "" && !onError
  }

  // if an error happened
  Controls.Label {
    id: errorLabel
    width: parent.width
    text: i18n("Hu ho something is wrong\n" + errorMessage)
    anchors.centerIn: parent
    visible: onError
    wrapMode: Text.Wrap
  }

  // loading indicator
  PlasmaComponents.BusyIndicator {
    id: busyIndicator
    anchors.centerIn: parent
    visible: isUpdating  && !onError
  }

  Component.onCompleted: {
    refresh()
  }
}
