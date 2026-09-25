#!/bin/bash
set -euo pipefail
[[ $(uname -m) == aarch64 ]]
apt-get update -qq
apt-get install -y --no-install-recommends libudev-dev ruby ruby-dev xvfb xauth libgtk-3-0 libnss3 libasound2 libgbm1 libxss1 libatk-bridge2.0-0
gem install fpm --no-document
yarn install --ignore-scripts --non-interactive
node scripts/package-sync.js
mkdir -p dist/gsender
cp src/package.json dist/gsender/package.json
node esbuild.config.js --production --target=all
yarn --cwd src/app build:client
yarn build-dev-css
mkdir -p dist/gsender/app/src
cp src/app/src/application.css dist/gsender/app/src/
cp -a src/app/favicon.ico src/app/images src/app/assets dist/gsender/app/
yarn jest --runInBand --runTestsByPath src/app/src/workers/__tests__/Visualize.rotary.test.ts src/app/src/features/Visualizer/__tests__/GCodeVisualizer.rotary.test.js
yarn --cwd dist/gsender install --production --ignore-scripts --non-interactive
node -e "require('./dist/gsender/node_modules/serialport').SerialPort.list().then(p => console.log('ARM64 serial binding loaded; ports:',p.length))"
cp scripts/rotatocam-pi/{desktop.cjs,README.md} dist/gsender/
cp LICENSE dist/gsender/LICENSE.gsender
printf 'Source: %s\nNode: %s\nPlatform: %s\n' "$GITHUB_SHA" "$(node --version)" "$(uname -m)" > dist/gsender/BUILD.txt
yarn electron-builder --config scripts/rotatocam-pi/desktop.json --linux deb --arm64 --publish never
mkdir -p pi-release
cp pi-desktop/*.deb pi-release/
(cd pi-release && sha256sum *.deb > SHA256SUMS)
cp scripts/rotatocam-pi/README.md pi-release/
dpkg-deb --info pi-release/*.deb
# Root in the disposable CI container needs --no-sandbox; installed apps do not.
export ROTATOCAM_SMOKE_TEST=1
timeout 45s xvfb-run -a pi-desktop/linux-arm64-unpacked/gsender-rotatocam-preview --no-sandbox --disable-gpu > pi-desktop-smoke.log 2>&1 || { cat pi-desktop-smoke.log; exit 1; }
grep -q 'ROTATOCAM_DESKTOP_READY' pi-desktop-smoke.log
cat pi-desktop-smoke.log