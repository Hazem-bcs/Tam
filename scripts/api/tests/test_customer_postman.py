import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('builder', ROOT / 'scripts/api/build_customer_postman.py')
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)


class CustomerPostmanTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.collection, cls.manifest = builder.build(ROOT)

    def test_generated_file_and_manifest_are_reproducible_and_current(self):
        for name, value in [(builder.OUTPUT, self.collection), (builder.MANIFEST, self.manifest)]:
            self.assertEqual(json.loads((ROOT / 'docs/api' / name).read_text()), value)
        self.assertEqual(builder.build(ROOT), (self.collection, self.manifest))
        self.assertEqual(len(self.collection['item']), 15)
        self.assertEqual(self.manifest['request_examples'], 62)
        self.assertEqual(len({item['collection'] for item in self.manifest['sources']}), 15)
        self.assertEqual(sum(item['namespace'] == 'auth' for item in self.manifest['sources']), 1)

    def test_effective_auth_preserves_public_and_protected_operations(self):
        for folder in self.collection['item']:
            for item in builder.request_items(folder['item']):
                request = item['request']
                raw = request['url']['raw'] if isinstance(request['url'], dict) else request['url']
                public = any(path in raw for path in ['/home', '/places?', '/content/legal/', '/map/reverse?', '/map/routes', 'maps_tiles_base_url'])
                auth = request.get('auth', folder['auth'])
                header = [h for h in request['header'] if h['key'].lower() == 'authorization']
                if public:
                    self.assertEqual(auth['type'], 'noauth', raw)
                    self.assertEqual(header, [], raw)
                elif '/account/operations/' in raw:
                    self.assertEqual(auth['type'], 'noauth')
                    self.assertTrue(any(h['key'] == 'X-Operation-Token' for h in request['header']))
                elif '/auth/' not in raw:
                    self.assertTrue(auth['type'] == 'bearer' or len(header) == 1, raw)
                if '/confirm' in raw and '/account/challenges/' in raw:
                    self.assertEqual(auth['type'], 'bearer')
                    self.assertTrue(any(h['key'] == 'X-Operation-Token' for h in request['header']))

    def test_feature_operation_ids_and_challenges_cannot_collide(self):
        keys = {item['key'] for item in self.collection['variable']}
        for name in ['auth_challenge_id', 'account_challenge_id', 'account_operation_id',
                     'addresses_operation_id', 'schedule_operation_id', 'completion_idempotency_key',
                     'ride_idempotency_key', 'support_client_request_id']:
            self.assertIn(name, keys)
        values = {item['key']: item['value'] for item in self.collection['variable']}
        self.assertEqual(values['access_token'], '')
        self.assertEqual(values['auth_refresh_token'], '')
        self.assertEqual(values['account_recovery_token'], '')
        self.assertEqual(values['base_url'], 'https://example.invalid/api/v1')

    def test_saved_requests_and_response_payloads_are_preserved_from_sources(self):
        for folder, source in zip(self.collection['item'], builder.SOURCES):
            namespace, _, filename, _ = source
            original = json.loads((ROOT / 'docs/api' / filename).read_text())
            mapping = {value['key']: value['key'] if value['key'] in builder.COMMON else f"{namespace}_{value['key']}"
                       for value in original.get('variable', [])}
            expected = builder.replace_variables(original['item'], mapping)
            self.assertEqual(folder['item'], expected)
            self.assertEqual(folder['auth'], builder.replace_variables(original.get('auth', {'type': 'noauth'}), mapping))

    def test_validator_rejects_unbound_requests_empty_envelopes_and_nonempty_204(self):
        cases = []
        missing = copy.deepcopy(self.collection)
        missing['item'][0]['item'][0]['request']['url'] = '{{missing_variable}}'
        cases.append(missing)
        invalid = copy.deepcopy(self.collection)
        response = next(builder.request_items(invalid['item'][0]['item']))['response'][0]
        response['body'] = json.dumps({'data': {}, 'error': {}})
        cases.append(invalid)
        invalid = copy.deepcopy(self.collection)
        response = next(builder.request_items(invalid['item'][0]['item']))['response'][0]
        response['code'] = 204
        cases.append(invalid)
        for collection in cases:
            with self.assertRaises(ValueError):
                builder.validate(collection)

    def test_auth_contract_unchanged_and_feature_aliases_are_normalized(self):
        for folder in self.collection['item']:
            auth_folder = 'المصادقة' in folder['name']
            for item in builder.request_items(folder['item']):
                for response in item['response']:
                    if response['code'] != 401:
                        continue
                    code = json.loads(response['body'])['error']['code']
                    if auth_folder:
                        self.assertIn(code, {'SESSION_INVALID', 'SESSION_REVOKED'})
                    else:
                        self.assertIn(code, {'UNAUTHENTICATED', 'RECOVERY_INVALID'})

    def test_binary_tile_example_cannot_hide_an_error_or_fabricated_payload(self):
        tile = next(item for folder in self.collection['item']
                    for item in builder.request_items(folder['item'])
                    if any(h['value'] == 'image/png' for response in item['response']
                           for h in response.get('header', [])))
        for field, value in [('code', 503), ('body', 'fabricated PNG')]:
            invalid = copy.deepcopy(self.collection)
            altered = next(item for folder in invalid['item']
                           for item in builder.request_items(folder['item'])
                           if item['name'] == tile['name'])
            altered['response'][0][field] = value
            with self.assertRaises(ValueError):
                builder.validate(invalid)


if __name__ == '__main__':
    unittest.main()
