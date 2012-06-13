#!/bin/sh

cat <<GLOBAL | drush-set &&
### global setup

clean_url: 1
configurable_timezones: 1
date_default_timezone: "Europe/London"
site_default_country: "GB"
site_frontpage: "node/1"
site_mail: "nick@noodlefactory.co.uk"
site_name: "Edinburgh Twins Club"
site_slogan: ""

user_email_verification: 1
# omitted
# update_notify_emails: Array([0] => webmaster@edinburghtwins.co.uk)
user_mail_register_pending_approval_body: "[user:name],\nThank you for registering at [site:name]. Your application for an account is currently pending approval. Once it has been approved, you will receive another e-mail containing information about how to log in, set your password, and other details.\n\nIf for some reason you don't hear back within the next day or so, please get in touch.\n\n--  [site:name] team\n"
GLOBAL

cat <<PHPBB | drush-set &&
## phpbb2drupal
phpbb2drupal_admin_user: "admin"
phpbb2drupal_bbcode: "1"
phpbb2drupal_db_database: "edinburg_phpbb"
phpbb2drupal_db_driver: "mysql"
phpbb2drupal_db_host: "localhost"
phpbb2drupal_db_password: "***********"
phpbb2drupal_db_username: "edinburg_root"
phpbb2drupal_import_attachments: 1
phpbb2drupal_import_spammers: 1
phpbb2drupal_input_format: "wysiwyg"
phpbb2drupal_regdate_us_english: 0
phpbb2drupal_same_db: 0
phpbb2drupal_table_prefix: "phpbb_"
phpbb2drupal_tested: 1
phpbb2drupal_time_limit: "1200"
PHPBB

# theme
drush dl zen genesis &&
drush en -y zen genesis &&

# drupal forms
drush dl webform &&

# views
drush dl views ctools &&
drush en -y views views_ui ctools &&

# ubercart
#drush dl ubercart uc_webform_pane entity rules &&
#drush en -y ubercart uc_webform_pane entity rules &&

# imce
drush dl imce imce_wysiwyg transliteration &&
drush en -y imce imce_wysiwyg transliteration &&

cat <<IMCE | drush-set &&
### transliteration
transliteration_file_lowercase: 1
transliteration_file_uploads: 1 

#### Files setup
file_default_scheme: "public"
file_private_path: ""
file_public_path: "sites/default/files"

mce_settings_absurls: 0
imce_settings_disable_private: 1
imce_settings_replace: "0"
imce_settings_textarea: ""
imce_settings_thumb_method: "scale_and_crop"
IMCE

# node-export + content_access
drush dl node_export content_access &&
drush en -y node_export content_access &&

# mollom
drush dl mollom &&
drush en -y mollom &&

cat <<MOLLOM | drush-set &&
mollom_fallback: "0"
mollom_moderation_redirect: 0
mollom_privacy_link: 1
mollom_private_key: "63076f9a6e3c5b81076b17ab0534215c"
mollom_public_key: "31c5effa67237f5beadc278b0baa114f"
mollom_testing_mode: 0
MOLLOM

# enable some core modules
drush en -y path tracker trigger rules 


