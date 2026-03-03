# Emote Menu (Roblox)

## Что изменилось
Теперь система работает так:
- UI открывается по **B**, меню выезжает снизу по центру.
- Клиент берет список "одетых" эмоций с сервера (до 4).
- Список сохраняется **для каждого игрока отдельно** через DataStore.
- Данные самой эмоции берутся из `ReplicatedStorage/Emotes/<EmoteName>`:
  - `Animation` (обязательно)
  - `Sound` (опционально)
  - `Props` (опционально, папка с объектами для клонирования на персонажа)
  - `DisplayName` (опционально, StringValue для текста кнопки)

## Куда что ставить

### 1) Клиент
- `roblox/EmoteController.client.lua` -> `StarterPlayer > StarterPlayerScripts`

### 2) Сервер
- `roblox/PlayerEquippedEmotes.module.lua` -> `ServerScriptService > PlayerEquippedEmotes` (ModuleScript)
- `roblox/EmoteService.server.lua` -> `ServerScriptService > EmoteService.server.lua` (Script)

### 3) Контент эмоций
Создай в `ReplicatedStorage` папку `Emotes`.
Внутри по папке на эмоцию, например:
- `ReplicatedStorage/Emotes/Wave/Animation`
- `ReplicatedStorage/Emotes/Wave/Sound`
- `ReplicatedStorage/Emotes/Wave/Props/...`
- `ReplicatedStorage/Emotes/Wave/DisplayName`

Имена папок эмоций (например `Wave`, `Dance`) — это ID эмоций для списка экипировки.

## Как менять "одетые" эмоции из других скриптов

Из серверного скрипта:

```lua
local PlayerEquippedEmotes = require(game.ServerScriptService.PlayerEquippedEmotes)

local player = -- игрок
PlayerEquippedEmotes.SetEquipped(player, {"Wave", "Dance", "Laugh"})
PlayerEquippedEmotes.NotifyChanged(player) -- сразу обновит клиентское меню
```

Можно также отправлять с клиента на сервер через:
`ReplicatedStorage.EmoteRemotes.SetEquippedEmotes:FireServer({...})`.

## Важно
- Лимит меню: максимум **4 эмоции**.
- У каждого игрока свой сохраненный список.
- Если у эмоции нет `Animation`, она не проиграется.
