# Snake — mechanics sheet

Every number that shapes how this game plays, and where it came from.

**No original program was supplied.** `capture/README.md` in this workspace reads
"No target - Build from the request alone." and `reference/` is empty, so there is
nothing to measure or copy numbers from. Every value below is therefore an
**estimate** of the classic Snake arcade / Nokia Snake tradition, chosen to give
the familiar feel: a grid the snake never leaves, food that makes it longer and
faster, and a wall or its own body as the only way to lose.

The same numbers live in `app/mechanics.json`, and the code uses them as written.

## Board

| Value | Number | Source |
|---|---|---|
| Grid width | 20 cells | estimated — classic 20×20 arcade board |
| Grid height | 20 cells | estimated — classic 20×20 arcade board |
| Cell size | 20 px | estimated — 20 × 20 cells fill a 400 × 400 px board |
| Board origin (screen) | x 40, y 56 | estimated — 480 × 512 window, board centred, HUD above |
| Window size | 480 × 512 px | estimated — fits the board plus a score bar |
| Wall behaviour | solid, hitting it kills | estimated — classic Snake has no wrap-around |
| Food on board at once | 1 | estimated — classic Snake |

## Snake

| Value | Number | Source |
|---|---|---|
| Starting length | 3 segments | estimated — classic Snake starts short |
| Starting direction | right | estimated — classic Snake |
| Start position | row 10, column 9 (centre-left) | estimated |
| Movement | one cell per tick, no diagonal, no free movement | estimated — classic grid Snake |
| Turning | instant, queued until the next tick | estimated |
| Reversing into yourself | refused | estimated — classic Snake ignores a 180° turn |
| Growth per food | +1 segment | estimated |
| Collision with own body | kills, except the tail cell it is leaving | estimated — classic Snake lets the tail move on |
| Death by wall | kills | estimated |

## Speed

| Value | Number | Source |
|---|---|---|
| Speed at the start | 6 cells per second | estimated — slow enough to read the board |
| Speed at the top | 16 cells per second | estimated — fast but still fair |
| Speed gained | +1 cell per second for every 5 food eaten | estimated |
| Speed steps | 5, 10, 15, 20 food | estimated — steps of 5, each +1 cell/second |

## Scoring

| Value | Number | Source |
|---|---|---|
| Points per food | 10 | estimated — arcade Snake scores in tens |
| Score shown | top left, "SCORE n" | estimated |
| Best score shown | top right, "HI n" | estimated — arcade Snake kept a high score |
| Best score kept | for the life of the run | estimated |
| Game over panel | shows the final score, "PRESS SPACE TO PLAY AGAIN" | estimated |

## Controls

| Value | Number | Source |
|---|---|---|
| Steer up | Up arrow or W | estimated — arrow keys are the classic choice |
| Steer down | Down arrow or S | estimated |
| Steer left | Left arrow or A | estimated |
| Steer right | Right arrow or D | estimated |
| Restart after game over | Space, Enter or R | estimated |

## Look

| Value | Number | Source |
|---|---|---|
| Background | very dark blue-grey `#111719` | estimated — plain arcade dark |
| Board | slightly lighter `#171F24` | estimated |
| Grid lines | `#252F35` | estimated |
| Snake body | green `#5BC871` | estimated — classic green snake |
| Snake head | light green `#A3E5A4` | estimated |
| Food | red `#E6464C` | estimated — classic red apple |
| Text | pale green `#D0F1D0` | estimated |

## Not in this version

Nothing was dropped from the request. The request was for a simple snake game and
nothing else, so there is no extra mode, character or story to leave out.
