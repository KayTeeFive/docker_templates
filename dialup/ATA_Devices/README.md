# Configuring ATA Devices for Dial-Up Connections

## ATA structure

Client side:
- LynkSys PAP2T
  - Phone Line #1: 201
  - Phone Line #2: 202

Server hub:
- Cisco SPA122
    - Phone Line #1: 101
    - Phone Line #2: 102
- Cisco SPA112
    - Phone Line #1: 111
    - Phone Line #2: 112

---

## ATA Settings

### Cisco SPA122

#### Networking
- Networking Service:
  - Networking Service = BRIDGE
  - Monitor Network Drop on WAN Port Only: OFF
- Internet Settings:
  - Connection Type = DHCP
  - MTU = Auto
  - Host Name = SPA122-DialUP
  - Domain Name = lan
  - DNS Server Order = DHCP-Manual
  - Primary DNS = 8.8.8.8
  - Secondary DNS = 8.8.4.4

#### Voice / Regional
Miscellaneous:
- FXS Port Impedance = 600+2.16uF

#### Voice / Line 1
Network Settings:
- Network Jitter Level = **low**
- Jitter Buffer Adjustment = **no**

Call Feature Settings:
- Enable IP Dialing = **yes**

Proxy and Registration:
- Register = **no**
- Use OB Proxy In Dialog = **no**
- Make Call Without Reg = **yes**
- Ans Call Without Reg = **yes**

Subscriber Information:
- User ID = **101**
- Use Auth ID = no

Audio Configuration table

| Option                        | Value       | Option                      | Value            |
|-------------------------------|-------------|-----------------------------|------------------|
| Preferred Codec               | **G711u**   | Second Preferred Codec      | Unspecified      |
| Third Preferred Codec         | Unspecified | Use Pref Codec Only         | **yes**          |
| Use Remote Pref Codec         | no          | Codec Negotiation           | Default          |
| G729a Enable                  | **no**      | Silence Supp Enable         | no               |
| G726-32 Enable                | **no**      | Silence Threshold           | medium           |
| FAX V21 Detect Enable         | **no**      | Echo Canc Enable            | **no**           |    
| FAX CNG Detect Enable         | **no**      | FAX Passthru Codec          | G711u            | 
| FAX Codec Symmetric           | **no**      | DTMF Process INFO           | yes              |
| FAX Passthru Method           | **None**    | DTMF Process AVT            | yes              |
| FAX Process NSE               | **no**      | DTMF Tx Method              | Auto             |
| FAX Disable ECAN              | no          | DTMF Tx Mode                | Strict           |
| DTMF Tx Strict Hold Off Time  | 70          | FAX Enable T38              | no               |
| Hook Flash Tx Method          | None        | FAX T38 Redundancy          | 1                |
| FAX T38 ECM Enable            | **no**      | FAX Tone Detect Mode        | caller or callee |
| Symmetric RTP                 | no          | FAX T38 Return to Voice     | no               |
| Modem Line                    | **yes**     | RTP to Proxy in Remote Hold | no               |

Dial Plan:
- Dial Plan: `(<101:101>S0<:@192.168.8.10:5060> | <102:102>S0<:@192.168.8.10:5061> | <111:111>S0<:@192.168.8.11:5060> | <112:112>S0<:@192.168.8.11:5061> | <201:201>S0<:@192.168.8.20:5060> | <202:202>S0<:@192.168.8.20:5061> | <211:211>S0<:@192.168.8.21:5060> | <212:212>S0<:@192.168.8.21:5061>)`

#### Voice / Line 2
Almost all settings for `Line 2` are identical to `Voice / Line 1` except next settings below.

Subscriber Information:
- User ID = **102**
- Use Auth ID = no

### Cisco SPA112

#### Networking
- Internet Settings:
  - Connection Type = DHCP
  - MTU = Auto
  - Host Name = SPA112-DialUP
  - Domain Name = lan
  - DNS Server Order = DHCP-Manual
  - Primary DNS = 8.8.8.8
  - Secondary DNS = 8.8.4.4

#### Voice

Almost all settings for `Voice` are identical to `SPA122` except next settings below.

#### Voice / Line 1
Subscriber Information:
- User ID = **111**
- Use Auth ID = no

#### Voice / Line 2
Subscriber Information:
- User ID = **112**
- Use Auth ID = no


### LynkSys PAP2T
#### Networking
- Internet Settings:
  - DHCP = yes
  - Host Name = LinkSysPAP2T-20
  - Domain Name = lan
  - DNS Server Order = Manual
  - Primary DNS = 8.8.8.8
  - Secondary DNS = 8.8.4.4

#### Voice / Regional
Miscellaneous:
- FXS Port Impedance = 600+2.16uF

#### Voice / Line 1
Network Settings:
- Network Jitter Level = **low**
- Jitter Buffer Adjustment = **up and down** -> **!!! maybe missconfiguration, need test with  `disable`**

Proxy and Registration:
- Register = **no**
- Use OB Proxy In Dialog = **no**
- Make Call Without Reg = **yes**
- Ans Call Without Reg = **yes**

Subscriber Information:
- User ID = **201**
- Use Auth ID = no

Audio Configuration table

| Option              | Value     | Option                 | Value    |
|---------------------|-----------|------------------------|----------|
| Preferred Codec     | **G711u** | Silence Supp Enable    | no       |
| Use Pref Codec Only | **yes**   | Silence Threshold      | medium   |
| G729a Enable        | **no**    | Echo Canc Enable       | **no**   |
| G723 Enable         | **no**    | Echo Canc Adapt Enable | **no**   |
| G726-16 Enable      | **no**    | Echo Supp Enable       | **no**   |
| G726-24 Enable      | **no**    | FAX CED Detect Enable  | **no**   |
| G726-32 Enable      | **no**    | FAX CNG Detect Enable  | **no**   |
| G726-40 Enable      | **no**    | FAX Passthru Codec     | G711u    |
| DTMF Process INFO   | yes       | FAX Codec Symmetric    | **no**   |
| DTMF Process AVT    | yes       | FAX Passthru Method    | **None** |
| DTMF Tx Method      | Auto      | DTMF Tx Mode           | Strict   |
| FAX Process NSE     | **no**    | Hook Flash Tx Method   | None     |
| FAX Disable ECAN    | **no**    | Release Unused Codec   | yes      |

> `Modem Line` option is absent on Linksys PAP2T

Dial Plan:
- Dial Plan: `(<101:101>S0<:@192.168.8.10:5060> | <102:102>S0<:@192.168.8.10:5061> | <111:111>S0<:@192.168.8.11:5060> | <112:112>S0<:@192.168.8.11:5061> | <201:201>S0<:@192.168.8.20:5060> | <202:202>S0<:@192.168.8.20:5061> | <211:211>S0<:@192.168.8.21:5060> | <212:212>S0<:@192.168.8.21:5061>)`
- Enable IP Dialing: **yes**

