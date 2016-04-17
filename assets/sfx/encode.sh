#!/bin/sh

for i in ~/Music/Logic/ld35-dj-ambientnouse/Bounces/*.wav ~/Music/Logic/ld35-dj-sounds/Bounces/*.wav ; do
	out="$(basename "$i" .wav).ogg"
	if [ "$i" -nt "$out" ] ; then
		oggenc "$i" -o "$(basename "$i" .wav).ogg"
	fi
done

