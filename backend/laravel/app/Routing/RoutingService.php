<?php
declare(strict_types=1);

namespace App\Routing;

use DateTimeImmutable;
use DateTimeZone;

final readonly class RoutingService
{
    public function __construct(
        private RoutingSelector $selector,
        private GoogleRoutesProvider $google,
        private OsrmRoutingProvider $osrm,
    ) {}

    public function current(?DateTimeImmutable $nowUtc = null): RoutingProvider
    {
        $which = $this->selector->choose($nowUtc ?? new DateTimeImmutable('now', new DateTimeZone('UTC')));
        return $which === 'google' ? $this->google : $this->osrm;
    }
}
