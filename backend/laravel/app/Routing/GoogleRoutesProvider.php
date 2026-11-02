<?php
declare(strict_types=1);

namespace App\Routing;

use Illuminate\Support\Facades\Http;
use RuntimeException;

final class GoogleRoutesProvider implements RoutingProvider
{
    private const ROOT = 'https://routes.googleapis.com/directions/v2';

    public function name(): string { return 'google'; }

    public function route(array $origin, array $destination): RouteResult
    {
        $response = Http::timeout(12)->withHeaders([
            'X-Goog-Api-Key' => (string) config('routing.google_api_key'),
            'X-Goog-FieldMask' => 'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline',
        ])->post(self::ROOT . ':computeRoutes', [
            'origin' => self::waypoint($origin),
            'destination' => self::waypoint($destination),
            'travelMode' => 'DRIVE',
            'routingPreference' => 'TRAFFIC_UNAWARE',
            'polylineQuality' => 'HIGH_QUALITY',
        ]);
        if (!$response->successful()) throw new RuntimeException('Google Routes HTTP ' . $response->status());
        $r = $response->json('routes.0');
        if (!is_array($r) || !isset($r['distanceMeters'], $r['duration'], $r['polyline']['encodedPolyline'])) {
            throw new RuntimeException('Google Routes returned no usable route');
        }
        return new RouteResult(
            (int) $r['distanceMeters'],
            (int) round((float) rtrim((string) $r['duration'], 's')),
            (string) $r['polyline']['encodedPolyline'],
            $this->name(),
        );
    }

    public function matrix(array $drivers, array $pickup): array
    {
        if (!$drivers || count($drivers) > 20) throw new \InvalidArgumentException('Matrix candidates must be 1..20');
        $response = Http::timeout(12)->withHeaders([
            'X-Goog-Api-Key' => (string) config('routing.google_api_key'),
            'X-Goog-FieldMask' => 'originIndex,destinationIndex,distanceMeters,duration,status,condition',
        ])->post(self::ROOT . ':computeRouteMatrix', [
            'origins' => array_map(static fn (array $point) => ['waypoint' => self::waypoint($point)], $drivers),
            'destinations' => [['waypoint' => self::waypoint($pickup)]],
            'travelMode' => 'DRIVE',
            'routingPreference' => 'TRAFFIC_UNAWARE',
        ]);
        if (!$response->successful()) throw new RuntimeException('Google Matrix HTTP ' . $response->status());
        $rows = $response->json();
        if (!is_array($rows)) throw new RuntimeException('Invalid Google Matrix response');
        $result = array_fill(0, count($drivers), null);
        foreach ($rows as $r) {
            if (!is_array($r) || !isset($r['originIndex'], $r['duration'], $r['distanceMeters'])) continue;
            if (isset($r['status']['code']) && $r['status']['code'] !== 0) continue;
            $i = (int) $r['originIndex'];
            if (!array_key_exists($i, $result)) continue;
            $result[$i] = [
                'distance_meters' => (int) $r['distanceMeters'],
                'duration_seconds' => (int) round((float) rtrim((string) $r['duration'], 's')),
            ];
        }
        return $result;
    }

    private static function waypoint(array $point): array
    {
        return ['location' => ['latLng' => [
            'latitude' => $point[0],
            'longitude' => $point[1],
        ]]];
    }
}
