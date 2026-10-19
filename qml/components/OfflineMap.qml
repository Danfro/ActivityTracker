import QtQuick 2.12
import Lomiri.Components 1.3
import QtWebEngine 1.10 // for offline map
import Morph.Web 0.1
import QtSystemInfo 5.0

Component {
    WebEngineView {
        id: webview
        anchors.fill: parent
        property var pendingCoords: null
        property var firstCoord: null
        property bool pageReady: false

        settings.localContentCanAccessFileUrls: true
        settings.localContentCanAccessRemoteUrls: true
        settings.javascriptEnabled: true
        settings.webGLEnabled: true

        onJavaScriptConsoleMessage: {
            console.log("[JS] (" + sourceID + ":" + lineNumber + ") " + message);
        }

        onUrlChanged: pageReady = false

        onLoadingChanged: {
            if (loadRequest.status === WebEngineView.LoadStartedStatus) {
                pageReady = false
            } else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                pageReady = false
                console.log("Map page failed to load: " + loadRequest.errorString)
            } else if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                pageReady = true

                if (firstCoord) {
                    webview.runJavaScript("initLiveTrack(" + firstCoord[0] + "," + firstCoord[1] + "," + persistentSettings.initialZoom + ");")
                    firstCoord = null
                }
                if (pendingCoords) {
                    webview.runJavaScript("showTrack(" + JSON.stringify(pendingCoords) + ");")

                    // here set the first point as new initial coord so the next time the map is opened roughly at the last tracks position
                    if (pendingCoords.length > 0) {
                        persistentSettings.initialLat = pendingCoords[0][0]
                        persistentSettings.initialLong = pendingCoords[0][1]
                    }
                    pendingCoords = null
                }
            }
        }

        // show recorded track in Map.qml
        function showTrack(coords) {
            if (!pageReady) {
                pendingCoords = coords
            } else {
                webview.runJavaScript("showTrack(" + JSON.stringify(coords) + ");")
            }
        }

        // clear track and center map in Tracker.qml
        function startTrack(lat, lon) {
            if (!pageReady) {
                firstCoord = [lat, lon]
            } else {
                //add offset to zoom so when starting to record it goes closer in for a more detailed view
                webview.runJavaScript("initLiveTrack(" + lat + "," + lon + "," + (persistentSettings.initialZoom + 4) + ");")
            }
        }

        // remove recorded track from map
        function removeTrack() {
            webview.runJavaScript("removeTrack();")
        }

        // add points while recording in Tracker.qml
        function addTrackPoint(lat, lon) {
            if (pageReady) {
                webview.runJavaScript("addTrackPoint(" + lat + "," + lon + ");")
            }
        }

        // display marker when position is available in Tracker.qml
        function showMarker(lat, lon) {
            if (pageReady) {
                webview.runJavaScript("showMarker(" + lat + "," + lon + ");")
            }
        }

        // center map in Tracker.qml
        function centerOn(lat, lon) {
            if (pageReady) {
                webview.runJavaScript("centerOn(" + lat + "," + lon + ");")
            }
        }

        // only load url once and apply initial settings values
        Component.onCompleted: {
            url = Qt.resolvedUrl("../../offlinemap/mapview.html")
                + "?lat=" + persistentSettings.initialLat
                + "&lon=" + persistentSettings.initialLong
                + "&zoom=" + persistentSettings.initialZoom
        }

        // disable map page when qml page is closed
        Component.onDestruction: pageReady = false
    }
}