# anti-drone-tools
anti drone tools


dronewatch — passive RF / drone-detection toolkit
A bash installer + Zenity GUI menu for a receive-only situational-awareness
stack: see nearby aerial RF emitters (including many consumer drones) on a
live map, inspect spectrum, trace frequency-hopping patterns, and decode
Remote ID broadcasts.
What's included
Tool
Purpose
Mode
Kismet
WiFi/RF device detection
Monitor mode, no injection
GQRX
SDR spectrum/waterfall viewer
Receive only
GNU Radio Companion
Custom receive flowgraphs
Receive only
tools/fhss_trace.grc
Frequency-hop trace flowgraph
Receive only (SDR source, no sink/TX)
Remote ID receiver
Decodes drone Remote ID broadcasts (FAA/EASA-mandated since 2023/2024)
Receive only
tshark
Packet capture to file
Passive capture
ADS-B decoder
Manned aircraft context
Receive only
tools/map_dashboard.py
Live web map fed by Kismet's REST API
Read-only API consumer
What's deliberately NOT included, and why
The original tool list mixed detection tools with an attack/jamming
toolchain: mdk3, hostapd-mana/Mana rogue-AP, Bettercap/Berate ap for
MITM, aircrack-ng's injection modes, and a GNU Radio transmit chain
(noise source → RF power amp → HackRF/USRP sink) intended to jam or
"scramble" a drone's control/video link.
That's excluded because:
Transmitting to disrupt another device's radio link is illegal in most
jurisdictions (in the US, 47 U.S.C. § 333 prohibits willful or malicious
interference with licensed radio communications — this covers most drone
jamming regardless of intent).
It can knock a drone out of controlled flight, which is a safety hazard
to people/property under the drone, not just a legal issue for the
operator of the jammer.
No amount of script restructuring changes what the transmit chain does —
omitting it isn't a policy technicality, it's the actual boundary.
If you have a specific, lawful need to interdict a drone (e.g. you're a
licensed operator under an FAA/FCC counter-UAS authorization, or law
enforcement/critical-infrastructure context with legal authority), that's a
regulated space with its own certified hardware vendors — it's not
something to bootstrap from a hobbyist SDR stack, and I'd point you to that
regulatory path rather than building it here.
Setup
Bash
Or install now, launch the menu later:
Bash
Notes
Kismet needs your WiFi adapter in monitor mode and capable of it —
not all adapters support monitor mode.
Remote ID: as of 2023 (US) / 2024 (EU), most new consumer drones
broadcast Remote ID (essentially a license-plate broadcast) — this is
by far the most reliable and fully legal way to identify a nearby drone
and often its operator's approximate location. The cloned
opendroneid/receiver-linux repo decodes these broadcasts.
map_dashboard.py reads Kismet's existing REST API — it doesn't do
any of its own RF work. Start Kismet first, then the dashboard.
The .grc flowgraph is a starting template, not a finished product —
open it in GNU Radio Companion, point sdr_source at your actual
hardware args, and adjust center_freq to the band you're interested in
(2.4/5.8 GHz covers most consumer drone control/video links).