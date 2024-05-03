import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import QtPositioning 5.12
import QtLocation 5.12
import "components"

Rectangle {
   id: trackerroot
   property bool openDialog: false
   onOpenDialogChanged: openDialog == true ? PopupUtils.open(sportselect) : ""
   Sports {id:sportsComp}
   color: Theme.palette.normal.background
   width: page1.width
   height: page1.height
   property int altitudeCorrected
   property bool fixedMarker: true

   Component {
      id:sportselect
      SportSelectPopUp {
         sportsComponent: sportsComp
      }
   }

   function start_recording() {
         // loggingpoints.interval = persistentSettings.pointsInterval //useful or not ?
         //listModel.clear()
         if (!src.active){
             src.start()
         }
         timer.start()
         if (src.valid){
             pygpx.create_gpx()
             map.addMapItem(pline)
             map.center = src.position.coordinate
             am_running = true
             is_paused = false
         }
   }

   function pause_recording() {
       if (is_paused) {
           timer.start()
           src.start()
       } else {
           timer.stop()
           src.stop()
       }
       am_running = !am_running
       is_paused = !is_paused
   }

   Page {
      id: newrunPage
      anchors.fill: parent
      header: PageHeader {
         title: (am_running) ? i18n.tr("Activity in Progress") : (is_paused) ? i18n.tr("Paused") : i18n.tr("New Activity")
         leadingActionBar.actions: [
         Action {
                iconName: "down"
                enabled: !(am_running) && !(is_paused)
                onTriggered: newrunEdge.collapse()
         }
         ]

         trailingActionBar.actions: [
            Action {
                iconSource: "../images/"+sportsComp.name[sportsComp.selected]+"-symbolic.svg"
                visible: sportsComp.selected != -1
                onTriggered: PopupUtils.open(sportselect)
            }
            ,Action {
                iconName: fixedMarker ? "gps" : "gps-disabled"
                onTriggered: fixedMarker = !fixedMarker
            }
         ]
      }

      Timer {
         id: timer
         interval: 1000
         running: false
         repeat: true
         onTriggered: {
            counter++
            pygpx.format_timer(counter)
         }
      }

      PositionSource {
         id: src
         updateInterval: 1000
         active: true
         preferredPositioningMethods: PositionSource.SatellitePositioningMethods


         onPositionChanged: {
            var coord = src.position.coordinate;
            count++
            //  console.log("Coordinate:", coord.longitude, coord.latitude);

            // only center position when tracking is active, otherwise allow zoom and pan
            if (fixedMarker) map.center = QtPositioning.coordinate(coord.latitude, coord.longitude)
            circle.coordinate = QtPositioning.coordinate(coord.latitude, coord.longitude)

            if (gpxx && am_running && !is_paused) {
               if (src.position.latitudeValid && src.position.longitudeValid && src.position.altitudeValid) {
                  //pygpx.addpoint(gpxx,coord.latitude,coord.longitude,coord.altitude)
                  altitudeCorrected = coord.altitude + persistentSettings.altitudeOffset
                  pline.addCoordinate(QtPositioning.coordinate(coord.latitude,coord.longitude, altitudeCorrected))
                  pygpx.current_distance(gpxx)
                  distlabel.text = dist
                  // console.warn("========================")
                  //console.warn(pygpx.current_distance(gpxx))
               }
               if (src.position.altitudeValid) {
                  altlabel.text = formatAlt(altitudeCorrected)
               } else {
                  altlabel.text = i18n.tr("No data")
               }
               if (src.position.speedValid) {
                  speedlabel.text = formatSpeed(src.position.speed)
               } else {
                  speedlabel.text = i18n.tr("No data")
               }
            }
         }
      }
      Timer {
         id: loggingpoints
         interval: persistentSettings.pointsInterval; running: true; repeat: true
         onTriggered: {
            var coord = src.position.coordinate
            if (gpxx && am_running){

               if (src.position.latitudeValid && src.position.longitudeValid && src.position.altitudeValid) {
                 altitudeCorrected = coord.altitude + persistentSettings.altitudeOffset
                  pygpx.addpoint(gpxx,coord.latitude,coord.longitude,altitudeCorrected)
                  // console.log("Coordinate:", coord.longitude, coord.latitude)
                  // console.log("calibrated altitude :", altitudeCorrected, "& raw Altitude:", coord.altitude )
               }

            }
         }
      }
      Component.onCompleted: {
         src.start()
      }

      Map {
         id: map
         anchors.fill: parent
         zoomLevel: map.maximumZoomLevel - 2
         color: Theme.palette.normal.background
         plugin : Plugin {
            id: plugin
            allowExperimental: true
            preferred: ["osm"]
            required.mapping: Plugin.AnyMappingFeatures
            required.geocoding: Plugin.AnyGeocodingFeatures
         }

         Component.onCompleted: {
            map.addMapItem(circle)

         }
      }//Map

      MapQuickItem {
         id: circle
         visible: (src.position.latitudeValid && src.position.longitudeValid)
         sourceItem: Rectangle { id: marker; width: 50; height: width; color: "green"; border.width: 3; border.color: "black"; smooth: true; radius: width*1.5 }
         coordinate : src.position.coordinate
         opacity: 0.4
         anchorPoint: Qt.point(marker.width/2, marker.height/2)
      }

      MapPolyline {
         id: pline
         line.width: 4
         line.color: 'red'
         path: []
      }
      Component {
         id: areyousure
         Dialog {
            id: areyousuredialog
            title: i18n.tr("Do you want to cancel the activity?")
            PopUpButton {
               id: yesimsure
               texth: i18n.tr("Yes, stop and discard")
               color: LomiriColors.red
               onClicked: {
                  PopupUtils.close(areyousuredialog)
                  timer.start()
                  counter = 0
                  pygpx.format_timer(0)
                  var distfloat
                  distfloat = parseFloat(dist.slice(0,-2)) //clean up the gpx array but not the maps / path
                  map.removeMapItem(pline)
                  timer.restart()
                  timer.stop()
                  am_running = false
                  sportsComp.reset()
                  newrunEdge.collapse()
               }
            }
            PopUpButton {
               id: noooooooodb
               texth: i18n.tr("No, go back")
               onClicked: {
                  PopupUtils.close(areyousuredialog)
                  PopupUtils.close(dialogue)
                  am_running = true
                  timer.start()
               }
            }
         }
      }
      Component {
         id: dialog
         Dialog {
            id: dialogue
            title: i18n.tr("What would you like to do?")
            PopUpButton {
               texth: i18n.tr("Stop and save track")
               color: LomiriColors.green
               onClicked: {
                  PopupUtils.close(dialogue)

                  //FIXME: do I want to add a point even if gps params aren't valid? I want to add a point here to get the exact time of activity
                  var coord = src.position.coordinate
                  if (gpxx && am_running){
                     if (src.position.latitudeValid && src.position.longitudeValid && src.position.altitudeValid) {
                       altitudeCorrected = coord.altitude + persistentSettings.altitudeOffset
                        pygpx.addpoint(gpxx,coord.latitude,coord.longitude,altitudeCorrected)
                        //pygpx.addpoint(gpxx,coord.latitude,coord.longitude,coord.altitude)
                     }
                  }
                  src.stop()
                  am_running = false
                  timer.stop()
                  PopupUtils.open(save_dialog)
               }
            }
            PopUpButton {
               texth: i18n.tr("Stop and discard track")
               color: LomiriColors.red
               onClicked: {
                   PopupUtils.close(dialogue) // close dialogue regardless of later choice
                   PopupUtils.open(areyousure) // show confirmation dialog
               }
            }
            PopUpButton {
               texth: i18n.tr("Nothing, go back")
               onClicked: PopupUtils.close(dialogue)
            }
         }
      }//Dialog component

      Component {
         id: save_dialog
         ActivityDialog {
            id: save_dialogue
            sportsComponent: sportsComp
            title: i18n.tr("Select the type and the name of your activity")
            save.onClicked: {
               PopupUtils.close(save_dialogue)
               pygpx.writeit(gpxx,trackName,sportsComponent.name[sportsComponent.selected])
               console.log(trackName)
               // console.log("----------restart------------")
               // counter & timer stuff used only here in Tracker -> why? FIXME
               counter = 0
               pygpx.format_timer(0)
               timer.restart()
               timer.stop()
               map.removeMapItem(pline)
               //  listModel.append({"name": tf.displayText, "act_type": sportsComp.name[sportsComp.selected]})
               //   pygpx.addrun(tf.displayText)
               listModel.clear()
               // distfloat stuff used only here in Tracker -> why? FIXME
               var distfloat
               distfloat = parseFloat(dist.slice(0,-2))
               pygpx.get_runs(listModel)
               newrunEdge.collapse()
               newrunEdge.preloadContent = false
               newrunEdge.contentUrl = ""
               newrunEdge.contentUrl = Qt.resolvedUrl("Tracker.qml")
            }
            cancel.onClicked: {
               PopupUtils.close(save_dialogue)
               am_running = true
               timer.start()
               sportsComp.selected=sportsComp.previous
            }
         }
      }

       Button {
          id: floatingPauseButton
          visible: !is_paused & am_running
          anchors.bottom: dataRect.top
          anchors.bottomMargin: units.gu(2)
          anchors.horizontalCenter: dataRect.horizontalCenter
          height: units.gu(8)
          implicitWidth: units.gu(10)
          text: i18n.tr("Pause")
          z: parent.z + 1
          onClicked: pause_recording()
      }

      Rectangle {
          id: floatingWaitingForFixRect
          visible: !(src.position.latitudeValid && src.position.longitudeValid)
          anchors.bottom: dataRect.top
          anchors.bottomMargin: units.gu(2)
          anchors.horizontalCenter: dataRect.horizontalCenter
          height: units.gu(4)
          width: parent.width - units.gu(4)
          color: theme.palette.normal.base
          radius: 30
          Label {
            text: i18n.tr("Waiting for position...")
            anchors.centerIn: parent
          }
          z: parent.z + 1
      }

        Rectangle {
            id: dataRect
            width: parent.width
            height: units.gu(14)
            // z:100
            anchors.bottom: parent.bottom
            color: theme.palette.normal.background
            opacity: 0.8
            property var marginsize: units.gu(2)
            property var availableWidth: dataRect.width - (5 * marginsize) // full width minus 5 times the spacing of the layout

            Column {
                id: leftColumn
                anchors.left: parent.left
                anchors.leftMargin: dataRect.marginsize
                bottomPadding: units.gu(3.5)
                topPadding: units.gu(1)
                width: dataRect.availableWidth / 3
                Label {
                   text: "Time"
                   //fontSize: "small"
                }
                Label {
                   text: timestring
                   fontSize: "large"
                   //text: "00:00"
                }
                Label {
                   text: "Speed"
                   fontSize: "small"
                }
                Label {
                   id: speedlabel
                   text: "No data"
                   fontSize: "large"
                }
            }
            Column {
                id: buttonColumn
                anchors.horizontalCenter: parent.horizontalCenter
                bottomPadding: units.gu(3.5)
                topPadding: units.gu(1)
                width: dataRect.availableWidth / 3
                Button {
                   id: startButton
                   anchors.horizontalCenter: parent.horizontalCenter
                   text: is_paused ? i18n.tr("Resume") : i18n.tr("Start")
                   color: LomiriColors.green
                   visible: !am_running
                   height: units.gu(10)
                   onClicked: is_paused ? pause_recording() : start_recording()
                }
                Button {
                   id: stopButton
                   anchors.horizontalCenter: parent.horizontalCenter
                   text: i18n.tr("Stop")
                   color: LomiriColors.red
                   visible:am_running
                   height: startButton.height
                   width: startButton.width
                   onClicked: PopupUtils.open(dialog)
                }//Button
            }

            Column {
                id: rightColumn
                anchors.left: buttonColumn.right
                anchors.leftMargin: buttonColumn.marginsize
                bottomPadding: units.gu(3.5)
                topPadding: units.gu(1)
                width: dataRect.availableWidth / 3
                Label {
                    text: "Distance"
                    //fontSize: "small"
                }
                Label {
                    id: distlabel
                    text: "0"
                    fontSize: "large"
                }
                Label {
                    text: "Altitude"
                    //  fontSize: "small"
                }
                Label {
                   id: altlabel
                    text: "No data"
                    fontSize: "large"
                }
            }

            Row {
                id: copyrightNotice
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                width: parent.width
                height: units.gu(2)
                Label {
                    id: mapText
                    text: "Map © "
                }
                Label {
                    id: thunderforest
                    text: "www.thunderforest.com"
                    color: theme.palette.normal.activity
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally('https://www.thunderforest.com/')
                    }
                }
                Label {
                    text: " | "
                }
                Label {
                    id: dataText
                    text: "Data © "
                }
                Label {
                    id: osm
                    text: "www.osm.org/copyright"
                    color: theme.palette.normal.activity
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally('https://www.osm.org/copyright')
                    }
                }
            }
        }
    }
}
