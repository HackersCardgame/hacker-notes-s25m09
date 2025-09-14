#/bin/bash

cat /proc/asound/cards

sleep 5

jackd -d dummy -p 128  &

sleep 5

for i in $(cat /proc/asound/cards |grep ICU| grep -v at |cut -c2)
do
  echo $i
  amixer -c $i get 'PCM Capture Source'
  echo amixer -c $i set 'PCM Capture Source' 'IEC958 In'
  
  amixer -c $i set 'PCM Capture Source' 'IEC958 In'
  
  alsa_in -j "toslink${i}" -d hw:${i} -r 48000 /dev/null &
  
  
  echo alsa_out -j "toslink${i}" -d hw:${i} -r 48000 >/dev/null &
  alsa_out -j "toslink${i}" -d hw:${i} -r 48000 >/dev/null &  
done

sleep 5

inputs=$(jack_lsp |grep capture |grep -v system |cut -d":" -f1 |sort|uniq)

outputs=$(jack_lsp |grep playback |grep -v system |cut -d":" -f1 |sort|uniq)

echo $inputs
echo $outputs

sleep 5

jack_lsp

echo connecting ports ...

for i in $inputs
do
  for o in $outputs
  do
    echo jack_connect ${i}:capture_1 ${o}:playback_1
    jack_connect ${i}:capture_1 ${o}:playback_1
    echo jack_connect ${i}:capture_2 ${o}:playback_2
    jack_connect ${i}:capture_2 ${o}:playback_2
  done
done

sleep 5

echo starting qjackd ...


qjackctl


