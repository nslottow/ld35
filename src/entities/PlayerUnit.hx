package entities;

import luxe.Entity;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.Color;

import components.*;

class PlayerUnit extends Sprite {
	public var controller(default, set):PlayerController;
	public var tile_movement:TileMovement;
	public var group:Array<PlayerUnit>;
	public var group_id(default, set):Int = 0;
	
	public static var active_color = new Color(0.7, 0.1, 0.7, 0.8);
	public static var inactive_color = new Color(0.3, 0.0, 0.3, 0.8);
	public static var destruct_color = new Color(0.9, 0.3, 0.1, 0.5);

	public var destructing:Bool = false;

	var group_id_text:Text;

	public override function new(?_options:luxe.options.SpriteOptions) {
		// TMP: Make a tinted purple box
		_options.color = inactive_color;
		_options.centered = false;

		super(_options);
		
		tile_movement = add(new TileMovement({name: 'tile_movement'}));
		group = [this];

		group_id_text = new Text({
			point_size: 12,
			parent: this,
			align: TextAlign.center,
			pos: new Vector(size.x * 0.5, size.y * 0.5),
			depth: 200,
			text: Std.string(group_id)
		});

		events.listen('bumped_by', on_bumped_by);
		events.listen('entered_abyss', on_entered_abyss);
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
			if (!destructing) {
				controller = other_unit.controller;
			}
		}
	}

	function on_entered_abyss(abyss:Abyss) {
		controller = null;
		color = destruct_color;
		Luxe.timer.schedule(0.25, function() { 
			destroy();
		});
	}

	public function set_controller(_controller:PlayerController) {
		if (_controller != null) {
			if (controller != _controller) {
				_controller.units.push(this);
			}
			color = active_color;
		} else {
			if (controller != null) {
				controller.units.remove(this);
			}
			color = inactive_color;
		}
		return controller = _controller;
	}

	public function set_group_id(_group_id:Int) {
		if (_group_id != 0) {
			group_id_text.text = Std.string(_group_id);
			//group_id_text.visible = true;
		} else {
			//group_id_text.visible = false;
		}
		return group_id = _group_id;
	}
}

