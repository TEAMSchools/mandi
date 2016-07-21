import json
from oauth2client.client import SignedJwtAssertionCredentials
from tzlocal import get_localzone

LOCAL_TZ = get_localzone()
OAUTH_FILE = ''
GDOCS_SCOPE = 'https://spreadsheets.google.com/feeds'
DOWNLOAD_CONFIG_URL = ''
UPLOAD_CONFIG_URL = ''

## authenticate to GDocs
oauth_key = json.load(open(OAUTH_FILE))
scope = [GDOCS_SCOPE]
GDOCS_CREDENTIALS = SignedJwtAssertionCredentials(oauth_key['client_email'], oauth_key['private_key'], scope)
