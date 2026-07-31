import QtQuick 2.12
import QtPositioning 5.12
import Lomiri.Components 1.3
import QtQuick.Layouts 1.12
import io.thp.pyotherside 1.5
import QtSystemInfo 5.0
import QtLocation 5.12
import Lomiri.Components.ListItems 1.3 as ListItem
import Lomiri.Components.Popups 1.3
// import Morph.Web 0.1
// import QtWebEngine 1.10  // for offline map
import Qt.labs.platform 1.0 //for StandardPaths
import "components"

Page {
    id: mainPage
    header: PageHeader {
        id: map_header
        title: i18n.tr("Activity Map")
        trailingActionBar.actions: [
            Action {
            text: i18n.tr("Info")
            iconName: "info"
            onTriggered: {
                    indexrun = index
                    infodis=""
                    PopupUtils.open(infogpx)
                    pygpx.info_run(index)
            }
            }
        ]
    }
    property var polyline
    property var index

    ActivityIndicator {
        id: refreshmap
        anchors.centerIn: parent
        z: 5
    }

    Python {
        id: pygpxmap
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('py/'));
            importModule("geepeeex", function() {
                refreshmap.visible = true
                refreshmap.running = true
                refreshmap.focus = true
                pygpxmap.call("geepeeex.visu_gpx", [polyline], function(result) {
                    var coords = []
                    for (var i = 0; i < result.length; i++) {
                        coords.push([result[i].latitude, result[i].longitude])
                    }
                    // Egal welche Karte aktiv ist: gleiche Aufruf-Signatur
                    if (mapLoader.item) {
                        mapLoader.item.showTrack(coords)
                    }
                    refreshmap.visible = false
                    refreshmap.running = false
                    refreshmap.focus = false
                });
            });
        }
    }

    Loader {
        id: mapLoader
        anchors.top: map_header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        sourceComponent: persistentSettings.mapType==="offline" ? offlineMapComponent : onlineMapComponent
    }

    // ---- Thunderforest online map ----
    Component {
        id: onlineMapComponent
        Map {
            id: map
            center: QtPositioning.coordinate(persistentSettings.initialLat, persistentSettings.initialLong)
            zoomLevel: map.maximumZoomLevel - 5
            color: Theme.palette.normal.background
            activeMapType: supportedMapTypes[supportedMapTypes.length - 1]
            plugin: Plugin {
                name: "osm"
                required.mapping: Plugin.AnyMappingFeatures
                required.geocoding: Plugin.AnyGeocodingFeatures
                PluginParameter {
                    name: "osm.mapping.custom.host"
                    value: "http://tile.thunderforest.com/" + persistentSettings.mapType + "/%z/%x/%y.png?apikey=" + persistentSettings.myApiKey + "&fake=.png"
                }
                PluginParameter { name: "osm.mapping.custom.datacopyright"; value: "www.osm.org/copyright" }
                PluginParameter { name: "osm.mapping.custom.mapcopyright"; value: "www.thunderforest.com" }
                PluginParameter {
                    name: "osm.mapping.offline.directory"
                    value: StandardPaths.writableLocation(StandardPaths.CacheLocation) + "/QtLocation/5.12/tiles/osm"
                }
            }

            MapPolyline {
                id: pline
                line.width: 4
                line.color: 'red'
                path: []
            }

            // Same-named function as the offline variant
            function showTrack(coords) {
                pline.path = []
                for (var i = 0; i < coords.length; i++) {
                    pline.addCoordinate(QtPositioning.coordinate(coords[i][0], coords[i][1]))
                }
                if (coords.length > 0) {
                    map.center = QtPositioning.coordinate(coords[Math.floor(coords.length / 2)][0],
                                                           coords[Math.floor(coords.length / 2)][1])
                }
            }
        }
    }

    // ---- OSM Scout Server offline map ----
    OfflineMap {
        id: offlineMapComponent
    }
}
