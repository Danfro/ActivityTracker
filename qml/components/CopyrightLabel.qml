import QtQuick 2.12
import Lomiri.Components 1.3

Row {
    property bool showOfflinecredits: persistentSettings.mapType === "offline"
    height: units.gu(2)

    Label {
        visible: !showOfflinecredits
        text: " © "
    }
    Label {
        visible: !showOfflinecredits
        text: "www.thunderforest.com"
        color: theme.palette.normal.activity
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.openUrlExternally('https://www.thunderforest.com/')
        }
    }
    Label {
        visible: showOfflinecredits
        text: " © "
    }
    Label {
        visible: showOfflinecredits
        text: "OSM Scout Server"
        color: theme.palette.normal.activity
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.openUrlExternally('https://rinigus.github.io/osmscout-server/')
        }
    }

    Label {
        visible: showOfflinecredits
        text: " | "
    }
    Label {
        visible: showOfflinecredits
        text: "MapLibre GL JS"
        color: theme.palette.normal.activity
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.openUrlExternally('https://maplibre.org/maplibre-gl-js')
        }
    }

    Label {
        text: " | "
    }
    Label {
        text: "www.osm.org/"
        color: theme.palette.normal.activity
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.openUrlExternally('https://www.osm.org/copyright')
        }
    }
}
