# RexshackGaming
- discord : https://discord.gg/s5uSk56B65
- youtube : https://www.youtube.com/channel/UCikEgGfXO-HCPxV5rYHEVbA
- github : https://github.com/Rexshack-RedM

# Framework QRCore RedM Edition
- https://github.com/QRCore-RedM-Re

# Dependencies
- qr-core

# Installation
- ensure the above dependancies are installed and started
- add rsg-properties to your resources folder
- import the "rsg-properties.sql" to your database
- add the following to qr-core\server\player.lua around line 473 (metadata)
```lua
PlayerData.metadata['house'] = PlayerData.metadata['house'] or 'none'
```
- add the following to your "server.cfg" : ensure rsg-properties

# Note
- to unlock doors use keybind [U]