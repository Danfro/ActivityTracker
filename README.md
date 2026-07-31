

# ActivityTracker
This repository is a fork of the [Xenial app version](https://github.com/ernesst/ActivityTracker) by @ernesst and @mymike00, which itself is a fork of the original app created by [@cwayne18](https://github.com/cwayne18/ActivityTracker). Thanks everyone who made this app possible!


Due to older QML lib on the original 15.04 version, the changes couldn't be retrofitted.
The app had been upgraded by Michele and Ernes_t to work on 16.04 Ubuntu Touch. They did develop it up to v0.15.
@Danfro (myself) did now update the app to work on focal and I am still maintaining the app.

Please see the [changelog](https://github.com/Danfro/ActivityTracker/blob/master/CHANGELOG.md) for a detailed list of changes.

## Download
[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/activitytracker.cwayne18)

## General information
 - due to a OS limitation the recording must occur with the screen on, otherwise the app is send to background and can not receive position information anymore
 - the GPX files are located in .local/share/activitytracker.cwayne18/
 - currently the map shows "api key required", this is know and hopefully can be fixed soon

## Map sources
As with version 2.0.0 there are two map sources that can be used with Activity Tracker app:
a) OSMscoutserver free offline maps (default map)
b) Thunderforest maps (api key required)

OSMscoutserver can be installed from OpenStore. Download maps for your area to use them with Activity Tracker.
To find out how to get a Thunderforest api key, please visit their website: [https://manage.thunderforest.com/](https://manage.thunderforest.com/).

To display OSM offline maps, [maplibre 4.7.1](https://github.com/maplibre/maplibre-gl-js/releases/tag/v4.7.1) is used in a WebEngineView. With Qt5 based morph we can't use any more recent version.

_Note: The free Thunderforest map has been discontinued. Thanks to Thunderforest folks for providing it over all the recent years._

## Translations
 This app can be translated on [Hosted Weblate](https://hosted.weblate.org/projects/ubports/activitytracker/). The localization platform of this project is sponsored by Hosted Weblate via their free hosting plan for Libre and Open Source Projects.

We welcome translators from all different languages. Thank you for your contribution!
You can easily contribute to the localization of this project (i.e. the translation into your language) by visiting (and signing up with) the Hosted Weblate service as linked above and start translating by using the webinterface. To add a new language, log into weblate, goto tools --> start new translation.

 ## Thanks
  - Michele for the logo and contributions,
  - Ernesst for all contributions,
  - Joan CiberSheep for the icons,
  - Anne for the French translation: https://github.com/cwayne18/ActivityTracker/pull/14,
  - Wagafo for the Catalan translation,
  - j2g2rp for the Spanish translation,
  - All the contributors on Weblate,
  - Mr-Growl for unicycle sport.
