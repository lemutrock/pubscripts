#!/bin/bash

sqlhost='127.0.0.1'
sqluser='user'
sqlpass='password'

grant_to='api'

grant_from=( '127.0.0.1' 'localhost' )

dblist=( dbtest anotherone )
#tables with readonly privs
rotlist=( categories discounts discounts_categories discounts_goods countries currencies images prices products products_tags )
#tables with rw privs
wrtlist=( orders order_discounts orders_items orders_items_products clients order_discounts payments )

for db in "${dblist[@]}"
do
    echo "granting privileges for $db"
    for t in "${rotlist[@]}"
    do
        echo "granting on $t"
        for h in "${grant_from[@]}"
        do
            echo "for $grant_to from $h"
            mysql -u$sqluser -p$sqlpass -h$sqlhost $db -e "GRANT SELECT ON $db.$t TO '$grant_to'@'$h'"
        done
    done
    for t in "${wrtlist[@]}"
    do
        echo "granting INSERT UPDATE on $t"
        for h in "${grant_from[@]}"
        do
            echo "for $grant_to from $h"
            mysql -u$sqluser -p$sqlpass -h$sqlhost $db -e "GRANT SELECT,INSERT,UPDATE ON $db.$t TO '$grant_to'@'$h'"
        done
    done
done

echo "FINISHED"
exit 0


