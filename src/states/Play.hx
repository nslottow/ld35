package states;

import luxe.Input;
import entities.PlayerController;

class Play extends luxe.States.State {

	override function onenter<T>(_:T) {
		// Load the default map
		var map_id = 'assets/maps/env_test_00.json';
		trace('Loading tiled map: $map_id');
		Level.load_json(Luxe.resources.text(map_id).asset.text);
	}

	override function onleave<T>(_:T) {
		Luxe.scene.empty();
		Level.destroy();
	}

	override function onkeydown(e:KeyEvent) {
		if (e.keycode == Key.key_r) {
			Level.reload();
		}
	}
}

