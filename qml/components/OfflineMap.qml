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
        property var pendingStart: null

        settings.localContentCanAccessFileUrls: true
        settings.localContentCanAccessRemoteUrls: true
        settings.javascriptEnabled: true
        settings.webGLEnabled: true

        url: Qt.resolvedUrl("../../offlinemap/mapview.html")
            + "?lat=" + persistentSettings.initialLat
            + "&lon=" + persistentSettings.initialLong
            + "&zoom=" + persistentSettings.initialZoom

        onJavaScriptConsoleMessage: {
            console.log("[JS] (" + sourceID + ":" + lineNumber + ") " + message);
        }

        onLoadingChanged: {
            if (!loading) {
                if (pendingStart) {
                    webview.runJavaScript("initLiveTrack(" + pendingStart[0] + "," + pendingStart[1] + ");")
                    pendingStart = null
                }
                if (pendingCoords) {
                    webview.runJavaScript("showTrack(" + JSON.stringify(pendingCoords) + ");")
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
            if (webview.loading) {
                pendingCoords = coords
            } else {
                webview.runJavaScript("showTrack(" + JSON.stringify(coords) + ");")
            }
        }

        // clear track and center map in Tracker.qml
        function startTrack(lat, lon) {
            if (webview.loading) {
                pendingStart = [lat, lon]
            } else {
                webview.runJavaScript("initLiveTrack(" + lat + "," + lon + ");")
            }
        }

        // add points while recording in Tracker.qml
        function addTrackPoint(lat, lon) {
            if (!webview.loading) {
                webview.runJavaScript("addTrackPoint(" + lat + "," + lon + ");")
            }
        }

        // center map in Tracker.qml
        function centerOn(lat, lon) {
            if (!webview.loading) {
                webview.runJavaScript("centerOn(" + lat + "," + lon + ");")
            }
        }
    }
}