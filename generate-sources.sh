#!/usr/bin/env bash

git clone https://github.com/acristoffers/Lachesis
git clone https://github.com/flatpak/flatpak-builder-tools

pushd Lachesis || exit
git checkout "$(yq -r '.modules[0].sources[1].commit' ../me.acristoffers.Lachesis.yml)"
popd || exit

pushd flatpak-builder-tools/node || exit

poetry install

poetry run flatpak-node-generator -o out1.json npm ../../Lachesis/package-lock.json
poetry run flatpak-node-generator -o out2.json npm ../../Lachesis/Lachesis/package-lock.json
poetry run flatpak-node-generator -o out3.json npm ../../Lachesis/desktop/package-lock.json
poetry run flatpak-node-generator -o out4.json npm ../../Lachesis/src/desktop/package-lock.json

jq -sc "flatten | unique | sort_by(.type)" out1.json out2.json out3.json out4.json > ../../generated-sources.json

popd || exit

rm -rf Lachesis flatpak-builder-tools tmp{,2}.json
