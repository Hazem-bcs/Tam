# Laravel routing module — integration-ready, NOT a standalone Laravel application

The team's Laravel engineer must integrate these PHP 8.2+ classes into the actual backend and add integration tests.

- **Strategy**: RoutingSelector, with google/osrm/trial modes (first 15 UTC days Google, next 15 days OSRM).
- **Adapters**: GoogleRoutesProvider and OsrmRoutingProvider, sharing a RoutingProvider contract.
- **Normalized result**: RouteResult(distanceMeters, durationSeconds, encodedPolyline, provider).
- **No routing API key is stored in Flutter**.
- **Both providers must pass route safety smoke tests before starting the 30-day trial**.

Sample backend environment configuration (replace date deliberately when launching):
```text
ROUTING_MODE=trial
ROUTING_TRIAL_START_UTC=2026-12-01
ROUTING_AFTER_TRIAL=osrm
GOOGLE_ROUTES_API_KEY=<secret>
OSRM_BASE_URL=http://127.0.0.1:5000
```

Log provider, API latency, errors, Matrix elements, estimated vs actual arrival times, usage and cost, while avoiding raw personal GPS traces in logs. A sequential 15+15-day trial is not randomized A/B testing. Do not silently switch providers during the experiment.
