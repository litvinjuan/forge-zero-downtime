# --------------------
# /      Config      /
# --------------------

PROJECT_PATH=[PATH_IN_SERVER_TO_YOUR_PROJECT]
SSH_REPOSITORY=[SSH_CLONE_URL_FOR_YOUR_REPOSITORY]


# --------------------
# /    Deployment    /
# --------------------

RELEASES_PATH=$PROJECT_PATH/releases
NEW_RELEASE_PATH=$RELEASES_PATH/$(date +%Y%m%d%H%M%S)
ENV_PATH=$PROJECT_PATH/.env
STORAGE_PATH=$PROJECT_PATH/storage
RELEASES_KEPT=3

printf "\n\nCloning Repository\n\n"

git clone $SSH_REPOSITORY $NEW_RELEASE_PATH

cd $NEW_RELEASE_PATH

printf "\n\nInstalling Composer dependences\n\n"

composer install --no-interaction --prefer-dist --optimize-autoloader

printf "\n\nBuilding Assets (Yarn)\n\n"
yarn install
yarn production

printf "\n\nRunning PHPUnit\n\n"
./vendor/bin/phpunit

printf "\n\nSymlinking .env and storage\n\n"
ln -s $ENV_PATH .env
rm -rf storage
ln -sn $STORAGE_PATH storage

if [ -f artisan ]; then
    printf "\n\nRestarting Queue\n\n"
    php artisan queue:restart
    printf "\n\nRunning migrations\n\n"
    php artisan migrate --force
fi

cd $PROJECT_PATH

printf "\n\nActivating new release\n\n"
ln -sfn $NEW_RELEASE_PATH current

( flock -w 10 9 || exit 1
    printf "Restarting FPM..."; sudo -S service php7.4-fpm reload ) 9>/tmp/fpmlock

cd $RELEASES_PATH

printf "\n\nPurging old releases"
rm -rf `ls -1 | sort -r | tail -n +$(($RELEASES_KEPT+1))`