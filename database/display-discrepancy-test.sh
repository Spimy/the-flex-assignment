#!/usr/bin/env bash

# This makes for sunset@propertyflow.com's Beach House Alpha property to show USD 2,250.05 on unfixed code
# Fixed code should show USD 2,250.06

# After running the remove option, it'll go back to the original data showing USD 2,250.00

set -euo pipefail
cd "$(dirname "$0")/.."

if docker compose version >/dev/null 2>&1; then
  compose=(docker compose)
else
  compose=(docker-compose)
fi

run_sql() {
  "${compose[@]}" exec -T db psql -U postgres -d propertyflow -v ON_ERROR_STOP=1 -c "$1"
}

flush_cache() {
  "${compose[@]}" exec -T redis redis-cli flushall >/dev/null
}

case "${1:-}" in
  add)
    run_sql "
      INSERT INTO reservations (id, property_id, tenant_id, check_in_date, check_out_date, total_amount)
      VALUES ('res-test-cents', 'prop-001', 'tenant-a',
              '2024-03-10 10:00:00+00', '2024-03-12 10:00:00+00', 0.055)
      ON CONFLICT (id) DO NOTHING;"
    flush_cache
    echo "Added. Sunset prop-001 should show USD 2,250.06 from 5 reservations."
    ;;
  remove)
    run_sql "DELETE FROM reservations WHERE id = 'res-test-cents';"
    flush_cache
    echo "Removed. Sunset prop-001 should show USD 2,250.00 from 4 reservations."
    ;;
  *)
    echo "Usage: bash database/cents-test.sh add|remove" >&2
    exit 1
    ;;
esac