#!/bin/sh

sed -e "s/^ *//g" -e "s/^\t*//g" \
| sed -e "s/^ *//g" \
| sed -e "s/^ *;$//g" \
| sed -e "/:/! s/^/\t\t/g" \
| sed -e "s/^\t\t;/;/g" \
| sed -e "s/^\t\t$//g"
