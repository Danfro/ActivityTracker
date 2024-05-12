import QtQuick 2.12 as QQC
import QtSystemInfo 5.0
import QtLocation 5.3
import Lomiri.Components 1.3
import Lomiri.Components.ListItems 1.3 as LI
import Lomiri.Components.Popups 1.3
import Lomiri.Components.Pickers 1.3
import Qt.labs.folderlistmodel 2.1 //for FolderListModel
import Qt.labs.platform 1.0 //for StandardPaths


Page {
    id: settings
    header: PageHeader {
        id: settingsHeader
        title: i18n.tr("Settings")

        trailingActionBar.actions: [
                Action {
                    text: i18n.tr("About")
                    iconName: "info"
                    onTriggered: stack.push(Qt.resolvedUrl("About.qml"))
                }
            ]
    }

    QQC.Flickable {
        id: settingsFlickable
        clip: true
        flickableDirection: QQC.Flickable.AutoFlickIfNeeded
        boundsBehavior: QQC.Flickable.StopAtBounds

        anchors {
            topMargin: settingsHeader.height
            bottomMargin: units.gu(2)
            fill: parent
        }

        contentHeight: settingsColumn.childrenRect.height

        QQC.Column {
            id: settingsColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            LI.ItemSelector {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                divider.visible: true
                text: i18n.tr("Distance unit:")
                model: [i18n.tr("Kilometers"), i18n.tr("Miles")]
                property var units_id: ["kilometers", "miles"]
                expanded: false
                selectedIndex: switch(runits) {case "kilometers": return 0; case "miles": return 1;}
                onSelectedIndexChanged: {
                console.warn("changed distance unit to: "+units_id[selectedIndex])
                runits=units_id[selectedIndex]
                pygpx.set_units(units_id[selectedIndex])
                }
            }

            LI.Divider {
                height: units.gu(0.1)
            }

            ListItem {
                divider.visible: true
                height: pointsIntervalLayout.height
                ListItemLayout {
                    id: pointsIntervalLayout
                    title.text: i18n.tr("Log a point every:")
                    // subtitle.text: Qt.formatDateTime(date, "ss")
                    summary.text: i18n.tr("between 50 and 3600000")
                    TextField {
                        id: pointsIntervalField
                        // text: persistentSettings.pointsInterval/1000
                        color: !acceptableInput ? LomiriColors.red : theme.palette.normal.backgroundText
                        placeholderText: "5000"
                        inputMethodHints: Qt.ImhDigitsOnly //Qt.ImhFormattedNumbersOnly
                        hasClearButton:false
                        // double validator not working
                        // validator: DoubleValidator {bottom:0.05; top:3600; /*decimals:2; notation: DoubleValidator.StandardNotation*/}//50ms -1h
                        validator: QQC.IntValidator {
                            bottom:50;
                            top:3600000;
                        }//50ms -1h
                        width: units.gu(length>0?length:placeholderText.length)+units.gu(2.75)
                        SlotsLayout.position:SlotsLayout.Trailing
                        onTextChanged: {
                            if (acceptableInput)
                                persistentSettings.pointsInterval = text/**1000*/ | 0
                            else if (length==0)
                                persistentSettings.pointsInterval = 5000 //default value
                        }
                        QQC.Component.onCompleted: text = persistentSettings.pointsInterval///1000
                    }
                    Label {
                        // TRANSLATORS: millisecond abbreviation
                        text:i18n.tr("ms");
                        SlotsLayout.position:SlotsLayout.Last;
                    }
                }
            }

            ListItem {
                divider.visible: true
                height: altitudeOffsetLayout.height
                width: parent.width
                ListItemLayout {
                    id: altitudeOffsetLayout
                    title.text: i18n.tr("Altitude offset:")
                    summary.text: i18n.tr("between -100 and 100")
                    TextField {
                        id: altitudeOffsetField
                        color: !acceptableInput ? LomiriColors.red : theme.palette.normal.backgroundText
                        placeholderText: "0"
                        inputMethodHints: Qt.ImhDigitsOnly
                        hasClearButton:false
                        validator: QQC.IntValidator {
                            bottom:-100;
                            top:100;
                        }
                        width: units.gu(length>0?length:placeholderText.length)+units.gu(2.75)
                        SlotsLayout.position:SlotsLayout.Trailing
                        onTextChanged: {
                            if (acceptableInput)
                                persistentSettings.altitudeOffset = text | 0
                            else if (length==0)
                                persistentSettings.altitudeOffset = 0 //default value
                        }
                        QQC.Component.onCompleted: text = persistentSettings.altitudeOffset
                    }
                    Label {
                        text:i18n.tr("meter(s)");
                        SlotsLayout.position:SlotsLayout.Last;
                    }
                }
            }

            ListItem {
                divider.visible: false
                height: apiKeyLayout.height
                width: parent.width
                ListItemLayout {
                    id: apiKeyLayout
                    QQC.Column {
                        width: parent.width
                        spacing: units.gu(1)
                        QQC.Row {
                            // anchors.horizontalCenter: parent.horizontalCenter
                            visible: !persistentSettings.myApiKey
                            spacing: units.gu(1)
                            height: units.gu(4)
                            width: parent.width
                            TextField {
                                id: apiKeyInput
                                width: parent.width - units.gu(19) // 3 units for the icon width, 2 unit for the spacing, 8 units for the apply button,  4 units for parent margins (why needed?)
                                placeholderText: i18n.tr("Enter API key")
                                hasClearButton: true
                                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                                echoMode: QQC.TextInput.Password
                                onTextChanged: {
                                    if (apiKeyInput.length == 0) showPassword.enabled = false
                                    else showPassword.enabled = true
                                    if (apiKeyInput.length == 32) applyButton.enabled = true
                                    else applyButton.enabled = false
                                }
                            }
                            Icon {
                                id: showPassword
                                anchors.verticalCenter: parent.verticalCenter
                                width: units.gu(3)
                                height: width
                                enabled: false
                                color: theme.palette.normal.backgroundText
                                opacity: enabled ? 1.0 : 0.6
                                name: "view-on"
                                QQC.MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (apiKeyInput.echoMode == QQC.TextInput.Password) {
                                            apiKeyInput.echoMode = QQC.TextInput.Normal
                                            showPassword.name = "view-off"
                                        } else {
                                            apiKeyInput.echoMode = QQC.TextInput.Password
                                            showPassword.name = "view-on"
                                        }
                                        apiKeyInput.forceActiveFocus()
                                    }
                                }
                            }
                            Button {
                                id: applyButton
                                enabled: false
                                width: units.gu(10)
                                text: i18n.tr("Apply")
                                onClicked: {
                                    persistentSettings.myApiKey = apiKeyInput.text
                                    mapTypeSelector.enabled = true
                                    mapTypeSelector.selectedIndex = 2
                                }
                            }
                        }
                        Button {
                            id: clearApiKeyButton
                            visible: persistentSettings.myApiKey
                            text: i18n.tr("Clear API key")
                            onClicked: {
                                persistentSettings.myApiKey = ""
                                mapTypeSelector.selectedIndex = 0
                                mapTypeSelector.enabled = false
                            }
                        }
                    }
                }
            }

            LI.ItemSelector {
                id: mapTypeSelector
                enabled: persistentSettings.myApiKey
                anchors {
                    left: parent.left
                    right: parent.right
                }
                text: persistentSettings.myApiKey ? i18n.tr("Select map type:") : i18n.tr("API key required for other map types")
                model: [
                    i18n.tr("Free Thunderforest OSM street map"),
                    i18n.tr("Thunderforest cycle map"),
                    i18n.tr("Thunderforest landscape map"),
                    i18n.tr("Thunderforest outdoors map"),
                    i18n.tr("Thunderforest transport map"),
                    i18n.tr("Thunderforest transport-dark map"),
                    i18n.tr("Thunderforest spinal map"),
                    i18n.tr("Thunderforest pioneer map"),
                    i18n.tr("Thunderforest atlas map"),
                    i18n.tr("Thunderforest mobile atlas map"),
                    i18n.tr("Thunderforest neighbourhood map")
                ]
                property var map_id: [
                    "free",
                    "cycle",
                    "landscape",
                    "outdoors",
                    "transport",
                    "transport-dark",
                    "spinal-map",
                    "pioneer",
                    "atlas",
                    "mobile-atlas",
                    "neighbourhood"
                ]
                expanded: false
                selectedIndex: switch(persistentSettings.mapType) {
                    case "free": return 0;
                    case "cycle": return 1;
                    case "landscape": return 2;
                    case "outdoors": return 3;
                    case "transport": return 4;
                    case "transport-dark": return 5;
                    case "spinal-map": return 6;
                    case "pioneer": return 7;
                    case "atlas": return 8;
                    case "mobile-atlas": return 9;
                    case "neighbourhood": return 10;
                }
                onSelectedIndexChanged: {
                    console.log("changed map to: " + map_id[selectedIndex])
                    persistentSettings.mapType = map_id[selectedIndex]
                    /*
                    map tiles get cached, the cached tile will be displayed and only tiles for new areas will be loaded
                    when changing the map type, it is needed to clear those cached map tiles to enforce tiles to get reloaded with the new style
                    delete the cached files one by one using the python os module
                    we could just delete the folder, but some cached files are used while the app is running
                    by deleting files one by one there should be a write lock on used files
                    */
                    console.log("start clearing cached tiles")
                    if (folderModel.count > 0) {
                        for (var i = 0; i < folderModel.count; i ++) {
                            pygpx.call('os.remove', [folderModel.get (i, "fileURL").toString().replace("file://","")], function (result) {
                            //TODO: add error handling
                            });
                            if (i == folderModel.count-1) {
                                console.log("finished clearing %1 cached tiles".arg(i))
                            }
                        }
                    }
                }
                QQC.Component.onCompleted: if (!persistentSettings.myApiKey) selectedIndex = 0  //without api key only free map is available
            }

            QQC.Column {
                id: mapsLink
                anchors.left: parent.left
                anchors.margins: units.gu(2)
                width: parent.width
                spacing: units.gu(1)

                Label {
                    id: thanksLabel
                    text: "\n" + i18n.tr("A big thanks to Thunderforest.com for providing the free map!")
                    font.bold: true
                    width: parent.width - units.gu(4)
                    wrapMode: QQC.Text.WordWrap
                    visible: persistentSettings.mapType == "free"
                }

                Label {
                    id: restartAppNote
                    text: "\n" + i18n.tr("After changing the map type, please restart the app for the changes to be applied. Otherwise cached map tiles of the map type used before may be displayed.")
                    font.italic: true
                    color: theme.palette.normal.negative
                    width: parent.width - units.gu(4)
                    wrapMode: QQC.Text.WordWrap
                }
                Label {
                    id: noAPIvalidationNote
                    text: "\n" + i18n.tr("Note: If the map comes up black, the API key might be wrong.")
                    font.italic: true
                    width: parent.width - units.gu(4)
                    wrapMode: QQC.Text.WordWrap
                }
                Label {
                    id: apiKeyDescription
                    text: "\n" + i18n.tr("Please get your own API key:")
                }
                Label {
                    id: apiKeylink
                    text: "https://manage.thunderforest.com/"
                    color: theme.palette.normal.activity
                    wrapMode: QQC.Text.WordWrap
                    QQC.MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally('https://manage.thunderforest.com/')
                    }
                }
                Label {
                    id: mapTypeDescription
                    text: "\n" + i18n.tr("Description of map types:")
                }
                Label {
                    id: mapTypeDescriptionlink
                    text: "https://www.thunderforest.com/maps/"
                    color: theme.palette.normal.activity
                    wrapMode: QQC.Text.WordWrap
                    QQC.MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally('https://www.thunderforest.com/maps/')
                    }
                }
            }
        }
    }

    //used to read all files from the apps .cache folder
    FolderListModel {
        id: folderModel
        folder: StandardPaths.writableLocation(StandardPaths.CacheLocation) + "/QtLocation/5.8/tiles/osm"
        nameFilters: ["*.qmlc","*.jsc","*.png"]
        showDirs: false
    }
}
