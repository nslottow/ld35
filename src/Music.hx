package;

import luxe.Audio;
import luxe.resource.Resource;
import luxe.Parcel;
import luxe.ParcelProgress;
import snow.types.Types.AudioHandle;
import snow.types.Types.AudioState;

import luxe.utils.Maths;

/**
	TODO: When changing energy level, no need to crossfade
	TODO: Change motifs randomly at any point in time -> crossfade new motif
	TODO: If the new motif is requested within 2-3 seconds of a boundary, wait for the boundary
**/
class Music {
	public static var current_energy:MusicInstance;
	public static var next_energy:MusicInstance;
	public static var next_motif:MusicInstance;

	static var fade_to:MusicInstance;
	static var fade_from:MusicInstance;

	static inline var music_volume = 0.3;

	public static var transition_next_loop:Bool = false;

	public static inline var loop_length_seconds:Float = 24;
	public static inline var fade_length_seconds:Float = 2;
	public static inline var fade_steps:Int = 30;
	public static inline var fade_timer_interval:Float = fade_length_seconds / fade_steps;

	static var loading_parcels = new Map<Parcel, MusicParcelInfo>();
	static var loop_timer:snow.api.Timer;
	static var fade_timer:snow.api.Timer;
	static var fade_start_time:Float;
	static var on_fade_complete:Void->Void;

	public static function init() {
		load_parcel('current_energy', 2, 1);
		load_parcel('next_energy', 2, 2);
		load_parcel('next_motif', 2, 1);
	}

	public static function load_parcel(target:String, motif:Int, energy:Int) {
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

		switch (info.target) {
			case 'current_energy':
				trace('loaded active: $resource_id');
				if (current_energy == null) {
					// Startup two handles for looping
					var active_handle = Luxe.audio.play(resource.source, music_volume);
					var inactive_handle = Luxe.audio.play(resource.source, music_volume);
					Luxe.audio.pause(inactive_handle);

					current_energy = {
						active_handle: active_handle,
						inactive_handle: inactive_handle,
						source: resource.source,
						motif: info.motif,
						energy: info.energy
					};

					// Start the timer to swap the active and inactive handle
					loop_timer = Luxe.timer.schedule(loop_length_seconds, loop_handler, true);

					// TODO: if this loads after next energy, setup the next energy position
					// or just load next energy here
				}

			case 'next_energy':
				trace('loaded next: $resource_id');
				if (next_energy == null) {
					var active_handle = Luxe.audio.play(resource.source, 0);
					var inactive_handle = Luxe.audio.play(resource.source, 0);
					Luxe.audio.pause(inactive_handle);

					var elapsed_time:Float = 0;
					if (loop_timer != null) {
						elapsed_time = snow.Snow.timestamp - (loop_timer.fire_at - loop_timer.time);
					}
					Luxe.audio.position(active_handle, elapsed_time);

					next_energy = {
						active_handle: active_handle,
						inactive_handle: inactive_handle,
						source: resource.source,
						motif: info.motif,
						energy: info.energy
					};
				}
		}
	}

	public static function pause() {
	}

	public static function resume() {
	}

	static function loop_handler() {
		trace('swapping active music handles');
		swap_active_handles(current_energy);
		swap_active_handles(next_energy);

		if (transition_next_loop) {
			transition_next_loop = false;

			trace('starting crossfade');

			// Start crossfading between current_energy and next_energy
			// TODO: When the crossfade finishes
			//   swap current and next energy level
			//   start loading next energy level
			fade_to = next_energy;
			fade_from = current_energy;
			fade_start_time = snow.Snow.timestamp;
			fade_timer = Luxe.timer.schedule(fade_timer_interval, fade_handler, true);
			on_fade_complete = function() {
				var old = current_energy;
				current_energy = next_energy;
				next_energy = null;

				// throw out the music that is totally faded out
				Luxe.audio.stop(old.active_handle);
				Luxe.audio.stop(old.inactive_handle);

				// start loading the next
				var next_energy_level = (fade_to.energy + 1) % 7 + 1;
				load_parcel('next_energy', current_energy.motif, next_energy_level);
			}
		}
	}

	static function fade_handler() {
		var elapsed_time = snow.Snow.timestamp - fade_start_time;
		var t = Maths.clamp(elapsed_time / fade_length_seconds, 0, 1);

		var pi = 3.1415;
		var fade_from_volume = (Math.cos(t * pi) + 1.0) * 0.5 * music_volume;
		var fade_to_volume = (Math.cos((1.0 - t) * pi) + 1.0) * 0.5 * music_volume;

		trace('elapsed: $elapsed_time, t: $t, fade_to_volume: $fade_to_volume, fade_from_volume: $fade_from_volume');

		Luxe.audio.volume(fade_to.active_handle, fade_to_volume);
		Luxe.audio.volume(fade_to.inactive_handle, fade_to_volume);

		Luxe.audio.volume(fade_from.active_handle, fade_from_volume);
		Luxe.audio.volume(fade_from.inactive_handle, fade_from_volume);

		if (elapsed_time >= fade_length_seconds) {
			fade_timer.stop();
			if (on_fade_complete != null) {
				on_fade_complete();
			}
		}
	}

	static function swap_active_handles(instance:MusicInstance) {
		if (instance == null) {
			return;
		}

		var new_active_handle = instance.inactive_handle;
		Luxe.audio.unpause(new_active_handle);
		Luxe.audio.position(new_active_handle, 0);

		if (Luxe.audio.state_of(new_active_handle) == as_invalid) {
			Luxe.audio.stop(new_active_handle);
			new_active_handle = Luxe.audio.play(instance.source, Luxe.audio.volume_of(instance.active_handle));
		}

		var new_inactive_handle = instance.active_handle;

		trace('active_handle: $new_active_handle, inactive_handle: $new_inactive_handle');

		instance.active_handle = new_active_handle;
		instance.inactive_handle = new_inactive_handle;
	}
}

typedef MusicInstance = {
	var active_handle:AudioHandle;
	var inactive_handle:AudioHandle;
	var source:AudioSource;
	var motif:Int;
	var energy:Int;
}

typedef MusicParcelInfo = {
	var target:String;
	var motif:Int;
	var energy:Int;
}
