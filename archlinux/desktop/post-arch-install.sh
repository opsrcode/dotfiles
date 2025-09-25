#!/bin/env bash

set -euo pipefail

systemctl enable systemd-networkd.service
systemctl start systemd-networkd.service

ufw default deny incoming
systemctl enable ufw.service
ufw enable

mkinitcpio -P
