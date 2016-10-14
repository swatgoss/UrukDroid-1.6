#!/bin/sh

/bin/rm -f "/data/data/com.android.settings/shared_prefs/com.android.settings.xml"

/bin/sed -i '/phone_id/d' "/data/data/com.android.settings/shared_prefs/com.android.settings_preferences.xml"
/bin/sed -i '/connection/d' "/data/data/com.android.settings/shared_prefs/com.android.settings_preferences.xml"
/bin/sed -i '/apn/d' "/data/data/com.android.settings/shared_prefs/com.android.settings_preferences.xml"

# EOF
