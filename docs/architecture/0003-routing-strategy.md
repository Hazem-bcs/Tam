# ADR 0003 — Swap routing provider without Flutter changes

**Decision:** Laravel owns Google Routes and self-hosted OSRM calls. The Google Maps SDK rendering layer and Places search are separate choices. Flutter receives the same normalized route and driver ETA schema regardless of routing provider.

`RoutingProvider` (Strategy contract), `GoogleRoutesProvider` and `OsrmRoutingProvider` (Adapters), `RoutingSelector` (server-side experiment).

- `google` and `osrm` select explicitly.
- `trial`: 15 complete UTC days Google, 15 complete UTC days OSRM, then explicitly configured stable fallback.
- Cannot start until both providers and Google commercial terms have been tested.
- Do not cache Google Routes data beyond applicable license terms or import Google road data into OSRM.
- Track outcomes by provider: p50/p95 API latency, route validity, ETA accuracy, cost per route/matrix element, and errors.
- Keep server-assigned route authority; app does not calculate authoritative fares.
- A 15/15 sequential trial is useful operationally, but subject to day-of-week, supply, weather and demand confounders.
