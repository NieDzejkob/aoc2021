#!/usr/bin/env -S jq -R -f
def counts: reduce .[] as $fish ([]; . | .[$fish] += 1);
def day: .[0] as $x | .[1:] | .[6] += $x | .[8] += $x;
def doit($n): split(",") | [.[] | tonumber] | counts | reduce range($n) as $i (.; day) | add;
doit(80), doit(256)
