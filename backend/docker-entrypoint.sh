#!/bin/sh

set -e

# Lancer migrations Laravel
php artisan migrate --force

exec "$@"
