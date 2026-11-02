<?php
return [
    'mode' => env('ROUTING_MODE', 'osrm'),
    'trial_start_utc' => env('ROUTING_TRIAL_START_UTC'),
    'after_trial' => env('ROUTING_AFTER_TRIAL', 'osrm'),
    'google_api_key' => env('GOOGLE_ROUTES_API_KEY'),
    'osrm_base_url' => env('OSRM_BASE_URL', 'http://127.0.0.1:5000'),
];
