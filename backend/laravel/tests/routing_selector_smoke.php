<?php
declare(strict_types=1);

require_once __DIR__ . '/../app/Routing/RoutingSelector.php';

use App\Routing\RoutingSelector;

$selector = new RoutingSelector(
    'trial', new DateTimeImmutable('2026-12-01', new DateTimeZone('UTC')), 'osrm'
);
$cases = [
    ['2026-12-01','google'],['2026-12-15','google'],
    ['2026-12-16','osrm'],['2026-12-30','osrm'],['2026-12-31','osrm'],
];
foreach ($cases as [$date, $expected]) {
    $actual = $selector->choose(new DateTimeImmutable($date, new DateTimeZone('UTC')));
    if ($actual !== $expected) {
        fwrite(STDERR, "Wrong provider on $date: $actual vs $expected\n");
        exit(1);
    }
}
echo "Routing selector smoke tests passed\n";
