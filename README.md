# Roblox Menu + Shop Camera Kit

Этот набор скриптов делает:
- плавный переход камеры в меню и в магазин;
- небольшой mouse-look эффект в меню/магазине;
- API для входа/выхода для всего меню и магазина;
- API для блокировки входа в меню и отдельно в магазин;
- систему случайных диалогов с поддержкой озвучки;
- fallback-звук в стиле «печатания» **только если у реплики нет аудио-озвучки**.

## Файлы
- `src/CameraTransitionController.lua`
- `src/ShopDialogueService.lua`
- `src/MenuFlowService.lua` (основной API для меню + магазина)
- `src/ExampleMenuShop.client.lua`
- `src/ShopService.lua` (опциональный старый API только для магазина)

## Быстрое подключение
1. Положи модули в `ReplicatedStorage.Modules`.
2. Положи `ExampleMenuShop.client.lua` в `StarterPlayerScripts`.
3. Создай в `workspace` якоря камеры:
   - `MenuCameraAnchor` (Part)
   - `ShopCameraAnchor` (Part)
   - `ReturnCameraAnchor` (Part, опционально)
4. Настрой GUI и имена кнопок из примера.

## API для всего меню + магазина
Через `MenuFlowService`:
- `EnterMenu(menuCameraPart)`
- `ExitMenu()`
- `EnterShop(shopCameraPart, dialogueLabel?)`
- `ExitShop(destinationCameraPart?)`
- `ForceExitAll(destinationCameraPart?)`
- `SetMenuLocked(isLocked, reason?)`
- `SetShopLocked(isLocked, reason?)`
- `IsMenuLocked()`
- `IsShopLocked()`

## API диалогов
Через `ShopDialogueService`:
- `GetRandomLine()`
- `PlayLine(text, outputLabel, typeSpeed?)`
- `SetVoiceForLine(text, soundId)`
- `SetLines(lines)`
- `AddLine(text, voiceSoundId?)`
