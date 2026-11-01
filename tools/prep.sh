#!/usr/bin/env bash
# One-time: fresh Sylius Standard 2.3 demo project with the N+1 customization,
# Mate on the latest release, two branches: demo-bare (no init) and demo-mate (init + discover).
#
#   tools/prep.sh                # creates ~/Sylius/phpers-demo-23 (DEMO_DIR to override)
#
# Needs: local MySQL on 127.0.0.1 as root (no password), symfony CLI, composer, node.
set -euo pipefail

DEMO_DIR="${DEMO_DIR:-$HOME/Sylius/phpers-demo-23}"
OLD_DIR="${OLD_DIR:-$HOME/Sylius/phpers-demo}"      # source of the customization commit
CUSTOMIZATION_COMMIT="${CUSTOMIZATION_COMMIT:-1fd073e}"  # "Show available variants, sizes and stock on the product card"
SYLIUS_STANDARD="${SYLIUS_STANDARD:-^2.3}"
MATE_VERSION="${MATE_VERSION:-^1.0@beta}"           # 1.0.0-BETA1 on 1 Nov 2026; drop @beta once stable is out
DB_NAME="${DB_NAME:-phpers_demo_23}"

say() { printf '\n\033[1;32m▶ %s\033[0m\n' "$*"; }

if [ ! -d "$DEMO_DIR" ]; then
  say "create-project sylius/sylius-standard:$SYLIUS_STANDARD → $DEMO_DIR"
  composer create-project "sylius/sylius-standard:$SYLIUS_STANDARD" "$DEMO_DIR" --no-interaction
  cd "$DEMO_DIR"
  git init -q && git add -A && git commit -qm "Fresh Sylius Standard 2.3 project"
fi
cd "$DEMO_DIR"

say "database name + env"
if ! grep -q "$DB_NAME" .env; then
  sed -i '' -E "s#^DATABASE_URL=.*#DATABASE_URL=mysql://root@127.0.0.1/${DB_NAME}_%kernel.environment%?serverVersion=8\&charset=utf8mb4#" .env
  git add .env && git commit -qm "Use a dedicated database name"
fi

if ! git log --oneline | grep -q "variants, sizes and stock"; then
  say "cherry-pick the customization from $OLD_DIR ($CUSTOMIZATION_COMMIT)"
  git fetch -q "$OLD_DIR" variants-on-card
  git cherry-pick -x "$CUSTOMIZATION_COMMIT"
fi

say "install, assets, database with fixtures"
composer install --no-interaction
[ -d node_modules ] || npm install --silent
npm run build --silent || true
bin/console doctrine:database:drop --force --if-exists -q
bin/console doctrine:database:create -q
bin/console doctrine:migrations:migrate -n -q
bin/console sylius:fixtures:load default -n -q
bin/console cache:clear -q

say "Mate $MATE_VERSION (vendor only; branch demo-bare = no init)"
composer require --dev "symfony/ai-mate:$MATE_VERSION" "symfony/ai-symfony-mate-extension:$MATE_VERSION" --no-interaction -W
git add -A && git commit -qm "Add Symfony AI Mate and the Symfony bridge as dev dependencies" || true
git branch -f demo-bare HEAD

say "branch demo-mate = mate init + discover"
git checkout -q -B demo-mate demo-bare
vendor/bin/mate init --no-interaction
vendor/bin/mate discover
git add -A && git commit -qm "mate init + discover" || true
git checkout -q demo-bare

say "done"
echo "  bare: $(git rev-parse --short demo-bare)   mate: $(git rev-parse --short demo-mate)"
echo "  next: DEMO_DIR=$DEMO_DIR tools/run.sh bare claude-fable-5-1 1   (smoke test, one run)"
echo "  check: counts on slide 5 (products × variants, queries on the listing) against this fixture set"
