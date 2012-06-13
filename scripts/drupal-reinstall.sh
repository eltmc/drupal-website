#!/bin/bash

export PWD=.
export DOMAIN=edinburghtwins.noodlefactory.co.uk
export DB_NAME=edinburg_drupal_website
export DB_USER=edinburg_drupal
export DB_PASS='***********'
export DB_ROOT=edinburg_root
export PHPBB_DUMP=~/i/messageboard-sql/full-dbdump.Final-Snapshot-2012-06-12.sql.bz2
export PHPBB_DB=edinburg_phpbb
export VERSION=7.14
export CKEDITOR_URL=http://download.cksource.com/CKEditor/CKEditor/CKEditor%203.6.3/ckeditor_3.6.3.tar.gz
SI_OPTIONS="--clean-url=0 --account-name=admin --account-mail=webmaster@edinburghtwins.co.uk --account-pass=multiples --site-name=Edinburgh-Twins-Club --site-mail=drupal@edinburghtwins.co.uk"
#export GIT_URL=http://git.drupal.org/project/phpbb2drupal.git
#export GIT_URL=git://github.com/wu-lee/phpbb2drupal.git
export GIT_URL=git@github.com:eltmc/phpbb2drupal.git
export DRUPAL_OWNER=edinburg:edinburg

die() {
  echo >&2 $*
  exit 1
}

reset_perms() {
  chown -R $DRUPAL_OWNER $1 &&
#  chmod -R g+w $1 && # eleven2 doesn't like this
  find $1 -type d | xargs chmod g+s
}

(
  cd $PWD
  if [ -e $DOMAIN ]; then
    mv $PWD/$DOMAIN  $PWD/$DOMAIN.`date +%F:%H:%S`
  fi
  mkdir  $PWD/$DOMAIN
) &&


(
  echo "recreating $DB_NAME, please enter password for $DB_ROOT user"
  echo "drop database if exists $DB_NAME; create database $DB_NAME;" | mysql -u $DB_ROOT -p ||
      die "failed to recreate database $DB_NAME"

  # assume $DB_USER already has access
) &&

(
cd  $PWD/$DOMAIN &&

# drupal
drush dl drupal-$VERSION # current latest &&
ln -s drupal-$VERSION htdocs &&
cd htdocs &&
#cp sites/default/default.settings.php sites/default/settings.php &&
#chmod g+w sites/default/settings.php &&
reset_perms . &&

drush si standard \
  -y --db-url=mysql://$DB_USER:$DB_PASS@localhost/$DB_NAME \
  $SI_OPTIONS &&
drush status &&

# phpbb2drupal
(
  cd modules/ &&
  git clone $GIT_URL
) &&
drush dl bbcode-7.x-1.0 && # version apparently required
drush dl privatemsg &&
drush en -y bbcode privatemsg forum phpbb2drupal phpbb2privatemsg phpbb_redirect &&

echo "Recreate and populate the $PHPBB_DB database, please enter password for $DB_ROOT user"
# The grep filters out commands which create/drop/use the 
# database in the sql, which might not be the one we want.
#mysqladmin -u $DB_ROOT -p -f drop $PHPBB_DB &&
( echo "drop database if exists $PHPBB_DB; create database $PHPBB_DB; use $PHPBB_DB;" ; bzip2 -dc  $PHPBB_DUMP | egrep -iv "^ *(use|create database|drop database)") |
    mysql -u $DB_ROOT -p &&
# assume $DB_USER already has access


# wysiwyg
drush dl wysiwyg &&
drush en -y wysiwyg &&
wget $CKEDITOR_URL &&
tar xzvf ${CKEDITOR_URL##*/} &&
mkdir -p sites/all/libraries &&
mv ckeditor sites/all/libraries &&

# perms
reset_perms .

)
