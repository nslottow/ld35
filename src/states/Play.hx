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
	var initial_map_index:Null<Int>;

	override function onenter<T>(_map_index:T) {
		initial_map_index = cast _map_index;


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

		if (initial_map_index != null) {
			Level.load_indexed_map(initial_map_index, function() {
				loading_indicator.active = false;
				loading_indicator.visible = false;
				Luxe.core.off(Ev.update, update_loading_indicator);
			});
		} else {
			// Load the default map
			var map_id = 'assets/maps/env_test_00.json';
			Level.load_json(Luxe.resources.text(map_id).asset.text);
		}
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
		switch (e.keycode) {
			case Key.key_r:
				Level.reload();
			case Key.escape:
				Main.states.set('level_select');
		}
	}
}

