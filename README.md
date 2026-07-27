# Z-City
Z-City is a GMod addon which modifies character damage and controls. Z-City also comes with its own weapon base and a gamemode

https://github.com/uzelezz123/8bit_zcity - 8bit module (compiled version is in lua/bin)

Optional Discord RPC module for clients:
1. https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer/releases/tag/2023.07.20
2. https://github.com/fluffy-servers/gmod-discord-rpc/releases/tag/1.2.1

## VRMod: Ultimate (Quest/Touch)

Z-City forwards **[G]VRMod: Ultimate**'s default reload action to Z-City weapons. Touch **both thumb rests** to reload, as configured by VRMod's default Oculus Touch profile. Shooting remains on VRMod's normal **right trigger** binding.

Set `zcity_vrmod_thumbrest_reload 0` to use VRMod's own reload-command handler instead. If SteamVR has a custom controller binding selected, map its reload action to `boolean_reload`.

An isolated visual hand-follow model is available for testing with `zcity_vr_hand_weapon 1`. It is disabled by default so it cannot affect shooting or cause a regression; use `zcity_vr_hand_weapon 0` to turn it off immediately.

The current version in the repository is 1.4.0

## The numbers in the version number indicate:
A.Bcc -> 1.000
- A -> Global updates
- B -> New mechanics, gameplay changes
- c -> Fixes and other small things

## Support us
**Donation links:**
- [Yoomoney](https://yoomoney.ru/fundraise/17GFEQH326Q.250101) 
- [Boosty](https://boosty.to/sadsalat/donate)

**Crypto**
- USDT(TRC20): TYgpaZgHQr6qEgemhHzVvV7AQESiyhHpZD
- BTC(BTC): bc1qa8pk9ag6xa5yav2mvlxkra8xk25lg3htgfqh5w
- ETH(ERC20)* 0x72AdCCcCEB4E323C64bCF0955A779DD9298E9483
