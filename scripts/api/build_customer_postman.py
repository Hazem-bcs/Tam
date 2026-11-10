#!/usr/bin/env python3
"""Compose the customer handoff from canonical, independently versioned sources."""
import argparse
import copy
import hashlib
import json
import re
from pathlib import Path

SOURCES = [
    ('auth', 'المصادقة', 'postman/Tam-Authentication-v1.postman_collection.json', 'authentication-v1.md'),
    ('home', 'الرئيسية', 'home/home-v1.postman_collection.json', 'home/home-v1.md'),
    ('ride', 'البحث والحجز الفوري', 'ride_request/ride_request-v1.postman_collection.json', 'ride_request/ride_request-v1.md'),
    ('schedule', 'الحجز المجدول — امتداد الحجز', 'scheduling/scheduling-v1.postman_collection.json', 'scheduling/scheduling-v1.md'),
    ('trips', 'طلباتي', 'trips/trips-v1.postman_collection.json', 'trips/trips-v1.md'),
    ('active', 'متابعة الرحلة — امتداد Trip', 'active_trip/active_trip-v1.postman_collection.json', 'active_trip/active_trip-v1.md'),
    ('addresses', 'العناوين المحفوظة', 'addresses/addresses-v1.postman_collection.json', 'addresses/addresses-v1.md'),
    ('maps', 'الخرائط المستضافة ذاتيًا', 'maps/maps-v1.postman_collection.json', 'maps/maps-v1.md'),
    ('contact', 'الاتصال بالسائق', 'driver_contact/driver_contact-v1.postman_collection.json', 'driver_contact/driver_contact-v1.md'),
    ('chat', 'المحادثة', 'chat/chat-v1.postman_collection.json', 'chat/chat-v1.md'),
    ('completion', 'إنهاء الرحلة والتقييم', 'completion/completion-v1.postman_collection.json', 'completion/completion-v1.md'),
    ('notifications', 'الإشعارات داخل التطبيق', 'notifications/notifications-v1.postman_collection.json', 'notifications/notifications-v1.md'),
    ('settings', 'إعدادات الحساب', 'settings/settings-v1.postman_collection.json', 'settings/settings-v1.md'),
    ('account', 'تغيير الرقم وحذف الحساب', 'account_management/account_management-v1.postman_collection.json', 'account_management/account_management-v1.md'),
    ('support', 'الدعم والمحتوى القانوني', 'support/support-v1.postman_collection.json', 'support/support-v1.md'),
]
COMMON = {'base_url', 'access_token', 'language'}
OUTPUT = 'postman/Tam-Customer-API-v1.postman_collection.json'
MANIFEST = 'postman/customer-api-v1.manifest.json'
VARIABLE = re.compile(r'\{\{([^{}]+)\}\}')


def request_items(items):
    for item in items:
        if 'request' in item:
            yield item
        else:
            yield from request_items(item.get('item', []))


def replace_variables(value, names):
    if isinstance(value, str):
        return VARIABLE.sub(lambda match: '{{' + names.get(match[1], match[1]) + '}}', value)
    if isinstance(value, list):
        return [replace_variables(item, names) for item in value]
    if isinstance(value, dict):
        return {key: replace_variables(item, names) for key, item in value.items()}
    return value


def strings(value):
    if isinstance(value, str):
        yield value
    elif isinstance(value, list):
        for item in value:
            yield from strings(item)
    elif isinstance(value, dict):
        for item in value.values():
            yield from strings(item)


