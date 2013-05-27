
local BALL_PUSH_CHECK_INTERVAL = 0.1

minetest.register_entity("soccer:ball", {
	physical = true,
	visual = "mesh",
	mesh = "soccer_ball.x",
	hp_max = 1000,
	groups = { immortal = true },
	textures = { "wool_white.png" },
	collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= BALL_PUSH_CHECK_INTERVAL then
			self.timer = 0
			if self:is_moving() then
				local p = self.object:getpos();
				p.y = p.y - 0.5
				local walkable = minetest.registered_nodes[minetest.env:get_node(p).name].walkable
				print("walkable: "..tostring(walkable))
				if walkable then
					local vel = self.object:getvelocity()
					vel.x = vel.x * 0.80
					vel.z = vel.z * 0.80
					self.object:setvelocity(vel)
					--return
				end
			end
			local pos = self.object:getpos()
			local objs = minetest.env:get_objects_inside_radius(pos, 1)
			local player_count = 0
			local final_dir = { x=0, y=0, z=0 }
			for _,obj in ipairs(objs) do
				if obj:is_player() then
					local objdir = obj:get_look_dir()
					local mul = 1
					if (obj:get_player_control().sneak) then
						mul = 3
					end
					final_dir.x = final_dir.x + (objdir.x * mul)
					final_dir.y = final_dir.y + (objdir.y * mul)
					final_dir.z = final_dir.z + (objdir.z * mul)
					player_count = player_count + 1
				end
			end
			if final_dir.x ~= 0 or final_dir.y ~= 0 or final_dir.z ~= 0 then
				final_dir.x = (final_dir.x * 5) / player_count
				final_dir.y = (final_dir.y * 5) / player_count
				final_dir.z = (final_dir.z * 5) / player_count
				local accel = {
					x = 0,
					y = -(final_dir.y / 2) - 4,
					z = 0,
				}
				self.object:setvelocity(final_dir)
				self.object:setacceleration(accel)
			end
		end
	end,
	on_punch = function(self, puncher)
		if puncher and puncher:is_player() then
			local inv = puncher:get_inventory()
			inv:add_item("main", ItemStack("soccer:ball_item"))
			self.object:remove()
		end
	end,
	is_moving = function(self)
		local v = self.object:getvelocity()
		if  (math.abs(v.x) <= 0.1)
		 and (math.abs(v.y) <= 0.1)
		 and (math.abs(v.z) <= 0.1) then
			self.object:setvelocity({x=0, y=0, z=0})
			return false
		end
		return true
	end,
	timer = 0,
})

minetest.register_craftitem("soccer:ball_item", {
	description = "Soccer Ball",
	inventory_image = "default_sand.png",
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		--pos = { x=pos.x+0.5, y=pos.y, z=pos.z+0.5 }
		local ent = minetest.env:add_entity(pos, "soccer:ball")
		ent:setvelocity({x=0, y=-4, z=0})
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_node("soccer:goal", {
	description = "Soccer Goal",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = { "soccer_white.png" },
	sunlight_propagates = true,
	groups = { snappy=1, cracky=1, fleshy=1, oddly_breakable_by_hand=1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -2.5, -0.5, -0.1, -2.3, 1.5, 0.1 },
			{  2.3, -0.5, -0.1,  2.5, 1.5, 0.1 },
			{ -2.5,  1.5, -0.1,  2.5, 1.7, 0.1 },
		},
	},
})

minetest.register_node("soccer:goal_mark", {
	description = "Soccer Goal Mark",
	drawtype = "raillike",
	paramtype = "light",
	walkable = false,
	inventory_image = "soccer_goal_mark.png",
	tiles = { "soccer_goal_mark.png" },
	sunlight_propagates = true,
	groups = { snappy=1, cracky=1, fleshy=1, oddly_breakable_by_hand=1 },
})

soccer = {}

soccer.matches = { count = 0 }

function soccer:create_match()
	for n = 1, self.matches.count do
		if not self.matches[id] then
			self.matches[id] = {
				players = { },
			}
			return id
		end
	end
end

function soccer:match_score(id, player)
	
end

minetest.register_node("soccer:controller", {
	description = "Soccer Goal Mark",
	drawtype = "raillike",
	paramtype = "light",
	tiles = { "soccer_goal_mark.png" },
	sunlight_propagates = true,
	groups = { snappy=1, cracky=1, fleshy=1, oddly_breakable_by_hand=1 },
})
