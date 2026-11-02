<?php
declare(strict_types=1);

namespace App\Routing;

use DateTimeImmutable;
use DateTimeZone;
use Illuminate\Support\ServiceProvider;

final class RoutingServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(RoutingSelector::class, static function (): RoutingSelector {
            $start = config('routing.trial_start_utc');
            return new RoutingSelector(
                (string) config('routing.mode'),
                $start ? new DateTimeImmutable((string) $start, new DateTimeZone('UTC')) : null,
                (string) config('routing.after_trial'),
            );
        });
    }
}
