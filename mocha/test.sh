#!/bin/bash

ROOT="$(dirname $(readlink -f $0))"

npm install --save-dev mocha
npm init -y
ln -sf $ROOT/../build/bin/Release_Browser_wasm32/UnoSemuxLightCoreWasm.js ./
ln -sf $ROOT/../build/bin/Release_Browser_wasm32/UnoSemuxLightCoreWasm.wasm ./
npm test
