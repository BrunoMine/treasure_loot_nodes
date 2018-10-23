--[[
	Mod Treasures_Loot_Nodes para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Loots aleatorios
  ]]

-- Variavel de controle de loot atual
treasures_loot_nodes.loot_atual = tonumber(minetest.settings:get("treasures_loot_nodes_number_control") or "1")

-- Redefinr numero do loot atual
treasures_loot_nodes.reset_loot_atual = function()
	treasures_loot_nodes.loot_atual = treasures_loot_nodes.loot_atual + 1
	minetest.settings:set("treasures_loot_nodes_number_control", treasures_loot_nodes.loot_atual)
	minetest.settings:write()
end

-- Registrar itens para loot
local loot_items = {
--	itemstring			raridade	preciosidade	qtd min e max	desgaste para ferramentas min e max
--	"modname:item"			0.001 ~ 1.000	1 ~ 10		1 ~ 99
	{"default:gold_ingot",		1.0,		8,		{1,10},		nil		},
	{"default:axe_wood",		1.0,		1,		nil,		{100,10000}	},
}

for _,d in ipairs(loot_items) do
	treasurer.register_treasure(unpack(d))
end

-- Função para colocar loots
local set_loot_nodes = {
	["default:chest"] = function(pos)
	
		local amount = math.random(1, 8)

		local treasures = treasurer.select_random_treasures(amount,1,10)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		
		for i=1,#treasures do
			inv:set_stack("main", i, treasures[i])
		end
	end
}

-- Altera on_rightclick
local old_on_rightclick = {}
for nn,loot in pairs(set_loot_nodes) do
	old_on_rightclick[nn] = minetest.registered_nodes[nn].on_rightclick
	minetest.override_item(nn, {
		on_rightclick = function(pos, node, player, itemstack, pointed_thing)
			local meta = minetest.get_meta(pos)
		
			-- Verifica se ja foi carregado
			if tonumber(meta:get_string("treasures_loot_nodes_loot")) ~= treasures_loot_nodes.loot_atual then
				
				-- Verifica se existe esse tipo de node na tabela de loots
				set_loot_nodes[nn](pos)
				
				-- Salva como carregado
				meta:set_string("treasures_loot_nodes_loot", loot_atual)
			end
			
			if old_on_rightclick[nn] then
				return old_on_rightclick[nn](pos, node, player, itemstack, pointed_thing)
			end
		end
	})
	
end
