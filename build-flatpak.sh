#!/usr/bin/env bash

# Copyright (c) 2023 Álan Crístoffer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

set -e

# Install all workspace dependencies from offline cache (root installs all workspaces)
npm install --offline

# Build electron main process
pushd src/desktop || exit
npx tsc
popd || exit

# Build Angular app
pushd Lachesis || exit
npx ng build --configuration production
popd || exit

# Stage: prepare desktop/www with compiled files
mkdir -p desktop/www desktop/build

cp src/desktop/dist/index.js       desktop/www/index.js
cp src/desktop/package.json        desktop/www/package.json
cp src/desktop/package-lock.json   desktop/www/package-lock.json

# Install production-only deps for the electron main (offline)
npm install --omit=dev --offline --prefix desktop/www

cp -r Lachesis/dist/Lachesis desktop/www/Lachesis
cp -r src/icons/* desktop/build/

# Package the electron app as an unpacked directory (no installer needed for flatpak)
pushd desktop || exit
npx electron-builder --dir --linux --publish never
popd || exit
