<div align="center">
<h1>Dice Admin</h1>

By [Mullet Mafia Dev](https://www.roblox.com/groups/5018486/Mullet-Mafia-Dev#!/about)
</div>

Dice Admin is an admin system which interlocks with other Dice modules such as Dice Output, Dice Assign Sizes, and Dice DataStore. There's also an admin console that appears that you can view by pressing F8 in game. This is only available to the users who have Admin access, which can be set in the module. When using the F8 console, you do **not** need the prefix, though you can use it if you want (not recommended).

## Configuration

* Default Admins = `{46522586,38162374,5520567,22119678}`
* Console Keybind = `F8`
* Prefix = `-`

## Commands

```
m [text]
```

Shouts a message for 10 seconds with the `text` argument.

```
h [text]
```

Shouts a hint for 10 seconds with the `text` argument.

```
tip [text]
```

A permanent hint with the `text` argument.

```
re [plr]
```

Reloads a player's character in the same position with the `plr` argument.

```
spawn [plr]
```

Spawns a player back at the spawn with the `plr` argument.

```
heal [plr]
```

Heal a player's character back to full health (MaxHealth) with the `plr` argument.

```
kill [plr]
```

Kill a player's character with the `plr` argument.

```
to [plr]
```

Teleport you to the player listed in the `plr` argument.

```
bring [plr]
```

Teleport the player listed in the `plr` argument to you.

```
health [plr] [number]
```

Set a player's characters health & max health to the given `number` argument with the `plr` argument.

```
speed [plr] [nmumber]
```

Set a player's characters walk speed to the given `number` argument ith the `plr` argument.

```
jump [plr] [number]
```

Set a player's characters jump height to the given `number` argument ith the `plr` argument.

```
ban [plr/userId]
```

Ban a player with either the player or user ID with the `plr/userId` argument.

```
unban [userId]
```

Unban a player with the given user ID in the `userId` argument.

## Console

```
fps [number]
```

Run a series of tests with the given `number` argument for accurate Frames Per Second, default is 4.

```
ping [number]
```

Run a series of tests with the given `number` argument for accurate ping, default is 4.

```
fov [number]
```

Change your Field Of View with the given `number` argument, default is 70.

```
noclip [on/off]
```

No Clip fly your character, leaving the `on/off` argument blank defaults to `on`. 

## DataStore

```
load [plr/userId]
```

Load a player's DataStore file with the given `plr/userId` argument.

```
save [plr/userId]
```

Save a player's DataStore file with the given `plr/userId` argument.

```
clear [plr/userId]
```

Clear a player's DataStore file with the given `plr/userId` argument.

```
rollback [plr/userId]
```

Rollback a player's DataStore file with the given `plr/userId` argument.

```
read [plr/userId] [stat]
```

Read a player's DataStore file with a specific `stat` argument & with a given `plr/userId` argument.

```
change [plr/userId] [stat] [value]
```

Set a player's DataStore file with a specific `stat` argument to a given `value` argument & with a given `plr/userId` argument.

```
increment [plr/userId] [stat] [number]
```

Increment a player's DataStore file with a specific `stat` argument to a given `number` argument & with a given `plr/userId` argument.
