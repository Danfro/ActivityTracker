{{/*  get start coordinates from url parameters, use 0,0 if no valid coords are given  */}}
var params = new URLSearchParams(window.location.search);
var initialLat = parseFloat(params.get('lat'));
var initialLon = parseFloat(params.get('lon'));
var initialZoom = parseInt(params.get('zoom'));

var hasValidStart = !isNaN(initialLat) && !isNaN(initialLon);

{{/*  use latest 4.x maplibre, newer versions fail with our morph browser
used currently: https://github.com/maplibre/maplibre-gl-js/releases?page=8#release-v4.7.1
available styles: mc-car, mc, osmbright, osmbright-car  */}}
var map = new maplibregl.Map({
    container: 'map',
    style: 'http://localhost:8553/v1/mbgl/style?style=osmbright',
    center: hasValidStart ? [initialLon, initialLat] : [0,0],
    zoom: initialZoom
});

var trackReady = false;
var pendingCoords = null;
var liveCoords = [];

map.on('load', function () {

    map.addSource('track', {
        type: 'geojson',
        data: { type: 'Feature', geometry: { type: 'LineString', coordinates: [] } }
    });

    map.addLayer({
        id: 'track-line',
        type: 'line',
        source: 'track',
        paint: { 'line-color': '#ff0000', 'line-width': 4 }
    });

    trackReady = true;

    // only draw track when coords are available, loading may take some time, so skip on empty values
    if (pendingCoords) {
        drawTrack(pendingCoords);
        pendingCoords = null;
    }

    increaseTextSize(2.25);
});

// plot existing track, called from qml-side
function showTrack(coords) {
    if (trackReady) {
        drawTrack(coords);
    } else {
        pendingCoords = coords;
    }
}

// track live coords and draw track line, called from qml-side
function initLiveTrack(lat, lon, zoom) {
    liveCoords = [[lon, lat]];
    if (trackReady) {
        map.getSource('track').setData({
        type: 'Feature',
        geometry: { type: 'LineString', coordinates: liveCoords }
        });
        map.setCenter([lon, lat]);
        map.setZoom(zoom);

        ensureCenterMarker();

        map.getSource('center-point').setData({
            type: 'Feature',
            geometry: { type: 'Point', coordinates: [lon, lat] }
        });
    }
}

// add track points to screen, called from qml-side
function addTrackPoint(lat, lon) {
    liveCoords.push([lon, lat]);
    if (trackReady) {
        map.getSource('track').setData({
            type: 'Feature',
            geometry: { type: 'LineString', coordinates: liveCoords }
        });
    }
}

// center current position on screen, called from qml-side
function centerOn(lat, lon) {
    map.setCenter([lon, lat]);
    if (map.getSource('center-point')) {
        map.getSource('center-point').setData({
            type: 'Feature',
            geometry: { type: 'Point', coordinates: [lon, lat] }
        });
    }
}

// tool function to draw track while it is recorded
function drawTrack(coords) {
    var lineCoords = coords.map(function (c) { return [c[1], c[0]]; });
    map.getSource('track').setData({
        type: 'Feature',
        geometry: { type: 'LineString', coordinates: lineCoords }
    });
    if (lineCoords.length > 0) {
        var bounds = lineCoords.reduce(function (b, c) {
            return b.extend(c);
        }, new maplibregl.LngLatBounds(lineCoords[0], lineCoords[0]));
        map.fitBounds(bounds, { padding: 250 });
    }
}

// increase text size, because map style default size is too small
function increaseTextSize(factor) {
    var layers = map.getStyle().layers;
    for (var i = 0; i < layers.length; i++) {
        var layer = layers[i];
        if (layer.type !== 'symbol') continue;

        var currentSize = map.getLayoutProperty(layer.id, 'text-size');
        var newSize = scaleTextSize(currentSize, factor);
        if (newSize === undefined) continue;

        map.setLayoutProperty(layer.id, 'text-size', newSize);
    }
}

// handle different server side text implementations, called in increaseTextSize above
function scaleTextSize(currentSize, factor) {
    //skip on empty values
    if (currentSize === undefined || currentSize === null) return undefined;

    // simple constant factor for numbers
    if (typeof currentSize === 'number') {
        return currentSize * factor;
    }

    // expression-style return value, e.g. ["interpolate", ...]
    if (Array.isArray(currentSize)) {
        return ['*', currentSize, factor];
    }

    // old "stops"-functions, e.g. { stops: [[10, 10], [16, 14]] }
    if (typeof currentSize === 'object' && Array.isArray(currentSize.stops)) {
        var scaled = Object.assign({}, currentSize);
        scaled.stops = currentSize.stops.map(function (stop) {
            var zoomKey = stop[0];
            var value = stop[1];
            return [zoomKey, typeof value === 'number' ? value * factor : value];
        });
        return scaled;
    }

    // unknown type keep unchanged
    return currentSize;
}

// create position marker for live tracking
function ensureCenterMarker() {
    if (map.getSource('center-point')) return; // skip if marker already exits

    // define geometrical map position as source for the marker
    map.addSource('center-point', {
        type: 'geojson',
        data: {
            type: 'Feature',
            geometry: { type: 'Point', coordinates: map.getCenter().toArray() }
        }
    });

    // the actual position marker as circle with border
    map.addLayer({
        id: 'center-circle',
        type: 'circle',
        source: 'center-point',
        paint: {
            'circle-radius': 20,
            'circle-color': 'rgba(62, 179, 79, 0.4)',
            'circle-stroke-color': 'rgba(0, 0, 0, 0.4)',
            'circle-stroke-width': 3
        }
    });
}