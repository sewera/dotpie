#!/bin/bash

muted() {
    pacmd list-sources | grep -A 10 'alsa_input.pci-0000_00_1f.3.analog-stereo' | grep -q 'muted: yes'; echo $?
}

unmuted() {
    pacmd list-sources | grep -A 10 'alsa_input.pci-0000_00_1f.3.analog-stereo' | grep -q 'muted: no'; echo $?
}

if [[ $(muted) -eq 0 ]]; then
    echo -e ""
    exit
fi

if [[ $(unmuted) -eq 0 ]]; then
    echo -e ""
    exit
fi

echo -e "%{F#494949}"
