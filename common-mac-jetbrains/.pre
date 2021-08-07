cdir=$1
[[ -z "$cdir" ]] && echo "Usage: $0 \"\$CONFDIR\" (after sourcing .conf/* file, use quotes)" && exit 1
products="DataGrip2021.2 IntelliJIdea2021.2 GoLand2021.2"

for prod in $products; do
  echo Removing ${cdir}/JetBrains/${prod}/keymaps/jazz_mac_with_ideavim.xml
  rm -f "${cdir}/JetBrains/${prod}/keymaps/jazz_mac_with_ideavim.xml"
  echo Removing ${cdir}/JetBrains/${prod}/options/mac/keymap.xml
  rm -f "${cdir}/JetBrains/${prod}/options/mac/keymap.xml"
done
