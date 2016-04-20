package states;

import luxe.Input;
import luxe.Text;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;

import luxe.utils.Maths;

import snow.types.Types.AudioState;

class MusicTest extends luxe.States.State {
	var current_energy_text:Text;
	var current_energy_progress:ProgressBar;
	var current_energy_volume:ProgressBar;

	var crossfading_motif_text:Text;
	var crossfading_motif_progress:ProgressBar;
	var crossfading_motif_volume:ProgressBar;

	var next_energy_text:Text;
	var next_motif_text:Text;
	var status_text:Text;
	
	var font_size = 12;

	override function onenter<T>(_:T) {
		var progress_bar_size = new Vector(Main.w_points * 0.25, font_size);

		current_energy_text = new Text({
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.1),
			point_size: font_size
		});
		current_energy_progress = new ProgressBar({
			pos: new Vector(current_energy_text.pos.x + 128, current_energy_text.pos.y),
			size: progress_bar_size
		});
		current_energy_volume = new ProgressBar({
			pos: new Vector(current_energy_progress.pos.x + progress_bar_size.x + 8, current_energy_text.pos.y),
			size: progress_bar_size
		});

		next_energy_text = new Text({
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.3),
			point_size: font_size
		});

		next_motif_text = new Text({
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.5),
			point_size: font_size
		});

		crossfading_motif_text = new Text({
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.7),
			point_size: font_size
		});
		crossfading_motif_progress = new ProgressBar({
			pos: new Vector(crossfading_motif_text.pos.x + 128, crossfading_motif_text.pos.y),
			size: progress_bar_size
		});
		crossfading_motif_volume = new ProgressBar({
			pos: new Vector(crossfading_motif_progress.pos.x + progress_bar_size.x + 8, crossfading_motif_progress.pos.y),
			size: progress_bar_size
		});

		status_text = new Text({
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.9),
			point_size: font_size
		});

		Music.init();
	}

	override function onleave<T>(_:T) {
		Luxe.scene.empty();
	}

	override function onkeydown(e:KeyEvent) {
		switch (e.keycode) {
			case Key.left:
			case Key.right:
			case Key.up:
			case Key.down:
			case Key.key_t:
				Music.transition_to_next_motif = !Music.transition_to_next_motif;
			case Key.key_p:
				Music.pause();
		}
	}

	override function update(dt:Float) {
		current_energy_text.text = 'current_energy\n' + get_debug_text(Music.current_energy);
		next_energy_text.text = 'next_energy\n' + get_debug_text(Music.next_energy);
		next_motif_text.text = 'next_motif\n' + get_debug_text(Music.next_motif);
		crossfading_motif_text.text = 'crossfading_motif\n' + get_debug_text(Music.crossfading_motif);

		if (Music.current_energy != null) {
			if (Music.current_energy.handle == null) {
				current_energy_progress.progress = 0;
				current_energy_volume.progress = 0;
			} else {
				current_energy_progress.progress = Luxe.audio.position_of(Music.current_energy.handle) / Music.loop_length_seconds;
				current_energy_volume.progress = Luxe.audio.volume_of(Music.current_energy.handle);
			}
		}

		if (Music.crossfading_motif != null) {
			if (Music.crossfading_motif.handle == null) {
				crossfading_motif_progress.progress = 0;
				crossfading_motif_volume.progress = 0;
			} else {
				crossfading_motif_progress.progress = Luxe.audio.position_of(Music.crossfading_motif.handle) / Music.loop_length_seconds;
				crossfading_motif_volume.progress = Luxe.audio.volume_of(Music.crossfading_motif.handle);
			}
		}

		status_text.text = 'transition_to_next_motif: ${Music.transition_to_next_motif}\n' +
			'paused: ${Music.paused}';
	}

	function get_debug_text(music:Music.MusicInstance) {
		if (music == null) {
			return 'null';
		}

		var motif = music.motif;
		var energy = music.energy;
		var handle = music.handle;
		var state_str = handle != null ? '${Luxe.audio.state_of(handle)}' : '(no handle)';

		return
			'motif: $motif, energy: $energy\n' +
			'  handle: $handle, state: $state_str\n';
	}
}

class ProgressBar extends Sprite {
	public var progress:Float = 0;

	public var indicator_sprite:Sprite;

	public override function new(?_options:luxe.options.SpriteOptions) {
		_options.centered = false;
		super(_options);

		indicator_sprite = new Sprite({
			parent: this,
			size: size,
			centered: false,
			color: new Color(0.2, 0.8, 0.8)
		});
	}

	override function update(dt:Float){
		var t = Maths.clamp(progress, 0, 1);
		indicator_sprite.scale.x = t;
	}
}
