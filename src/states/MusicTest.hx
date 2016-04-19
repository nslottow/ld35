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
	var next_energy_text:Text;
	var next_motif_text:Text;
	var status_text:Text;
	
	var font_size = 14;

	override function onenter<T>(_:T) {
		current_energy_text = new Text({
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.1),
			point_size: font_size
		});

		var progress_bar_size = new Vector(Main.w_points * 0.4, font_size);
		current_energy_progress = new ProgressBar({
			pos: new Vector(current_energy_text.pos.x + 128, current_energy_text.pos.y),
			size: progress_bar_size
		});

		next_energy_text = new Text({
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.4),
			point_size: font_size
		});

		next_motif_text = new Text({
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.7),
			point_size: font_size
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
				Music.transition_next_loop = !Music.transition_next_loop;
			case Key.key_p:
				Music.pause();


		}
	}

	override function update(dt:Float) {
		current_energy_text.text = 'current_energy\n' + get_debug_text(Music.current_energy);
		next_energy_text.text = 'next_energy\n' + get_debug_text(Music.next_energy);
		next_motif_text.text = 'next_motif\n' + get_debug_text(Music.next_motif);

		// TODO: It would be nice to show a progress bar along with a volume for each
		if (Music.current_energy != null) {
			current_energy_progress.progress = Luxe.audio.position_of(Music.current_energy.active_handle) / 24;
		}

		status_text.text = 'transition_next_loop: ${Music.transition_next_loop}\n' +
			'paused: ${Music.paused}';
	}

	function get_debug_text(music:Music.MusicInstance) {
		if (music == null) {
			return 'null';
		}

		var motif = music.motif;
		var energy = music.energy;
		var active_handle = music.active_handle;
		var active_state = Luxe.audio.state_of(active_handle);
		var active_vol = Luxe.audio.volume_of(active_handle);
		var active_pos = Luxe.audio.position_of(active_handle);

		var inactive_handle = music.inactive_handle;
		var inactive_state = Luxe.audio.state_of(inactive_handle);
		var inactive_vol = Luxe.audio.volume_of(inactive_handle);
		var inactive_pos = Luxe.audio.position_of(inactive_handle);

		return
			'motif: $motif, energy: $energy\n' +
			'active\n' +
			'  handle: $active_handle, state: $active_state\n' +
			'  vol: $active_vol\n  pos: $active_pos\n' +
		    'inactive\n' +
			'  handle: $inactive_handle, state: $inactive_state\n' +
			'  vol: $inactive_vol\n  pos: $inactive_pos';
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
