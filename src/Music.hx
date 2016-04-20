package;

import luxe.Log.*;
import luxe.Audio;
import luxe.resource.Resource;
import luxe.Parcel;
import luxe.ParcelProgress;
import snow.types.Types.AudioHandle;
import snow.types.Types.AudioState;

import luxe.utils.Maths;

/**
	BUG: Snow WebAudio does not handle Audio.play(paused = true), i.e. getting an AudioHandle
	that you want to start paused.
	BUG: AudioHandles also become invalid when they are finished playing. Not sure if this is a bug.
	BUG: AudioSource.duration() is incorrect on WebAudio for ogg at least.
	I tried to instead keep looping an audio handle and changing the volume and position. Didn't work
	because of AudioSource.duration() bug.

	NOTE: Handle sequences are always sequential

	NOTE: js.html.AudioBufferSourceNode can only be played once, must be recreated
	NOTE: js.html.AudioBuffer can be reused with multiple AudioBufferSourceNodes

	TODO: If window loses focus and audio system is paused, Luxe.audio.position_of will return the wrong thing because it's based on time
**/
class Music {
	public static inline var loop_length_seconds:Float = 24;
	public static inline var crossfade_length_seconds:Float = 2;
	public static inline var motif_count = 5;
	public static inline var energy_count = 7;

	public static var current_energy:MusicInstance;
	public static var next_energy:MusicInstance;
	public static var next_motif:MusicInstance;
	public static var crossfading_motif:MusicInstance;

	public static var paused(default, null):Bool;
	public static var master_volume = 0.8; // TODO: Respond to this being set
	public static var transition_to_next_motif:Bool = false;

	public static var unplayed_motifs(default, null):Array<Int>;
	public static var crossfade_start_time(default, null):Float;

	static var loading_parcels = new Map<Parcel, MusicParcelInfo>();

	public static function init(motif:Int=2, energy:Int=1) {
		assert(motif >= 1 && motif <= motif_count);
		assert(energy >= 1 && energy <= energy_count);

		paused = false;
		unplayed_motifs = [for (i in 1...(motif_count+1)) i];

		load_music_async(MusicSlot.current_energy, motif, energy);
		load_music_async(MusicSlot.next_energy, motif, (energy % energy_count) + 1);
		load_music_async(MusicSlot.next_motif, (motif % motif_count) + 1, 1);
	}

	public static function load_music_async(target:MusicSlot, motif:Int, energy:Int) {
		var music_id = 'assets/music/l$motif-e$energy.ogg';
		var parcel = new Parcel({
			sounds: [
				{ id: music_id, is_stream: false}
			],
			oncomplete: on_loaded
		});
		loading_parcels.set(parcel, {
			target: target,
			motif: motif,
			energy: energy 
		});
		parcel.load();
	}

	public static function on_loaded(parcel:Parcel) {
		var info = loading_parcels.get(parcel);
		var resource_id = parcel.loaded[0];
		var resource = Luxe.resources.audio(resource_id);
		var source = resource.source;

		var motif = info.motif;
		var energy = info.energy;

		switch (info.target) {
			case MusicSlot.current_energy:
				// Immediately replace the current_energy slot
				if (current_energy != null) {
					// Clean up the currently playing handle
					var old_handle = current_energy.handle;
					if (Luxe.audio.state_of(old_handle) != as_invalid) {
						Luxe.audio.stop(old_handle);
					}
				}

				var handle = Luxe.audio.play(source, master_volume);

				current_energy = {
					handle: handle,
					source: source,
					motif: motif,
					energy: energy
				};

			case MusicSlot.next_energy:
				// NOTE: next_energy is never playing. It is just loaded, ready to be played.
				// So there is never an AudioHandle to clean up here
				next_energy = {
					source: source,
					motif: motif,
					energy: energy
				};

			case MusicSlot.next_motif:
				// NOTE: next_motif is never playing. Having it set just means it is loaded, ready to be played.
				// When we crossfade to the next motif, crossfading_motif has the playing instance, and next_motif is null
				// until the next motif is chosen and loaded.
				next_motif = {
					source: source,
					motif: motif,
					energy: energy
				}
		}
	}

