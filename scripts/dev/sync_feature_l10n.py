#!/usr/bin/env python3
"""Merge owned ARB fragments into Flutter's existing localization input files."""
import argparse
import json
from pathlib import Path

PREFIXES = {
    'home': 'home', 'ride_request': 'rideRequest', 'trips': 'trips',
    'notifications': 'notifications', 'settings': 'settings', 'addresses': 'addresses',
    'active_trip': 'activeTrip', 'chat': 'chat',
    'completion': 'completion', 'support': 'support',
}


def load(path, locale):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError(f'{path}: duplicate key {key}')
            result[key] = value
        return result
    data = json.loads(path.read_text(), object_pairs_hook=unique)
    if not isinstance(data, dict) or data.get('@@locale') != locale:
        raise ValueError(f'{path}: expected @@locale={locale}')
    return data


def messages(data):
    return {key for key in data if not key.startswith('@')}


def merged(project):
    outputs = {}
    for locale in ('ar', 'en'):
        data = load(project / f'l10n/base/app_{locale}.arb', locale)
        for feature, prefix in PREFIXES.items():
            path = project / f'lib/features/{feature}/l10n/app_{locale}.arb'
            fragment = load(path, locale)
            for key, value in fragment.items():
                if key == '@@locale':
                    continue
                message = key[1:] if key.startswith('@') else key
                if not (message.startswith(prefix) and len(message) > len(prefix)
                        and message[len(prefix)].isupper()):
                    raise ValueError(f'{path}: {key} must use namespace {prefix}')
                if key.startswith('@') and message not in fragment:
                    raise ValueError(f'{path}: metadata without message: {key}')
                if not key.startswith('@') and not isinstance(value, str):
                    raise ValueError(f'{path}: {key} must be a string')
                if key in data:
                    raise ValueError(f'{path}: key already owned elsewhere: {key}')
                data[key] = value
        outputs[locale] = data
    if messages(outputs['ar']) != messages(outputs['en']):
        raise ValueError('Arabic and English message keys must match')
    return outputs


def sync(project, check=False):
    outputs = merged(project)  # Validate both locales before writing either.
    stale = []
    for locale, data in outputs.items():
        path = project / f'lib/l10n/app_{locale}.arb'
        content = json.dumps(data, ensure_ascii=False, indent=2) + '\n'
        if not path.exists() or path.read_text() != content:
            stale.append(str(path))
            if not check:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content)
    if check and stale:
        raise ValueError('Regenerate localization inputs: ' + ', '.join(stale))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project', type=Path,
                        default=Path(__file__).resolve().parents[2] / 'apps/customer')
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    try:
        sync(args.project, args.check)
    except (ValueError, OSError) as error:
        parser.exit(1, str(error) + '\n')
    print('Localization inputs are synchronized.')
