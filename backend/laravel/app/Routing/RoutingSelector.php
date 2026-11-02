<?php
declare(strict_types=1);

namespace App\Routing;

use DateTimeImmutable;
use InvalidArgumentException;

/** Deterministic 15+15-day experiment, evaluated in UTC on the server. */
final readonly class RoutingSelector
{
    public function __construct(
        private string $mode,
        private ?DateTimeImmutable $trialStartUtc = null,
        private string $afterTrial = 'osrm',
    ) {}

    public function choose(DateTimeImmutable $nowUtc): string
    {
        if ($this->mode === 'google' || $this->mode === 'osrm') {
            return $this->mode;
        }
        if ($this->mode !== 'trial' || $this->trialStartUtc === null) {
            throw new InvalidArgumentException('Invalid routing mode or missing trial start');
        }
        $days = (int) $this->trialStartUtc->setTime(0, 0)->diff(
            $nowUtc->setTimezone(new \DateTimeZone('UTC'))->setTime(0, 0)
        )->format('%r%a');

        if ($days < 0) {
            throw new InvalidArgumentException('Routing trial has not started');
        }
        if ($days < 15) return 'google';
        if ($days < 30) return 'osrm';
        if (!in_array($this->afterTrial, ['google', 'osrm'], true)) {
            throw new InvalidArgumentException('Invalid post-trial provider');
        }
        return $this->afterTrial;
    }
}
