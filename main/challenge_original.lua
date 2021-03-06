--[[local highscore
local score
local brake_score -- the score when the player used brakes for the first time]]
local word_streaks
local color_streaks
local max_word_streak
local max_color_streak
local word_streak_scores
local color_streak_scores
local brake_used -- this boolean variable is used for challenge no 6 and 8 after so loops its value is set

--[[
	The challenges should get harder as the player gets better. So it needs to communicate with the analyser script to determine the kind of 
	challenges the player gets by looking at the player stats.
]]

-- I need to decide what n is how to set the appropriate value of n
-- Some challenges will be very difficult so they either need to be changed or need to be set for the very best players(NB the analyer would take
--into account how often the players beats the highscore and how large the margin is) I have to make a decision
--I'm designing the challenges with the intention of making a miss gameover instead of giving the players chances
local challenges = {--[[1]]	"REACH A SCORE OF "..tostring(n),
--[[2]]	"REACH A SCORE OF\n"..tostring(n).." WITHOUT USING BRAKES",

--[[3]]	"BEAT YOUR HIGHSCORE",
--[[4]] "BEAT YOUR HIGHSCORE\nWITHOUT USING BRAKES",

--[[5]]	"GET A "..tostring(n).."X COLOR STREAK",
--[[6]]	"GET A "..tostring(n).."X COLOR STREAK\nWITHOUT USING BRAKES",

--[[7]]	"GET A "..tostring(n).."X WORD STREAK",
--[[8]]	"GET A "..tostring(n).."X WORD STREAK\nWITHOUT USING BRAKES",

--[[9]]	"DOUBLE YOUR HIGHSCORE",
--[[10]]"DOUBLE YOUR HIGHSCORE\nWITHOUT USING BRAKES",

--[[11]]"TRIPLE YOUR HIGHSCORE",
--[[12]]"TRIPLE YOUR HIGHSCORE\nWITHOUT USING BRAKES"
}

local chosen_chal_index
local n


local check_memory_loc = function(str)
	local file = sys.get_save_file(folder, str)
	local cell = sys.load(file)
	return cell[1]
end

--local no_challenge = nil
local save_to_memory_loc = function(str, n)
	local file = sys.get_save_file(folder, str)
	local tab = {n}
	sys.save(file, tab)
end

local new_chal_qst = "new chal qst" --this is the location in the memory the script checks to know if the challenge being set is a new one. true if it is and false if not
local challenge
local challenges_passed = 0
local challenge_status -- true if the challenge was passed and false if not
local prev_index -- this is the index of the previous challenge it is needed to avoid set the same challenge twice in a row after a change is reqested by the player
local chal_reward
--This function sets the challenge.
local set_challenge = function(index)
	if check_memory_loc("chal_index") == nil then	
		chosen_chal_index = 1--math.random(#challenges)---------------------------------------------------------------------------------------------------------------------------
		if chosen_chal_index == prev_index then
			--[[if chosen_chal_index == #challenges then -- to stop it from passing the limit of the table-------------------------------------------------------------------------------------------
				chosen_chal_index = chosen_chal_index - 1
			else
				chosen_chal_index = chosen_chal_index + 1
			end]]
		end
		challenge_status = false
	else
		chosen_chal_index = check_memory_loc("chal_index")
		challenge_status = check_memory_loc("chal_status")
	end
	challenges = {--[[1]]	"Reach a score of "..tostring(n),
	--[[2]]	"Reach a score of "..tostring(n).."\nwithout using brakes",
	
	--[[3]]	"Beat your highscore",
	--[[4]] "Beat your highscore\nwithout using brakes",
	
	--[[5]]	"Get a "..tostring(n).."X color streak",
	--[[6]]	"Get a "..tostring(n).."X color streak\nwithout using brakes",
	
	--[[7]]	"Get a "..tostring(n).."X word streak",
	--[[8]]	"Get a "..tostring(n).."X word streak\nwithout using brakes",
	
	--[[9]]	"Double your highscore",
	--[[10]]"Double your highscore\nwithout using brakes",
	
	--[[11]]"Triple your highscore",
	--[[12]]"Triple your highscore\nwithout using brakes"
	}
	if challenge_status then
		chal_reward = check_memory_loc("reward")
	else
		chal_reward = n * chosen_chal_index
	end
	challenge = challenges[chosen_chal_index]
	save_to_memory_loc("chal_index", chosen_chal_index)
	save_to_memory_loc("chal_status", challenge_status)
	--this enables the analyzer script that needs the information to know if it is a new challenge is being set or not
	if check_memory_loc(new_chal_qst) == true then
		--notify the analyser
		msg.post(analyzer, "new_chal")
		--set the state to false
		save_to_memory_loc(new_chal_qst, false)
	end
end

local chal_status_check = function()
	if chosen_chal_index == 1 then
		if score == n then
			if n <= 1000 then
				--n = n + 5----------------------------------------------------------------------------------------------------------------------------
				save_to_memory_loc("n"..tostring(chosen_chal_index), n)
			end
			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 2 then
		if score == n and brake_score < n then
			if n <= 1000 then
				n = n + 5
				save_to_memory_loc("n"..tostring(chosen_chal_index), n)
			end
			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)	
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 3 then
		if score > highscore then

			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)	
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 4 then
		if score > n and brake_score < n then

			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)	
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 5 then
		if n >= max_color_streak then

			n = n + 1
			save_to_memory_loc("n"..tostring(chosen_chal_index), n)
			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 6 then
		if n >= max_color_streak and brake_used == false then

			n = n + 1
			save_to_memory_loc("n"..tostring(chosen_chal_index), n)
			challenge_status = true
			challenges_passed = challenges_passed + 1
			save_to_memory_loc("chal_status", true)
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 7 then
		if n >= max_word_streak then

			n = n + 1
			save_to_memory_loc("n"..tostring(chosen_chal_index), n)
			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 8 then
		if n >= max_word_streak and brake_used == false then

			n = n + 1
			save_to_memory_loc("n"..tostring(chosen_chal_index), n)
			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 9 then
		local val = 2 * highscore
		if score >= val then

			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 10 then
		local val = 2 * highscore
		if score >= val and brake_score <= val then

			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 11 then
		local val = 3 * highscore
		if score >= val then

			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)
			save_to_memory_loc("reward", chal_reward)
		end
	elseif chosen_chal_index == 12 then
		local val = 3 * highscore
		if score >= val and brake_score <= val then

			challenges_passed = challenges_passed + 1
			challenge_status = true
			save_to_memory_loc("chal_status", true)
			save_to_memory_loc("reward", chal_reward)
		end
	end
	if lvl_loaded then
		msg.post("level:/controller#controller", "challenge_check_completed")
	end
