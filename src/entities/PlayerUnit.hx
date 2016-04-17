package entities;

import luxe.Entity;
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

		events.listen('bumped_by', on_bumped_by);
	}

	override function ondestroy() {
		super.ondestroy();
		if (controller != null) {
			controller.units.remove(this);
		}
	}

	function on_bumped_by(other:Entity) {
		if (controller == null && Std.is(other, PlayerUnit)) {
			var other_unit:PlayerUnit = cast other;
			controller = other_unit.controller;
		}
	}

	public function set_controller(_controller:PlayerController) {
		if (_controller != null) {
			if (controller != _controller) {
				_controller.units.push(this);
			}
			color = active_color;
		} else {
			color = inactive_color;
		}
		return controller = _controller;
	}
}