	public static function pause() {
		paused = true;
	}

	public static function resume() {
		paused = false;
	}

	static function start_crossfade() {
		// Begin crossfade
		crossfading_motif = next_motif;
		crossfading_motif.handle = Luxe.audio.play(crossfading_motif.source, 0);
		crossfade_start_time = Luxe.time;

		choose_next_motif();
	}

	static function choose_next_motif() {
		next_motif = null;
		var random = Luxe.utils.random;
		var motif:Int;
		if (unplayed_motifs.length > 0) {
			motif = unplayed_motifs[random.int(unplayed_motifs.length)];
			unplayed_motifs.remove(motif);
		} else {
			motif = random.int(motif_count) + 1;
		}

		load_music_async(MusicSlot.next_motif, motif, 1);
	}

	public static function update(dt:Float) {
		if (paused || current_energy == null) {
			return;
		}

		var current_energy_pos = Luxe.audio.position_of(current_energy.handle);

		// Check if someone has requested a transition to the next motif
		if (transition_to_next_motif && next_motif != null) {
			transition_to_next_motif = false;
			var motif_crossfade_threshold = crossfade_length_seconds;
			var time_left_in_loop = loop_length_seconds - current_energy_pos;

			if (time_left_in_loop > motif_crossfade_threshold) {
				start_crossfade();
			} else {
				// Set the next motif to start playing at full volume at the end of the current loop
				next_energy = next_motif;
				choose_next_motif();
			}
		}

		// Update crossfade
		if (crossfading_motif != null) {
			var fade_to = crossfading_motif;
			var fade_from = current_energy;

			var elapsed_time = Luxe.time - crossfade_start_time;
			var t = Maths.clamp(elapsed_time / crossfade_length_seconds, 0, 1);
			var pi = Math.PI;
			var fade_from_volume = (Math.cos(t * pi) + 1.0) * 0.5 * master_volume;
			var fade_to_volume = (Math.cos((1.0 - t) * pi) + 1.0) * 0.5 * master_volume;

			Luxe.audio.volume(fade_from.handle, fade_from_volume);
			Luxe.audio.volume(fade_to.handle, fade_to_volume);

			if (elapsed_time >= crossfade_length_seconds) {
				current_energy = crossfading_motif;
				crossfading_motif = null;
			}
		}

		// Check if we've reached the end of the current loop
		if (current_energy_pos >= loop_length_seconds) {
			if (next_energy != null) {
				// If the next energy level is loaded, we can switch to it
				var handle = Luxe.audio.play(next_energy.source, Luxe.audio.volume_of(current_energy.handle));
				current_energy = next_energy;
				current_energy.handle = handle;

				// Select the next energy level and load it
				next_energy = null;
				var random = Luxe.utils.random;
				var motif = current_energy.motif;
				var energy = random.int(1, 7);//((current_energy.energy - 1) + random.int(-1, 1)) % 7 + 1;
				
				load_music_async(MusicSlot.next_energy, motif, energy);
			} else {
				// The next energy has not yet loaded, fallback to looping this energy level
				current_energy.handle = Luxe.audio.play(current_energy.source, Luxe.audio.volume_of(current_energy.handle));
			}
		}
	}
}

typedef MusicParcelInfo = {
	var target:MusicSlot;
	var motif:Int;
	var energy:Int;
}

typedef MusicInstance = {
	@:optional var handle:AudioHandle;
	var source:AudioSource;
	var motif:Int;
	var energy:Int;
}

@:enum abstract MusicSlot(Int) from Int to Int {
	var current_energy = 0;
	var next_energy = 1;
	var next_motif = 2;
}
