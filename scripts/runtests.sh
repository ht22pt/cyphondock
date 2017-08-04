#!/bin/bash
set -ev
# Make sure starter fixtures can load successfully and all tests pass.
# Run tests with --keepdb to avoid OperationalError during teardown, in case
# any db connections are stillr open from threads in TransactionTestCases.
docker exec cyphondock_cyphon_1 python manage.py makemigrations || true
docker exec cyphondock_cyphon_1 python manage.py migrate || true
docker exec cyphondock_cyphon_1 python manage.py loaddata fixtures/starter-fixtures.json || true
docker exec cyphondock_cyphon_1 python manage.py test -p test_functional.py --noinput --keepdb -v 2
