import initWasm from '@vlcn.io/crsqlite-wasm';
import wasmUrl from '@vlcn.io/crsqlite-wasm/crsqlite.wasm?url';

const sqlite = await initWasm(wasmUrl);

const db = await sqlite.open('scored.db');

// https://www.youtube.com/watch?v=T1ES9x8DKR4
// https://vlcn.io/docs
