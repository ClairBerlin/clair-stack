#!/usr/bin/env python3

import sys
import json
import base64
import uuid
import hashlib

def olduuid(devid, protocol):
    return uuid.UUID(bytes=hashlib.sha256(protocol.encode() + devid.encode()).digest()[0:16])


UUID_MAP = {
    olduuid("9876B600001193E0", "CLAIRCHEN"): 'c727b2f8-8377-d4cb-0e95-ac03200b8c93', # Clairchen Rot
    olduuid("003CB7EA62A7DCBB", "CLAIRCHEN"): '3b95a1b2-74e7-9e98-52c4-4acae441f0ae', # Clairchen Schwarz
    olduuid("A81758FFFE052B0F", "ELSYSERS"): '9d02faee-4260-1377-22ec-936428b572ee'
}

with open(sys.argv[1]) as fd:
    fixtures = []

    for line in fd:
        obj = json.loads(line)
        olduuid = uuid.UUID(bytes = base64.b64decode(obj['node_ref']['$binary']['base64']))
        fields = {
            'node': str(UUID_MAP[olduuid]),
            'timestamp_s': obj['timestamp_s']['$numberLong'],
            'co2_ppm': obj['co2_ppm']['$numberInt'],
            'measurement_status': 'M'
        }
        if 'temperature_celsius' in obj:
            fields['temperature_celsius'] = obj['temperature_celsius']['$numberInt']
        if 'rel_humidity_percent' in obj:
            fields['rel_humidity_percent'] = obj['rel_humidity_percent']['$numberInt']
        fixture = {
            'model': 'core.sample',
            'pk': len(fixtures) + 1,
            'fields': fields
        }
        fixtures.append(fixture)

    print(json.dumps(fixtures, indent=4))
