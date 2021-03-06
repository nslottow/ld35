package;

import luxe.Audio;
import luxe.resource.Resource;
import luxe.Parcel;
import luxe.ParcelProgress;
import snow.systems.audio.AudioSource;
import snow.types.Types.AudioHandle;
import snow.types.Types.AudioState;

class Sfx {
	public static var master_volume = 0.8;

	static var select_sfx:AudioSource;

	// in-game sfx
	static var move_sfx:Array<AudioSource>;
	static var fall_sfx:AudioSource;
	static var eat_sfx:AudioSource;
	static var rifle_sfx:AudioSource;
	static var splat_sfx:AudioSource;

	static var to_play_next_tick:Map<AudioSource, SfxInfo>;
	static var evt_tick:String;

	public static function init_game_sfx() {
		move_sfx = [
			Luxe.resources.audio('assets/sfx/move-1.ogg').source,
			Luxe.resources.audio('assets/sfx/move-2.ogg').source,
			Luxe.resources.audio('assets/sfx/move-3.ogg').source,
			Luxe.resources.audio('assets/sfx/move-4.ogg').source
		];

		fall_sfx = Luxe.resources.audio('assets/sfx/fall-1.ogg').source;
		eat_sfx = Luxe.resources.audio('assets/sfx/eat-1.ogg').source;
		rifle_sfx = Luxe.resources.audio('assets/sfx/rifle-1.ogg').source;
		splat_sfx = Luxe.resources.audio('assets/sfx/splat-1.ogg').source;

		to_play_next_tick = new Map<AudioSource, SfxInfo>();

		evt_tick = Level.on('post_tick', post_tick);
	}

	public static function play_move(count:Int) {
		var random = Luxe.utils.random;
		var delay = 0.05;

		var unplayed_sfx = move_sfx.copy();

		for (i in 0...count) {
			var sfx = unplayed_sfx[random.int(unplayed_sfx.length)];
			unplayed_sfx.remove(sfx);
			var volume = random.float(0.5, 0.6) / count;
			Luxe.timer.schedule(delay, function() {
				Luxe.audio.play(sfx, volume * master_volume);
			});
			delay += random.float(0.01, 0.05);
		}
	}

	public static function play_fall(count:Int) {
		var random = Luxe.utils.random;
		var delay = 0.05;

		for (i in 0...count) {
			var volume = random.float(0.5, 0.6) / count;
			Luxe.timer.schedule(delay, function() {
				Luxe.audio.play(fall_sfx, volume * master_volume);
			});
			delay += random.float(0.01, 0.05);
		}
	}

	public static function play_eat() {
		queue_for_tick({
			source: eat_sfx,
			delay: 0.02,
			delay_delta_min: 0.1,
			delay_delta_max: 0.2,
			volume_min: 0.7,
			volume_max: 0.8
		});
	}

	public static function play_rifle() {
		queue_for_tick({
			source: rifle_sfx,
			delay: 0,
			delay_delta_min: 0,
			delay_delta_max: 0,
			volume_min: 0.7,
			volume_max: 0.7
		});
	}

	public static function play_splat(delay:Float=0) {
		queue_for_tick({
			source: splat_sfx,
			delay: delay,
			delay_delta_min: 0,
			delay_delta_max: 0,
			volume_min: 0.8,
			volume_max: 0.8
		});
	}

	static function queue_for_tick(info:SfxInfo) {
		var source = info.source;
		var existing_info = to_play_next_tick.get(source);
		if (existing_info == null) {
			trace('sfx: adding new sound for next tick');
			info.count = 1;
			to_play_next_tick.set(source, info);
		} else {
			++existing_info.count;
		}
	}

	static function post_tick(_) {
		var played_count = 0;
		var random = Luxe.utils.random;
		for (source in to_play_next_tick.keys()) {
			var info = to_play_next_tick.get(source);
			var count = info.count;
			if (count > 3) {
				count = 3;
			}

			var delay = info.delay;
			for (i in 0...count) {
				var volume = random.float(info.volume_min, info.volume_max) / count;
				Luxe.timer.schedule(delay, function() {
					Luxe.audio.play(source, volume * master_volume);
				});

				delay += random.float(info.delay_delta_min, info.delay_delta_max);
			}

			played_count += count;
		}

		if (played_count > 0) {
			trace('sfx: played $played_count scheduled sounds this tick');
		}

		to_play_next_tick = new Map<AudioSource, SfxInfo>();
	}
}

typedef SfxInfo = {
	var source:AudioSource;
	var delay:Float;
	var delay_delta_min:Float;
	var delay_delta_max:Float;
	var volume_min:Float;
	var volume_max:Float;
	@:optional var count:Int;
}
