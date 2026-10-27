# SortieAnnouncer

Windower 4 addon for FFXI. Calls the next Sortie boss in party chat based on the route your group runs, with the strategy block for each boss.

One macro is all you need. Press it after each boss and the next one gets posted.

**Authors:** Soulfly, Meechie
**Version:** 0.2

## Install

1. Create `Windower/addons/SortieAnnouncer/`
2. Put `SortieAnnouncer.lua` in that folder
3. In game: `//lua load sortieannouncer`

To load it every time, add `lua load sortieannouncer` to `Windower/scripts/init.txt`.

The first load creates a `messages` folder with the default boss messages, and a `data` folder for your settings.

## Quick Start

1. Pick a route: `//sa preset` to list them, then `//sa preset 1` (DHABCGEF is the default).
2. Make an in-game macro with this line: `/console sa next`
3. At the start of the run, press the macro. It posts the route and the first boss.
4. Each time a boss dies, press the macro. It posts the next boss.

## Commands

| Command | What it does |
| --- | --- |
| `//sa next` | Current boss is dead, post the next one. First press posts the route and the first boss |
| `//sa start` | Post the route and the first boss |
| `//sa now` | Repost the current boss |
| `//sa back` | Go back one boss and repost it |
| `//sa done <bosses>` | Mark bosses killed by hand (ex: `//sa done a`) |
| `//sa reset` | Clear progress and times |
| `//sa status` | Show mode, call style, HUD, route, progress and current boss |
| `//sa macro` | Only your macro posts (default) |
| `//sa auto` | Post the next boss automatically on each kill |
| `//sa full` | Post the full message block for each boss (default) |
| `//sa compact` | Post one line per boss |
| `//sa hud` | Show or hide the on-screen box |
| `//sa times` | Show boss times in your log |
| `//sa times party` | Post boss times to party |
| `//sa preset` | List presets |
| `//sa preset <#\|name>` | Use a preset (ex: `//sa preset 4`) |
| `//sa route` | List your saved routes |
| `//sa route add <name> <order>` | Save a route (ex: `//sa route add mine dhabcgef`) |
| `//sa route use <name>` | Set the active route |
| `//sa route del <name>` | Delete a saved route |
| `//sa a` through `//sa h`, `//sa aminon` | Post that boss's full message |
| `//sa <message>` | Post any file in the messages folder (ex: `//sa reminders`) |
| `//sa messages` | List message files |
| `//sa preview <message>` | Show a message in your log only |
| `//sa reload` | Reload message files after editing |
| `//sa stop` | Clear party lines waiting to be posted |
| `//sa debug` | Show kill and zone detection output |
| `//sa help` | Show the command list in game |

`//sra` and `//sortieannouncer` work in place of `//sa`. In a macro, use `/console sa` instead of `//sa`.

## Modes

Mode is saved per character. `//sa status` shows which one you're in.

**Macro (default).** Nothing posts on its own. `/console sa next` does everything. When a kill is detected, it only puts a reminder in your log and never moves your place in the route, so the macro stays in control.

**Auto.** When the current boss dies, it waits 3 seconds and posts the next one. For a split, it waits until every boss in the split is dead.

Safety checks:
- A macro press within 5 seconds of the last one is ignored, so a double tap won't skip a boss. Use `//sa back` if you did mean to skip.
- In auto mode, a macro press within 10 seconds of an auto post is ignored.
- If the group kills a boss out of order in auto mode, it picks up the route from that boss.

## Routes

### Presets

| # | Route | Order | Note |
| --- | --- | --- | --- |
| 1 | dhabcgef | D > H > A > B > C > G > E > F | Default |
| 2 | dhcbagef | D > H > C > B > A > G > E > F | |
| 3 | dhabcgfe | D > H > A > B > C > G > F > E | |
| 4 | dabcgefh | D > A > B > C > G > E > F > H | BG-Wiki default, Soul Voice saved for H |
| 5 | hdcbaefg | H > D > C > B > A > E > F > G | H access farmed on the last run |
| 6 | dhcbaefg | D > H > C > B > A > E > F > G | Magic burst group, ordered by skillchain |
| 7 | abcdefgh | A > B > C > D > E > F > G > H | All 8 in letter order |
| 8 | ace | A > C > E | Intermediate |
| 9 | ac | A > C | Beginner |

Presets can't be deleted. To add or change one, edit the `Presets` section near the top of `SortieAnnouncer.lua`.

### Your Own Routes

Write the order the way you'd call it:

```
//sa route add mine dhabcgef
```

- Letters run in order. Spaces and dashes are ignored, so `dh - abc gef` saves the same route.
- Use `+` for a split, where groups kill bosses at the same time: `//sa route add split a+b+c+d efgh aminon`
- Route names start with a letter and use only letters, numbers and `_`.
- Saved routes are per character.

