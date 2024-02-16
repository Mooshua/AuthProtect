# AuthProtect

Protects source-engine servers from people abusing authentication timeouts

## Requirements

AuthProtect runs on any sourcemod game.

- Basecomm (or a plugin with similar functionality)

## Features

When a player is not authenticated with steam, AuthProtect will:
- **Communication:** Players cannot speak or chat until they are authenticated.
  - Chat Communication (if no other plugin overrides chat behavior)
  - Voice Communication (*note:* requires basecomm or similar)
- **Movement:** Players cannot move, attack, or drop weapons until they are authenticated.
- **Sprays:** Players cannot place player sprays until they are authenticated.
  
AuthProtect additionally changes the steam-auth-error disconnect reason to be more verbose:

```
Disconnect: AUTH_FAIL
Steam did not authorize your session in time
This is usually caused by steam being down

You are not banned, and you are free to re-join.

[This server is protected by AuthProtect]
```