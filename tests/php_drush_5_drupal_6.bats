#!/usr/bin/env bats

FIG_FILE="${BATS_TEST_DIRNAME}/php_drush_5_drupal_6.yml"

container() {
  echo "$(fig -f ${FIG_FILE} ps php | grep php | awk '{ print $1 }')"
}

setup_drupal() {
  docker exec "$(container)" /bin/su - root -mc "wget http://ftp.drupal.org/files/projects/drupal-6.34.tar.gz -O /tmp/drupal-6.34.tar.gz"
  docker exec "$(container)" /bin/su - root -mc "tar xzf /tmp/drupal-6.34.tar.gz -C /tmp"
  docker exec "$(container)" /bin/su - root -mc "rsync -avz /tmp/drupal-6.34/ /httpd/data"
  docker exec "$(container)" /bin/su - root -mc "chown www-data.www-data /httpd/data"
  docker exec "$(container)" /bin/su - root -mc "drush -r /httpd/data -y site-install --db-url=mysqli://root:root@localhost/drupal --account-name=admin --account-pass=admin"
}

setup() {
  fig -f "${FIG_FILE}" up -d --allow-insecure-ssl

  sleep 10

  setup_drupal
}

teardown() {
  fig -f "${FIG_FILE}" kill
  fig -f "${FIG_FILE}" rm --force
}

@test "php: drush 5: drupal 6" {
  run docker exec "$(container)" /bin/su - root -mc "drush -r /httpd/data/ status | grep 'Drupal bootstrap'"

  [ "${status}" -eq 0 ]
  [[ "${output}" == *"Successful"* ]]
}
