#!/bin/sh

# Quick and dirty graph generator. Should be rewritten at some point.

SHARD="SHARD1"

cd /home/closure

rm -f $SHARD
rm -f $SHARD.geolist
rm -f $SHARD.clientconnsperhour

wget -q  http://iabak.archiveteam.org/stats/$SHARD
wget -q  http://iabak.archiveteam.org/stats/$SHARD.size
wget -q  http://iabak.archiveteam.org/stats/$SHARD.geolist
wget -q  http://iabak.archiveteam.org/stats/$SHARD.clientconnsperhour       

if [ -f $SHARD ]
   then
   IA1=`cat $SHARD | grep 'numcopies +0' | cut -f2 -d':'`
   IA2=`cat $SHARD | grep 'numcopies +1' | cut -f2 -d':'`
   IA3=`cat $SHARD | grep 'numcopies +2' | cut -f2 -d':'`
   IA4=`cat $SHARD | grep 'numcopies +[3-6]' | cut -f2 -d':' | awk '{ sum+=$1} END {print sum}'`
   CHRONOS=`date`

   # Fix color problem for missing numbers.
   if [ -z "$IA1" ]; then IA1=0.001; fi
   if [ -z "$IA2" ]; then IA2=0.001; fi
   if [ -z "$IA3" ]; then IA3=0.001; fi
   if [ -z "$IA4" ]; then IA4=0.001; fi

# Head!

   cat html/graph.template.head | sed "s/IA1/${IA1}/g" | sed "s/IA2/${IA2}/g" | sed "s/IA3/${IA3}/g" | sed "s/IA4/${IA4}/g" | sed "s/TIME/${CHRONOS}/g" > html/graph.html

# Let's do GEO.....
    
   CLICOUNT=`cat $SHARD.geolist | wc -l`
   COUNTRYS=`cat $SHARD.geolist | sed 's/.*\"country_name\":\"//g' | sed 's/ /_/g' | cut -f1 -d'"' | sort -u | wc -l`
   
   for country in `cat $SHARD.geolist | sed 's/.*\"country_name\":\"//g' | sed 's/ /_/g' | cut -f1 -d'"' | sort -u`
       do
       PUNKY=`echo ${country} | sed 's/_/ /g'`
       COUNT=`grep "\"country_name\":\"${PUNKY}" $SHARD.geolist | wc -l `
       echo "['${PUNKY}', ${COUNT}]," >> html/graph.html
       done

       cat html/graph.template.middle >> html/graph.html

   for city in `cat $SHARD.geolist | grep "United States" | sed 's/.*\"zip_code\":\"//g' | sed 's/ /_/g' | cut -f1 -d'"' | sort -u`
       do
       PUNKY=`echo ${city} | sed 's/_/ /g'`
       COUNT=`grep "\"zip_code\":\"${PUNKY}" $SHARD.geolist | wc -l `
       echo "['${PUNKY}', ${COUNT}]," >> html/graph.html
       done

cat $SHARD.clientconnsperhour | sed -e 's/^[ \t]*//' | awk '{print $2, $3, $4, "Z", $1}'  | sed "s/^/['/g" | sed "s/ Z /', /g" | sed "s/$/],/g" | tail -24 > $SHARD.clientday

   SHARDNAME="$SHARD"
   if [ "$SHARDNAME" = ALL ]; then SHARDNAME=""; fi

   SIZE="$(cat $SHARD.size)"

   cat html/graph.template.tail | sed "s/SHARDNAME/${SHARDNAME}/g" | sed "s/SIZE/${SIZE}/g" | sed "s/IA1/${IA1}/g" | sed "s/IA2/${IA2}/g" | sed "s/IA3/${IA3}/g" | sed "s/IA4/${IA4}/g" | sed "s/TIME/${CHRONOS}/g" | sed "s/CLICOUNT/${CLICOUNT}/g" | sed "s/CLAMBAKE/${COUNTRYS}/g" >> html/graph.html

fi