def validate(collection):
    if collection['info']['schema'] != 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json':
        raise ValueError('Expected Postman v2.1')
    variables = collection['variable']
    names = {value['key'] for value in variables}
    if len(names) != len(variables):
        raise ValueError('Duplicate variables')
    # Contract prose may use conventional names; executable request definitions
    # and saved original requests must resolve their namespaced variables.
    for folder in collection['item']:
        for item in request_items(folder['item']):
            for text in strings([item['request'], item.get('response', [])]):
                missing = {name for name in VARIABLE.findall(text) if name not in names and not name.startswith('$')}
                if missing:
                    raise ValueError(f"{folder['name']}/{item['name']}: unbound {sorted(missing)}")
            request = item['request']
            if not request.get('method') or not request.get('url') or not item.get('response'):
                raise ValueError('Missing operation or examples')
            for response in item['response']:
                if not isinstance(response.get('code'), int) or not response.get('originalRequest'):
                    raise ValueError('Invalid saved response')
                if response['code'] == 204:
                    if response.get('body', ''):
                        raise ValueError('204 must be bodyless')
                    continue
                binary = any(h['key'].lower() == 'content-type' and h['value'] == 'image/png'
                             for h in response.get('header', []))
                if binary:
                    if response['code'] != 200 or item['request']['method'] != 'GET' or response.get('body'):
                        raise ValueError('Binary tile example must be bodyless GET 200')
                    continue
                body = json.loads(response['body'])
                if ('data' in body) == ('error' in body):
                    raise ValueError('Expected exactly one envelope kind')
                if response['code'] >= 400:
                    error = body['error']
                    if not error.get('code') or not all(error['message'].get(lang) for lang in ('ar', 'en')):
                        raise ValueError('Expected bilingual failure')


def build(root):
    api = root / 'docs/api'
    description = (api / 'customer-api-v1.md').read_text()
    variables = [
        {'key': 'base_url', 'value': 'https://example.invalid/api/v1', 'type': 'string'},
        {'key': 'access_token', 'value': '', 'type': 'string'},
        {'key': 'language', 'value': 'ar', 'type': 'string'},
    ]
    folders, entries = [], []
    for namespace, label, source, contract in SOURCES:
        source_path, contract_path = api / source, api / contract
        collection = json.loads(source_path.read_text())
        names = {value['key']: value['key'] if value['key'] in COMMON else f"{namespace}_{value['key']}"
                 for value in collection.get('variable', [])}
        variables.extend(replace_variables({**value, 'key': names[value['key']]}, names)
                         for value in collection.get('variable', []) if value['key'] not in COMMON)
        items = replace_variables(copy.deepcopy(collection['item']), names)
        # A noauth root preserves public operations with manual Bearer headers;
        # inherited source auth is materialized at its folder boundary.
        folders.append({
            'name': f'{len(folders) + 1:02d} — {label}',
            'description': (f'المصدر: {source}. المتغيرات التخصصية تبدأ بـ{namespace}_.\n'
                            'اقرأ قواعد العقد الموحد في وصف المجموعة أولًا؛ امتدادات Trip الحالية تطبق على أمثلة W1 القديمة.\n\n'
                            + contract_path.read_text()),
            'auth': replace_variables(collection.get('auth', {'type': 'noauth'}), names),
            'item': items,
        })
        entries.append({
            'namespace': namespace, 'collection': source, 'contract': contract,
            'collection_sha256': hashlib.sha256(source_path.read_bytes()).hexdigest(),
            'contract_sha256': hashlib.sha256(contract_path.read_bytes()).hexdigest(),
            'request_examples': sum(1 for _ in request_items(items)),
        })
    collection = {
        'info': {'name': 'TAM | تم — Customer API Contract v1 — REVIEW REQUIRED',
                 'description': description,
                 'schema': 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'},
        'auth': {'type': 'noauth'}, 'variable': variables, 'item': folders,
    }
    validate(collection)
    manifest = {'version': 1, 'status': 'REVIEW_REQUIRED',
                'request_examples': sum(entry['request_examples'] for entry in entries),
                'scope': 'Customer rides + account deletion + phone change + driver contact; no wallet, electronic payments or coupons',
                'overview_sha256': hashlib.sha256((api / 'customer-api-v1.md').read_bytes()).hexdigest(),
                'sources': entries}
    return collection, manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    collection, manifest = build(root)
    for filename, data in [(OUTPUT, collection), (MANIFEST, manifest)]:
        path = root / 'docs/api' / filename
        content = json.dumps(data, ensure_ascii=False, indent=2) + '\n'
        if args.check:
            if not path.exists() or path.read_text() != content:
                raise SystemExit(f'Stale output: {path}')
        else:
            path.write_text(content)
    print(f"Customer Postman: {len(SOURCES)} folders, {manifest['request_examples']} request examples; {'synchronized' if args.check else 'generated'}")


if __name__ == '__main__':
    main()
