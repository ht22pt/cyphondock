#!/bin/bash
set -ev
docker exec cyphondock_cyphon_1 python manage.py migrate contenttypes || true
bridge="$(ip -4 addr show docker0 | grep -Po 'inet \K[\d\.]+')"
echo $bridge
docker exec cyphondock_cyphon_1 nc -zv cyphondock_cyphon_1 4445
docker exec cyphondock_cyphon_1 route -n
docker exec cyphondock_cyphon_1 sed -ie "s/localhost/${bridge}/" tests/functional_tests.py
# Make sure starter fixtures can load successfully and all tests pass.
# Run tests with --keepdb to avoid OperationalError during teardown, in case
# any db connections are stillr open from threads in TransactionTestCases.
docker exec cyphondock_cyphon_1 python manage.py loaddata fixtures/starter-fixtures.json
docker exec \
  -e FUNCTIONAL_TESTS_DRIVER=SAUCELABS \
  -e SAUCE_USERNAME \
  -e SAUCE_ACCESS_KEY \
  -e TRAVIS_JOB_NUMBER \
  -e TRAVIS_BUILD_NUMBER \
  -e TRAVIS_PYTHON_VERSION \
  -e TWITTER_ACCESS_TOKEN \
  -e TWITTER_KEY \
  -e TWITTER_SECRET \
  -e TWITTER_TOKEN_SECRET \
  cyphondock_cyphon_1 python manage.py test --noinput --keepdb -v 2
