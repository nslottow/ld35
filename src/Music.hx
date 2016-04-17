package;

import luxe.Audio;
import luxe.resource.Resource;
import luxe.Parcel;
import luxe.ParcelProgress;
import snow.types.Types.AudioHandle;

/**
3 audio players at any given time
	currently playing e-level
	next energy level cued up
	every 24 seconds, swap players
	next level's first energy level should be playing muted to keep it in sync
		on the elevator, fade 
		


	2 players per music instance because they have a tail

	trigger the next thing every 24 seconds
		whether it be the next energy or the next song
**/
class Music {
	static var active_energy:MusicInstance;
	static var next_energy:MusicInstance;
	static var next_motif:MusicInstance;

	//static var assets_by_level:Map<Int, Array<AudioResource>> = new Map<Int, Array<AudioResource>>();

	public static function init() {
		/*
		var music_id = 'assets/music/l1-e1.ogg';
		var music_id2 = 'assets/music/l2-e3.ogg';
		var parcel = new Parcel({
			sounds: [
				{ id: music_id, is_stream: false },
				{ id: music_id2, is_stream: false }
			],
			oncomplete: function(_) {
				Luxe.audio.play(Luxe.resources.audio(music_id).source);
				Luxe.audio.play(Luxe.resources.audio(music_id2).source);
			}
		});

		parcel.load();
		*/
	}
}

typedef MusicInstance = {
	var active_handle:AudioHandle;
	var inactive_handle:AudioHandle;
	var source:AudioSource;
	var motif:Int;
	var energy:Int;
}
