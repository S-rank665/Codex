local SoundService = game:GetService("SoundService")

local ShopDialogueService = {}
ShopDialogueService.__index = ShopDialogueService

local DEFAULT_TYPING_SOUND_ID = "rbxassetid://9118823100"

function ShopDialogueService.new(config)
	config = config or {}

	local self = setmetatable({}, ShopDialogueService)
	self.lines = config.lines or {
		"О, новый покупатель!",
		"Сегодня у нас отличные скидки.",
		"Осмотрись, тут много интересного.",
		"Выбирай спокойно, я подожду.",
	}
	self.voiceMap = config.voiceMap or {}
	self.typingSoundId = config.typingSoundId or DEFAULT_TYPING_SOUND_ID
	self.defaultTypingPitchRange = config.typingPitchRange or NumberRange.new(0.96, 1.04)
	self.onCharacterTyped = config.onCharacterTyped

	return self
end

function ShopDialogueService:SetLines(lines)
	assert(type(lines) == "table", "SetLines ожидает таблицу")
	self.lines = lines
end

function ShopDialogueService:AddLine(text, voiceSoundId)
	table.insert(self.lines, text)
	if voiceSoundId then
		self.voiceMap[text] = voiceSoundId
	end
end

function ShopDialogueService:GetRandomLine(rng)
	if #self.lines == 0 then
		return nil
	end

	rng = rng or Random.new()
	local index = rng:NextInteger(1, #self.lines)
	return self.lines[index]
end

function ShopDialogueService:SetVoiceForLine(text, soundId)
	self.voiceMap[text] = soundId
end

function ShopDialogueService:_createSound(soundId)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.8
	sound.RollOffMaxDistance = 30
	sound.Parent = SoundService
	return sound
end

function ShopDialogueService:PlayLine(text, outputLabel, typeSpeed)
	assert(type(text) == "string", "PlayLine ожидает строку")
	assert(outputLabel and outputLabel:IsA("TextLabel"), "PlayLine ожидает TextLabel")

	typeSpeed = typeSpeed or 0.025
	outputLabel.Text = ""

	local voiceSoundId = self.voiceMap[text]
	local hasVoiceLine = type(voiceSoundId) == "string" and voiceSoundId ~= ""

	if hasVoiceLine then
		local voiceSound = self:_createSound(voiceSoundId)
		voiceSound:Play()
		voiceSound.Ended:Connect(function()
			voiceSound:Destroy()
		end)
	end

	for i = 1, #text do
		local character = string.sub(text, i, i)
		outputLabel.Text = outputLabel.Text .. character

		if self.onCharacterTyped then
			self.onCharacterTyped(character, i)
		end

		if not hasVoiceLine and character ~= " " then
			local blip = self:_createSound(self.typingSoundId)
			blip.PlaybackSpeed = math.random(
				self.defaultTypingPitchRange.Min * 100,
				self.defaultTypingPitchRange.Max * 100
			) / 100
			blip:Play()
			blip.Ended:Connect(function()
				blip:Destroy()
			end)
		end

		task.wait(typeSpeed)
	end
end

return ShopDialogueService
