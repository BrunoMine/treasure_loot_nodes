--[[
	Mod Treasures_Loot_Nodes para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Loots aleatorios
  ]]

-- Variavel de controle de loot atual
local loot_atual = minetest.settings:get("treasures_loot_nodes_number_control") or "1"

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
local set_loot_node = {
	["default:chest"] = function(pos)
	
		local amount = math.random(1, 8)

		local treasures = treasurer.select_random_treasures(amount,1,10)

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		
		for i=1,#treasures do
			inv:set_stack("main",i,treasures[i])
		end
	end
}


-- Algoritimo para verificar se os nodes focam carregados com itens
minetest.register_lbm({
	name = "treasures_loot_nodes:loot_load",
	nodenames = {"default:chest"},
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		
		-- Verifica se ja foi carregado
		if meta:get_string("loot") == loot_atual then return end
		
		-- Verifica se existe esse tipo de node na tabela de loots
		set_loot_node[node.name](pos)
		
		-- Salva como carregado
		meta:set_string("loot", loot_atual)
	end,
})
