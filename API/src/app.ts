import { startAPI } from './api/api';
import { startFolderWatcher } from './watcher/folder_watcher';
import { startJsonWatcher } from './watcher/json_watcher';
import { startSpecWatcher } from './watcher/spec_watcher';
import { startVpnWatcher } from './watcher/vpn_watcher';

/////////////////////////////////////////////////////////////////////////////////
// Main de l'api
startAPI();
startFolderWatcher();
startJsonWatcher();
startSpecWatcher();
startVpnWatcher();