## Message Files

Every announcement comes from a text file in `Windower/addons/SortieAnnouncer/messages/`. Each line in a file is one party chat line.

| File | Used for |
| --- | --- |
| `aboss.txt` to `hboss.txt` | Boss A to H calls |
| `aminonboss.txt` | Aminon call |
| `reminders.txt` | `//sa reminders` |
| `geo7boss.txt` | `//sa geo7boss` |

- Edit a file in Notepad, save it as UTF-8 so the symbols survive, then run `//sa reload`.
- Blank lines and empty `| 【  】` placeholders are skipped.
- Add any new `.txt` file and it becomes a command. `pldsplit.txt` is posted with `//sa pldsplit`.
- A file named after a route posts automatically when that route starts. `dhabcgef.txt` or `mine.txt` is a good place for a group's split plan.
- A file like `aboss_short.txt` replaces boss A's line in compact mode.
- Delete a default file and run `//sa reload` to get the original back.
- Use `//sa preview <name>` to check an edit before posting it.

## Compact Mode

`//sa compact` turns each boss call into one line, built from the first two lines of its message file:

```
★ A ★ Boss: Ghadjot  【 AVOID : Reverberation / Distortion / Darkness 】
```

If `<boss>_short.txt` exists, that file is used instead. Calling a boss directly (`//sa a`) always posts the full block. `//sa full` switches back.

## HUD

```
Sortie Announcer  [macro]
Route  dhabcgef
D H A B C G E F
Now    H  Aita  4:05
Next   A  Ghadjot
Run    7:17
```

- The current boss shows in green and finished bosses in gray.
- The boss timer and run timer count up live.
- Drag the box to move it. The position is saved per character.
- `//sa hud` shows or hides it.

## Boss Times

Each boss is timed from when it's called until it's marked done, either by your macro press (macro mode) or by the kill (auto mode). The run timer starts with the first boss.

When the route finishes, it posts to party:

```
Times: D 3:12 | H 4:05 | A 1:40 | B 1:40
C 1:40 | G 1:40 | E 1:40 | F 3:20 | Total 22:47
```

`//sa times` shows the times in your log mid-run, and `//sa times party` posts them.

## Auto Reset

Zoning into Sortie from outside clears progress and times, so last run never carries over. Moving between floors inside Sortie doesn't reset anything.

It checks for zone names that start with "Outer Ra'Kaznar [U". Turn on `//sa debug` to see the zone name when you zone.

## Kill Detection

Kills are picked up from the "defeats" and "falls to the ground" messages and from the game's defeat packet. Detected kills drive auto mode and boss times. In macro mode they only show a reminder in your log.

| Sector | Boss |
| --- | --- |
| A | Ghadjot |
| B | Leshonn |
| C | Skmora |
| D | Degei |
| E | Dhartok |
| F | Gartell |
| G | Triboulex |
| H | Aita |
| Final | Aminon |

## Multiboxing and Parties

Settings are saved per character. Only one person in the party should be posting. If two people run it with auto on, both will post.

## Settings

Saved per character in `Windower/addons/SortieAnnouncer/data/settings.xml`:

- `auto`: auto mode on or off (default off)
- `compact`: compact calls on or off (default off)
- `active`: active route (default dhabcgef)
- `routes`: your saved routes
- `hud_on`: HUD shown or hidden (default shown)
- `hud`: HUD position, font and colors

Set at the top of `SortieAnnouncer.lua`:

- `line_delay`: seconds between party lines (default 1.5)
- `auto_delay`: seconds after a kill before posting the next boss in auto mode (default 3)

## Troubleshooting

**Nothing posts after a kill.** Run `//sa status`. In macro mode, nothing posts until you press the macro.

**A kill isn't detected.** Turn on `//sa debug` and check that the boss name in the "defeats" line matches the table above. Use `//sa done <letter>` to mark it by hand.

**Progress didn't reset when entering Sortie.** Turn on `//sa debug` and zone in. Check the zone name it shows.

**Symbols look garbled after editing a message.** Save the file as UTF-8 and run `//sa reload`.

**Posts are piling up.** Run `//sa stop` to clear the queue.

## Credits

Boss messages and the original party chat format by Soulfly. Routes, modes, message files, HUD and timers by Meechie.

## Sources

Preset routes are from [BG-Wiki: Sortie Strategies](https://www.bg-wiki.com/ffxi/Sortie_Strategies) and [FFXIAH: Open spot for Sortie (8-Boss, Magic)](https://www.ffxiah.com/forum/topic/58171/open-spot-for-sortie-8-boss-magic-830pm-est/2/).
