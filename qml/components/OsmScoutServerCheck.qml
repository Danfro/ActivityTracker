// helper item to check if OSMscoutserver is available at all
import QtQuick 2.12

Item {
    id: checker

    // Wird nach Abschluss der Prüfung gefeuert
    signal checkFinished(bool available)

    property int timeoutMs: 3000
    property bool checking: false

    function check() {
        if (checking) return
        checking = true

        var xhr = new XMLHttpRequest()
        var finished = false

        var timeoutTimer = Qt.createQmlObject(
            'import QtQuick 2.12; Timer { interval: ' + timeoutMs + '; running: true; repeat: false }',
            checker
        )

        function finish(result) {
            if (finished) return
            finished = true
            checking = false
            timeoutTimer.stop()
            timeoutTimer.destroy()
            checkFinished(result)
        }

        timeoutTimer.triggered.connect(function() {
            xhr.abort()
            finish(false)
        })

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                finish(xhr.status === 200)
            }
        }

        xhr.open("GET", "http://localhost:8553/v1/activate")
        xhr.send()
    }
}