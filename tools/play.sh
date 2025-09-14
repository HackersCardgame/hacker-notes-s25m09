#!/bin/bash

date
echo "

> seek 3400
> seek -10
> seek +10
get_time
#nvlc --rate=2
"

cvlc -I rc --rate=2 $1

