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

# Install dependencies
mkdir -p desktop/www desktop/build
cp -r src/desktop/* desktop/www/

npm install --offline
npm install --offline --prefix Lachesis
npm install --offline --prefix desktop
npm install --offline --prefix desktop/www

pushd desktop/www || exit
npx tsc
rm -r node_modules index.ts tsconfig.json
npm install --omit dev --offline
popd || exit

pushd Lachesis || exit
npx ng build --configuration production --optimization
popd || exit

mv Lachesis/dist/Lachesis desktop/www/Lachesis
cp -r src/icons/* desktop/build/

pushd desktop || exit
npx electron-builder --dir --linux --publish never
popd || exit
