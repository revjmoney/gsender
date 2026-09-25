const { app } = require('electron');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const name = 'gSender RotatoCAM Preview';
const data = path.join(app.getPath('appData'), name);
fs.mkdirSync(data, { recursive: true });
app.setName(name);
app.setPath('userData', data);
app.setPath('sessionData', data);
os.homedir = () => data;
process.env.GSENDER_USER_DATA = data;
process.env.NODE_ENV = 'production';
delete process.env.ELECTRON_RENDERER_URL;
const { autoUpdater } = require('electron-updater');
autoUpdater.checkForUpdates = async () => null;
autoUpdater.downloadUpdate = async () => [];
autoUpdater.quitAndInstall = () => {};
if (process.env.ROTATOCAM_SMOKE_TEST === '1') {
    // Electron has already consumed the CI-only Chromium flags; do not pass
    // those flags to gSender's separate Commander argument parser.
    process.argv = [process.argv[0]];
    app.on('browser-window-created', (_event, window) => {
        window.webContents.on('did-finish-load', () => {
            if (window.webContents.getURL().startsWith('http://127.0.0.1:')) {
                console.log('ROTATOCAM_DESKTOP_READY');
                setTimeout(() => app.exit(0), 3000);
            }
        });
        window.webContents.on('did-fail-load', (_event, code, message) => {
            console.error('Desktop load failure:', code, message);
            app.exit(1);
        });
    });
}
require('./main.js');
