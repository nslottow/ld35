package states;

import luxe.Ev;
import luxe.Vector;
import luxe.Color;
import luxe.Input;
import luxe.Sprite;
import luxe.Parcel;
import luxe.ParcelProgress;

import entities.PlayerController;

/*
*/
class Play extends luxe.States.State {
	var parcel:Parcel;
	var loading_indicator:Sprite;

	override function onenter<T>(_:T) {
		parcel = new Parcel({
            jsons: [
				{ id:'assets/animations/cha_alien.json' },
				{ id:'assets/animations/cha_mib.json' }
			],
            textures: [
				{ id: 'assets/maps/tilesets/env.png' }, // default tileset
                { id: 'assets/textures/cha_alien.png' },
                { id: 'assets/textures/cha_mib.png' }
            ],
			texts: [
				{ id: 'assets/maps/env_test_00.json' }, // default map
			],
			sounds: [
				/*
				// NOTE: Not using ambient sfx for now
				{ id: 'assets/sfx/ambient-layer1.ogg', is_stream: false },
				{ id: 'assets/sfx/ambient-layer2.ogg', is_stream: false },
				{ id: 'assets/sfx/ambient-layer3.ogg', is_stream: false },
				*/
				{ id: 'assets/sfx/eat-1.ogg', is_stream: false },
				{ id: 'assets/sfx/elevator-1.ogg', is_stream: false },
				{ id: 'assets/sfx/elevatorbing-1.ogg', is_stream: false },
				{ id: 'assets/sfx/elevatorbing-2.ogg', is_stream: false },
				{ id: 'assets/sfx/fall-1.ogg', is_stream: false },
				{ id: 'assets/sfx/move-1.ogg', is_stream: false },
				{ id: 'assets/sfx/move-2.ogg', is_stream: false },
				{ id: 'assets/sfx/move-3.ogg', is_stream: false },
				{ id: 'assets/sfx/move-4.ogg', is_stream: false },
				{ id: 'assets/sfx/rifle-1.ogg', is_stream: false },
				{ id: 'assets/sfx/splat-1.ogg', is_stream: false },
				{ id: 'assets/sfx/switch-1.ogg', is_stream: false },
				{ id: 'assets/sfx/switch-2.ogg', is_stream: false },
			],
			oncomplete: on_loaded
        });

		loading_indicator = new Sprite({
			pos: new Vector(Main.w_points * 0.5, Main.h_points * 0.5),
			size: new Vector(96, 96),
			color: new Color(0.9, 0.2, 0.7),
			depth: 500 // on top of everything
		});

		Luxe.core.on(Ev.update, update_loading_indicator);

		parcel.load();
	}

	function on_loaded(_) {
		loading_indicator.active = false;
		loading_indicator.visible = false;
		Luxe.core.off(Ev.update, update_loading_indicator);

		// Load the default map
		var map_id = 'assets/maps/env_test_00.json';
		trace('Loading tiled map: $map_id');
		Level.load_json(Luxe.resources.text(map_id).asset.text);

		Sfx.init_game_sfx();
	}

	function update_loading_indicator(dt:Float) {
		loading_indicator.radians += 0.5 * dt;
	}

	override function onleave<T>(_:T) {
		// TODO: Cancel loading of the asset parcel
		Luxe.scene.empty();
		Level.destroy();

		Luxe.core.off(Ev.update, update_loading_indicator);
	}

	override function onkeydown(e:KeyEvent) {
		if (e.keycode == Key.key_r) {
			Level.reload();
		}
	}
}

