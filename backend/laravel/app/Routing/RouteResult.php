<?php
declare(strict_types=1);

namespace App\Routing;

final readonly class RouteResult
{
    public function __construct(
        public int $distanceMeters,
        public int $durationSeconds,
        public string $encodedPolyline,
        public string $provider,
    ) {}
}
