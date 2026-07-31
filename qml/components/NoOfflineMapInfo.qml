import QtQuick 2.9
import Lomiri.Components 1.3

Page {
    id: warning_root

    header: PageHeader {
        id: main_header

        title: i18n.tr("Offline map unavailable!")
        StyleHints {backgroundColor: top_back_color; foregroundColor: top_text_color}
        leadingActionBar.actions: []
    }

    Flickable {
        anchors {
            top: main_header.bottom
            left: parent.left
            right: parent.right
            bottom: ok_button.top
            bottomMargin: units.gu(1)
        }

        contentHeight: warning_text.height + units.gu(2)


        Label {
            id: warning_text

            anchors {
                top: parent.top
                topMargin: units.gu(2)
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - units.gu(4)

            //Warning Label, changes need to go to: /Timer/ui/About.qml, README.md and OpenStore description text
            text: i18n.tr("Thunderforest free map has been discontinued. (Btw. thanks for providing folks!)")
                  + "\n\n"
                  + i18n.tr("Activity Tracker does now default to free OSMscoutserver offline OSM maps.")
                  + "\n\n"
                  + i18n.tr("It looks like there is no OSMscoutserver offline map available.")
                  + "\n\n"
                  + i18n.tr("You have two options to use this app:")
                  + "\n\n"
                  + i18n.tr("a) Install OSMscoutserver and download offline maps")
                  + "\n\n"
                  + i18n.tr("b) Aquire a Thunderforest API key for their online maps")
            wrapMode: Text.WordWrap
        }
    }

    Button {
        id: ok_button

        color: theme.palette.normal.positive
        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(2)
            horizontalCenter: parent.horizontalCenter
        }
        text: i18n.tr("OK, I understand")
        onClicked: {
            apl_main.removePages(primaryPage)
            warningVisible = false
        }
    }
}
