import QtQuick 2.12
import QtPositioning 5.12
import Lomiri.Components 1.3
import QtQuick.Layouts 1.12
import io.thp.pyotherside 1.5
import QtSystemInfo 5.0
import QtLocation 5.12
import Lomiri.Components.ListItems 1.3 as ListItem
import Lomiri.Components.Popups 1.3
import Morph.Web 0.1
import Qt.labs.platform 1.0 //for StandardPaths


Page {
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
   id: mainPage
   property var polyline
   property var index

   ActivityIndicator {
       id:refreshmap
       anchors.centerIn: parent
       z: 5
   }

   Python {
      id: pygpxmap
      Component.onCompleted: {

         addImportPath(Qt.resolvedUrl('py/'));
         importModule("geepeeex", function() {
            // console.warn("calling python script to load the gpx file")
            refreshmap.visible = true
            refreshmap.running = true
            refreshmap.focus = true
            pygpxmap.call("geepeeex.visu_gpx", [polyline], function(result) {
               var t = new Array (0)
               for (var i=0; i<result.length; i++) {
                  pline.addCoordinate(QtPositioning.coordinate(result[i].latitude,result[i].longitude));
               }
               map.center = QtPositioning.coordinate(result[(i/2).toFixed(0)].latitude,result[(i/2).toFixed(0)].longitude); // Center the map on the enter of the track
               refreshmap.visible = false
               refreshmap.running = false
               refreshmap.focus = false
            });
         });
      }//Component.onCompleted
   }

   Map {
      id: map
      anchors.fill: parent
      center: QtPositioning.coordinate(29.62289936, -95.64410114) // Oslo
      zoomLevel: map.maximumZoomLevel - 5
      color: Theme.palette.normal.background
      activeMapType: supportedMapTypes[supportedMapTypes.length-1]  // zero is Street map, only this style for free/hobby plan is allowed, the very last one is custom map
      plugin : Plugin {
            id: plugin
            name: "osm"

            required.mapping: Plugin.AnyMappingFeatures
            required.geocoding: Plugin.AnyGeocodingFeatures

            // for Qt Versions older than 6.7 we need a workaround for the api key to be accepted by adding a &fake=.png at the end
            // https://stackoverflow.com/questions/60544057/qt-qml-map-with-here-plugin-how-to-correctly-authenticate-using-here-token
            PluginParameter {
               name: "osm.mapping.custom.host"
               value: "http://tile.thunderforest.com/" + persistentSettings.mapType + "/%z/%x/%y.png?apikey=" + persistentSettings.myApiKey + "&fake=.png"
            }
            PluginParameter {
               name: "osm.mapping.custom.datacopyright"
               value: "www.osm.org/copyright"
            }
            PluginParameter {
               name: "osm.mapping.custom.mapcopyright"
               value: "www.thunderforest.com"
            }
            PluginParameter {
               name: "osm.mapping.offline.directory"
               value: StandardPaths.writableLocation(StandardPaths.CacheLocation) + "/QtLocation/5.8/tiles/osm"
            }
      }

      MapPolyline {
         id: pline
         line.width: 4
         line.color: 'red'
         path: []
      }
   }

}
