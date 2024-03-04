## Changes v1.0.1
- fixed: map marker now keeps fixed size regardless of map zoom
- improved: editing a track name when saving, now uses the placeholder text as given input
- improved: add word wrap to button text to allow longer translations
- improved: reduced logging in several places
- updated: translations, many thanks to all translators!

## Changes v1.0.0
- new maintainer @danfro
- improved: updated app for focal/20.04
- improved: move translations to ubports hosted weblate (Thanks to Weblate for sponsoring this service!)
- added: sport type SUP and nordic walking
- added: pause option
- fixed: app icon not showing (thanks @ivoxavier)
- improved: cancel recording dialog handling
- improved: now distances in main screen use locale separator
- improved: changelog and readme have been split into two separate files for easier reading
- updated: translations, many thanks to all translators!

## Changes v0.15:
- Update the web library use to Morph.Web
- Update translation

## Changes v0.14:
- Add the possibility to calibrate the altitude,
- Remove JavaScript lib,
- Thanks to the contributors to update translation,
- remove .gpx file when trip is deleted,
- Add Unicycle sport,
- Filter activities by type,

## Changes v0.13:
- Thanks to the contributors to update translation.

## Changes v0.12:
- Improved sport selection
- Missing appname substitution and removed unused images
- Back to appname cwayne18, UX and translation improvements. Updated it.po
- Add features: Importing GPX files from another folder through the contenthub, renaming and changing activity
- Bumping the software revsion to 0.12
- Add GPX info feature next to editing
- Add refresh indicator to load GPX info + some cleanup
- Created proper components to handle useful dialogs
- Code cleanup: Remove metrics, contentPickerDialog & Polyline
- Fixed PositionSource not being closed and code cleaning
- Theme support

## Changes initial Xenial version:
- Add speed and altitude, thanks to https://github.com/cwayne18/ActivityTracker/pull/17
- Update of the QML code
- Uniformise and change the tile service to QML/OSM.
- Implement a routing to parse locally the gpx track
- Allow setting frequency of position recording. (it's adviced to not go below a frequency of 10 or 5 seconds in order to not saturate the GPX file. The more data points it has, the longer it will take to display.)
