<?php
declare(strict_types=1);

namespace App\Routing;

/** Transport-neutral routing contract. Points are [lat, lng] (not GeoJSON order). */
interface RoutingProvider
{
    /** @param array{0:float,1:float} $origin @param array{0:float,1:float} $destination */
    public function route(array $origin, array $destination): RouteResult;

    /** @param array<int,array{0:float,1:float}> $drivers @param array{0:float,1:float} $pickup
     * @return array<int,array{distance_meters:int,duration_seconds:int}|null>
     */
    public function matrix(array $drivers, array $pickup): array;

    public function name(): string;
}
