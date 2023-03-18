Config = {}

Config.RaceTimesDefault = 5
Config.RaceTimesMax = 15

Config.RaceSetup = {
	["race1"] = {
        startdelay = 30, -- seconds till start
        maxtime = 120, -- seconds (used for the race i.e. max time players have to race, and "timeout" i.e. when there isn't enough players to start the race)
        maxdistance = 5, -- from checkpoint
		--minplayers = 12, -- minimum players required (not required to be defined)
        startingalert = {20,10,5,4,3,2,1}, -- when it will alert the player of how many seconds till the race starts
		checkpoints = {
			[1] = {337731,-474499,-86083},
			[2] = {333514,-478761,-86616},
			[3] = {335405,-491514,-85491},
			[4] = {346331,-495696,-87551},
			[5] = {361241,-495675,-87115},
			[6] = {374553,-496587,-86881},
			[7] = {371282,-499253,-86240},
			[8] = {382969,-501401,-85004},
		}
	}
}