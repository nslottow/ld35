#!/bin/sh

for i in ~/Music/Logic/ld35-dj*/Bounces/l*-e*.wav ; do
	out="$(basename "$i" .wav).ogg"
	if [ "$i" -nt "$out" ] ; then
		oggenc "$i" -o "$(basename "$i" .wav).ogg"
	fi
done

