# import boto3
# import json
# import os
# import gzip
# import base64
# import urllib.parse
# import time
# import http.client
# from botocore.exceptions import BotoCoreError, NoCredentialsError

# # Splunk HEC Configuration
# SPLUNK_HOST = "52.53.212.111"
# SPLUNK_PORT = 8088
# SPLUNK_HEC_TOKEN = "81d454ca-d204-420e-8b32-431384468faf"

# # AWS S3 Client
# s3_client = boto3.client("s3")

# def send_to_splunk(event):
#     """Send metadata logs to Splunk HEC"""
#     conn = http.client.HTTPConnection(SPLUNK_HOST, SPLUNK_PORT)
#     headers = {
#         "Authorization": f"Splunk {SPLUNK_HEC_TOKEN}",
#         "Content-Type": "application/json"
#     }
#     payload = json.dumps(event)

#     conn.request("POST", "/services/collector", payload, headers)
#     response = conn.getresponse()

#     print(f"🔄 Splunk Response: {response.status} - {response.read().decode()}")
#     return response.status

# def lambda_handler(event, context):
#     """AWS Lambda function to process S3 files and send metadata to Splunk"""
#     for record in event.get("Records", []):
#         bucket_name = record["s3"]["bucket"]["name"]
#         object_key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

#         try:
#             print(f"📄 Processing file: {object_key} from bucket: {bucket_name}")

#             # Download file from S3 (only for metadata)
#             response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
#             content = response["Body"].read()

#             # Determine content type (do not log content)
#             if object_key.endswith(".gz"):
#                 content_type = "gzip"
#             else:
#                 try:
#                     content.decode("utf-8")  # Check if it's text
#                     content_type = "text"
#                 except UnicodeDecodeError:
#                     content_type = "binary"

#             # Create Splunk event payload (only metadata, no file content)
#             event_data = {
#                 "event": {
#                     "file_name": object_key,
#                     "bucket": bucket_name,
#                     "content_type": content_type,
#                     "timestamp": time.time()
#                 }
#             }

#             # Send metadata to Splunk
#             status = send_to_splunk(event_data)
#             if status not in [200, 201]:
#                 print(f"❌ Failed to send metadata for file: {object_key}")

#         except (BotoCoreError, NoCredentialsError) as e:
#             print(f"❌ S3 Access Error: {str(e)}")
#         except Exception as e:
#             print(f"❌ Processing Error: {str(e)}")

#     return {"status": "success"}
