package entities;

import luxe.Sprite;
import luxe.Vector;
import luxe.Color;

import components.*;

class PlayerUnit extends Sprite {
	public var controller(default, set):PlayerController;
	public var tile_movement:TileMovement;
	
	public static var active_color = new Color(0.7, 0.1, 0.7, 0.8);
	public static var inactive_color = new Color(0.3, 0.0, 0.3, 0.8);

	public override function new(?_options:luxe.options.SpriteOptions) {
		// TMP: Make a tinted purple box
		_options.color = inactive_color;
		_options.centered = false;

		super(_options);
		
		tile_movement = add(new TileMovement({name: 'tile_movement'}));
	}

	override function ondestroy() {
		super.ondestroy();
		if (controller != null) {
			controller.units.remove(this);
		}
	}

	public function set_controller(_controller:PlayerController) {
		controller = _controller;
		if (_controller != null) {
			_controller.units.push(this);
			color = active_color;
		} else {
			color = inactive_color;
		}
		return _controller;
	}
}