end

function init(self)
	math.randomseed(os.time() * 1005)
	set_challenge()
end

function final(self)

end

function on_message(self, message_id, message, sender)
	-- message ids
	local msg_set_chal = hash("set_chal")
	local msg_change_chal = hash("change_challenge")
	local msg_chal_req = hash("challenges_requested")
	local msg_check_chal = hash("check_challenge")
	local msg_reward = hash("reward")
	local msg_give_reward = hash("give_reward")
	local msg_lvl_ended = hash("level_ended")

	if message_id == msg_change_chal then
		prev_index = chosen_chal_index
		save_to_memory_loc("chal_index", nil) -- clear the memory location
		set_challenge()
	elseif message_id == msg_give_reward then
		money = money + chal_reward
		msg.post(sender, "chal_reward")
		msg.post(analyzer, "chal_passed")
		-- This is needed by the analyser to check if a new challenge has been set. The code below allows the challenge
		--script to know that the next challenge is a new one
		save_to_memory_loc(new_chal_qst, true)
	elseif message_id == msg_chal_req then
		msg.post(sender, "chal", {c = challenge, status = challenge_status, reward = chal_reward})
	elseif message_id == msg_reward then
		chal_reward = chal_reward * message.num_of_clrs -- calculate the actual reward for the challenge
		lvl_loaded = true
	elseif message_id == msg_lvl_ended then
		chal_reward = chal_reward / message.num_of_clrs -- set the reward back to the base reward because it was multiplied by the num_of_colors_picked
		lvl_loaded = true
	elseif message_id == msg_check_chal then
		word_streaks = message.word
		color_streaks = message.color
		word_streak_scores = message.word_score
		color_streak_scores = message.color_score
		max_word_streak = table.maxn(word_streaks)
		max_color_streak = table.maxn(color_streaks)
		--The if statement below check if the player used brakes before getting the streak
		if chosen_chal_index == 6 then
			for k, v in ipairs(color_streaks) do
				if v >= n then
					if color_streak_scores[k] < brake_score then
						brake_used = false
						break
					end
				end
			end
		elseif chosen_chal_index == 8 then
			for k, v in ipairs(word_streaks) do
				if v >= n then
					if word_streak_scores[k] < brake_score then
						brake_used = false
						break
					end
				end
			end
		end
		chal_status_check()
		msg.post(sender, "chal", {c = challenge, status = challenge_status, reward = chal_reward})
	end
end