# TAM map resources

`liberty.json` is the OpenFreeMap Liberty style downloaded from
https://tiles.openfreemap.org/styles/liberty on 2026-11-16. Its upstream is
https://github.com/hyperknot/openfreemap-styles and the Liberty design originates
at https://github.com/maputnik/osm-liberty. See the two bundled license files.
TAM applies its central map theme and localized labels at render time; the
original source, sprite, glyph and attribution metadata remain intact.

`car-top.svg` and `destination.svg` are original vector artwork authored for
TAM in this change. Their `currentColor` follows the application theme. Flutter
renders the car directly in cards; MapLibre uploads each SVG as a native marker
texture once per map style, rather than on each location update.

The `vehicle-*.svg`, `map-select.svg` and `place-pin.svg` resources are also
original TAM artwork, rendered directly as vectors in the location and vehicle
selection interfaces. Vehicles use a consistent three-quarter view with neutral
metal/glass materials and inherited `currentColor` accents. Map icons inherit
their ink through `currentColor` and tonal opacity. Vehicle v2 replaces the older
outline side views; these are actual paths and gradients, with no embedded bitmap.

The default public provider is OpenFreeMap. MapLibre is the renderer and
OpenStreetMap is the underlying map data. Source credits remain accessible from
the map's attribution information button.

To self-host, supply a bundled style under `assets/maps/`, register it as a
Flutter asset, and set `MAP_VECTOR_STYLE_ASSET` centrally. Replace the style's
vector source URL, glyph URL, sprite URL and any active ancillary source URLs
with the hosted services while preserving their required attribution. A style
asset alone does not provide offline map coverage.

Legacy raster deployments must explicitly set `MAP_VECTOR_STYLE_ASSET` to an
empty string and supply `MAP_TILES_URL_TEMPLATE`. A native map failure never
silently switches providers. Search and routing still use the existing
independently configured Maps repository and API contract.
