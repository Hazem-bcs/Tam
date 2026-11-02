<?php
declare(strict_types=1);

namespace App\Routing;

use Illuminate\Support\Facades\Http;
use RuntimeException;

final class OsrmRoutingProvider implements RoutingProvider
{
    public function name(): string { return 'osrm'; }

    public function route(array $origin, array $destination): RouteResult
    {
        $coords = self::coord($origin) . ';' . self::coord($destination);
        $response = Http::timeout(12)->get($this->base() . '/route/v1/driving/' . $coords, [
            'overview' => 'full',
            'geometries' => 'polyline',
            'steps' => 'false',
        ]);
        if (!$response->successful()) throw new RuntimeException('OSRM HTTP ' . $response->status());
        $r = $response->json('routes.0');
        if ($response->json('code') !== 'Ok' || !is_array($r)) {
            throw new RuntimeException('OSRM returned no usable route');
        }
        return new RouteResult(
            (int) round((float) $r['distance']),
            (int) round((float) $r['duration']),
            (string) $r['geometry'],
            $this->name(),
        );
    }

    public function matrix(array $drivers, array $pickup): array
    {
        if (!$drivers || count($drivers) > 20) throw new \InvalidArgumentException('Matrix candidates must be 1..20');
        $points = array_merge($drivers, [$pickup]);
        $coords = implode(';', array_map(self::coord(...), $points));
        $response = Http::timeout(12)->get($this->base() . '/table/v1/driving/' . $coords, [
            'sources' => implode(';', array_keys($drivers)),
            'destinations' => (string) count($drivers),
            'annotations' => 'duration,distance',
        ]);
        if (!$response->successful() || $response->json('code') !== 'Ok') {
            throw new RuntimeException('OSRM Matrix unavailable');
        }
        $durations = $response->json('durations');
        $distances = $response->json('distances');
        $out = [];
        foreach (array_keys($drivers) as $i) {
            $duration = $durations[$i][0] ?? null;
            $distance = $distances[$i][0] ?? null;
            $out[] = $duration === null || $distance === null ? null : [
                'distance_meters' => (int) round((float) $distance),
                'duration_seconds' => (int) round((float) $duration),
            ];
        }
        return $out;
    }

    private function base(): string
    {
        return rtrim((string) config('routing.osrm_base_url'), '/');
    }

    private static function coord(array $point): string
    {
        return $point[1] . ',' . $point[0]; // OSRM longitude,latitude
    }
}
