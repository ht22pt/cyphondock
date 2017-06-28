#!/bin/bash
set -ev
# netstat -4lnt
docker exec cyphondock_cyphon_1 python manage.py migrate contenttypes || true
# bridge="$(docker exec cyphondock_cyphon_1 route -n | grep -Po '172\.\d+\.0\.1' | head -n1)"
# echo $bridge
# docker exec cyphondock_cyphon_1 route -n
# sed -ie "s/POSTGRES_HOST=.*/POSTGRES_HOST=${bridge}/" config-COPYME/env/cyphon.env
# docker-compose -f docker-compose.travis.yml stop cyphon
# docker-compose -f docker-compose.travis.yml up -d cyphon
# sleep 10
docker exec cyphondock_cyphon_1 sed -ie "s/localhost/saucelabs/" tests/functional_tests.py
docker exec cyphondock_cyphon_1 grep "saucelabs" tests/functional_tests.py
# Make sure starter fixtures can load successfully and all tests pass.
# Run tests with --keepdb to avoid OperationalError during teardown, in case
# any db connections are stillr open from threads in TransactionTestCases.
docker exec cyphondock_cyphon_1 python manage.py loaddata fixtures/starter-fixtures.json || true
# while ! docker logs cyphondock_saucelabs_1 | grep -q "Selenium listener started"
# do
#   echo "Waiting for Saucelabs Connect proxy..."
#   sleep 10
# done
docker exec cyphondock_cyphon_1 python manage.py test -p test_functional.py --noinput --keepdb -v 2
