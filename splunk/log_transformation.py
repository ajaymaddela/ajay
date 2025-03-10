from base64 import b64encode, b64decode
from json import loads
from zlib import decompress
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    return {'records': list(process(event['records']))}

def process(records) -> list:
    for record in records:
        record_id, payload = parse_record(record)
        logger.info(f'Payload to be transformed: {payload}')
        message_type = payload.get('messageType', '<unknown>')
        if message_type == 'CONTROL_MESSAGE':
            yield {'recordId': record_id, 'result': 'Dropped'}
        elif message_type == 'DATA_MESSAGE':
            payload = '\r\n'.join(transform(payload))
            yield {
                'recordId': record_id,
                'result': 'Ok',
                'data': b64encode(payload.encode('UTF-8')).decode('UTF-8')
            }
        else:
            logger.info(f'Unknown messageType: {message_type}')
            yield {'recordId': record_id, 'result': 'ProcessingFailed'}

def parse_record(record) -> tuple:
    data = record['data'].strip()
    if not data.startswith("{"):
        data = decompress(b64decode(data)).decode('UTF-8')
    return record['recordId'], loads(data)

def transform(payload) -> str:
    for event in payload['logEvents']:
        yield event['message']