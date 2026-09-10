#!/usr/bin/env python3
"""
map_dashboard.py
----------------
Live web map of nearby RF/aerial emitters, sourced from Kismet's REST API
(receive/detect data only — this script has no transmit capability).

Requires Kismet already running with its REST API enabled (default:
http://localhost:2501). Set KISMET_USER / KISMET_PASS env vars if your
Kismet install requires auth (it does by default — check
~/.kismet/kismet_httpd.conf for the generated credentials).
