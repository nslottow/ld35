package states;

import luxe.Input;
import luxe.Text;
import luxe.Vector;

class MusicTest extends luxe.States.State {
	var current_text:Text;
	var current_active_pos_text:Text;
	var current_inactive_pos_text:Text;
	var queued_text:Text;
	var transition_flag_text:Text;

	override function onenter<T>(_:T) {
		current_text = new Text({
			text: 'current energy',
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.1)
		});

		queued_text = new Text({
			text: 'queued motif',
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.4)
		});

		transition_flag_text = new Text({
			text: 'transition flag: ${Music.transition_next_loop}',
			pos: new Vector(Main.w_points * 0.1, Main.h_points * 0.7)
		});
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
				transition_flag_text.text = 'transition flag: ${Music.transition_next_loop}';
		}
	}

	function update_text() {
	}
}
