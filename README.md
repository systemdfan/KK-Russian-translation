# KK-Russian-translation
Russian Koikatsu translation project. Репозиторий содержит файлы и инструменты перевода

## Зачем
[Англоязычный репозиторий](https://github.com/IllusionMods/KoikatsuTranslation) не содержит информации о спикерах в диалогах, что усложняет качественный машинный перевод.

### Чего хотим добиться?
Нв выходе планируется получить файлы перевода для XUnity.AutoTranslator, повторяющие по структуре [англоязычный репозиторий](https://github.com/IllusionMods/KoikatsuTranslation)

## Что внутри
- `tools/` - инструменты/скрипты для работы с файлами репозитория и игры
    - `conf/` - конфиги скриптов  
	
- `sources/` - входные файлы для перевода (которые идут в переводчик)
    - `mappings_en/` - варианты входных файлов с англоязычными названиями
    - `mappings_jp/` - варианты входных файлов с японскими названиями
	
- `pretranslations/` - всё что связанно с этапом машинного первода 
    - `artefacts/` - артефакты перевода
        - `mappings_en/` - артефакты с английским маппингом
        - `mappings_jp/` - артефакты с японским вариантом
    - `conf/` - конфиги, глосарии, всё что нужно для машинного переводчика
	
- `translation/` - итоговые файлы перевода XUnity.AutoTranslator, повторяющие структуру англоязычного репозитория.

## todo:
- [ ] Подготовить входные файлы перевода из других директорий
- [ ] Перевести файлы

## Прогресс

*прогресса не существует дёмдальш*

| Директория | Этап | Описание |
| ---- | ---- | ---- |
| `action/list/event` | - | Event titles |
| `adv` | загружено | main game dialogs |
| `communication` | загружено | main game dialogs |
| `custom/customscenelist` | - | Maker Pose Text |
| `etcetra/list/nickname` | - |Call Names |
| `h/list/*/animationinfo_*` | - | Positions (game versions) |
| `h/list/*/hpointtoggle` | - | Positions (game versions) |
| `h/list/*/personality_voice*` | - | H Subtitles |
| `list/characustom` | - | Maker stuff |
| `list/characustom/*/cha_sample_voice_*` | - | Personality names |
| `list/random_name` | - | Random names |
| `map/list/mapinfo` | - | Map names |
| `studio/info` | - | Studio stuff |

![Yar har fiddle-dee-dee!](mascot.webp)

__*Только полный и качественный перевод!*__
