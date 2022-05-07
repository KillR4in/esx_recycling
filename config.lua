Config              	= {}
Config.MarkerType   	= 1
Config.DrawDistance 	= 0
Config.ZoneSize     	= {x = 3.0, y = 3.0, z = 0.5}
Config.MarkerColor  	= {r = 100, g = 204, b = 100}
-- Show blip in map?
Config.ShowBlips    	= true

Config.Locale 			= 'br'

-- Before add any drug/item here you have to add the translation of the item
Config.Farms = {
	-- Translated name
	[_U('scrapyard')] = {
		Item1			= 'metalscrap',				 	-- Item to pickup 1
		Item2			= 'plastic',				 	-- Item to pickup 2
		Item3			= 'rubber',				 		-- Item to pickup 3
		Item4			= 'steel',				 		-- Item to pickup 4
		qtd1			= 5,							-- Quantity to pickup Item1
		qtd2			= 5,							-- Quantity to pickup Item2
		qtd3			= 5,							-- Quantity to pickup Item3
		qtd4			= 1,							-- Quantity to pickup Item4
		max1			= 100,							-- Max amount of Item1
		max2			= 100,							-- Max amount of Item2
		max3			= 100,							-- Max amount of Item3
		max4			= 20,							-- Max amount of Item4
		TimeToFarm		= 7,							-- Time to farm in seconds
		Zones 			= {
			Field 		= {x = 976.2405, y = -2290.6387, z = 30.5080},
		}
	}
}
