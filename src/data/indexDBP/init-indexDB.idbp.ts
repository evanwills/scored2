// import { EAppStates } from "../redux/app-state";
// import { TScoredStore } from "../types/game-data";
// import { TAppState } from '../../types/app-state.types';

import { initGameTypesData, initGameTypeStore } from "./game-type-store";
import { initPlayerStore } from "./player-store.idbp";
import initPlayersData from "./init-players-data";
import initTeamsData from "./init-teams-data";
import { openDB, deleteDB, IDBPDatabase } from "idb";
import { initCustomGamesStore } from "./custom-game-store";
import { initGamedataStore, initGamedataGametypeStore } from "./past-game-store";

let scoredDB : IDBPDatabase<unknown> | null = null;

// ------------------------------------------------------------------
// START: individual object store initialisers

const _upgradeDB = (db : IDBPDatabase, oldVersion, newVersion, transaction, event) => {
  db.createObjectStore('appState');
  db.createObjectStore('currentGame');
  initCustomGamesStore(db);
  initGamedataStore(db);
  initGamedataGametypeStore(db);
}


export const initPlayerTeamStore = (db: IDBDatabase) : IDBObjectStore => {
  // const output = db.createObjectStore('playerTeam');
  // const output = db.createObjectStore('playerTeam', { keyPath: ['playerID, teamID'] });
  const output = db.createObjectStore('playerTeam', { keyPath: ['playerID', 'teamID'] });
  output.createIndex('playerID', 'playerID', { unique: false });
  output.createIndex('teamID', 'teamID', { unique: false });
  output.createIndex('position', 'position', { unique: false });
  output.createIndex('playerIdTeamId', ['playerID', 'teamID'], { unique: true });

  return output;
};

export const initPlayerPastgameStore = (db: IDBDatabase) : IDBObjectStore => {
  const output = db.createObjectStore('playerPastgame', { keyPath: ['playerID', 'gameID'] });
  output.createIndex('playerID', 'playerID', { unique: false });
  output.createIndex('gameID', 'gameID', { unique: false });
  output.createIndex('type', 'type', { unique: false });
  output.createIndex('rank', 'rank', { unique: false });
  output.createIndex('started', 'started', { unique: false });
  output.createIndex('playerIdGameId', ['playerID', 'gameID'], { unique: true });

  return output;
};

export const initTeamPastgameStore = (db: IDBDatabase) : IDBObjectStore => {
  const output = db.createObjectStore('teamPastgame', { keyPath: ['teamID', 'gameID'] });
  output.createIndex('teamID', 'teamID', { unique: false });
  output.createIndex('gameID', 'gameID', { unique: false });
  output.createIndex('type', 'type', { unique: false });
  output.createIndex('rank', 'rank', { unique: false });
  output.createIndex('started', 'started', { unique: false });
  output.createIndex('teamIdGameId', ['teamID', 'gameID'], { unique: true });

  return output;
};

export const initPlayerGametypeStore = (db: IDBDatabase) : IDBObjectStore => {
  const output = db.createObjectStore('playerGametype', { keyPath: ['playerID', 'typeID'] });
  output.createIndex('playerID', 'playerID', { unique: false });
  output.createIndex('typeID', 'typeID', { unique: false });
  output.createIndex('playerIdTypeId', ['playerID', 'typeID'], { unique: true });

  return output;
};

export const initTeamGametypeStore = (db: IDBDatabase) : IDBObjectStore => {
  const output = db.createObjectStore('teamGametype', { keyPath: ['teamID', 'typeID'] });
  output.createIndex('teamID', 'teamID', { unique: false });
  output.createIndex('typeID', 'typeID', { unique: false });
  output.createIndex('playerIdTypeId', ['teamID', 'typeID'], { unique: true });

  return output;
};

export const initTeamStore = (db: IDBDatabase) : IDBObjectStore => {
  const output = db.createObjectStore('teams', { keyPath: 'id' });

  output.createIndex('memberCount', 'memberCount', { unique: false });
  output.createIndex('name', 'name', { unique: true });
  output.createIndex('normalisedName', 'normalisedName', { unique: true });


  return output;
};

//  END:  individual object store initialisers
// ------------------------------------------------------------------
// START: db initialisation

const getIDBDatabase = (event : Event) : IDBDatabase | false => {
  if (typeof event.target !== 'undefined' && event.target !== null
    && typeof (event.target as IDBOpenDBRequest).result !== 'undefined'
    && (event.target as IDBOpenDBRequest).result instanceof IDBDatabase
  ) {
    return (event.target as IDBOpenDBRequest).result;
  }
  return false;
};

const setScoredDB = (event : Event) => {
  console.group('setScoredDB()');
  console.log('event:', event);

  if (scoredDB === null) {
    scoredDB = getIDBDatabase(event);

    if (scoredDB !== false) {
      initGameTypesData(scoredDB);
      initPlayersData(scoredDB);
      initTeamsData(scoredDB);
    }
  }

  console.log('scoredDB:', scoredDB);
  console.groupEnd();
};


//  END:  individual object store initialisers
// ------------------------------------------------------------------
// START: db initialisation

export const deleteScoredDB = async () => {
  await deleteDB('ScoredDB');
};

export const getScoredDB = async () => {
  if (scoredDB === null) {
    scoredDB = await openDB('ScoredDB', 1, { upgrade: _upgradeDB });

    request.onupgradeneeded = (event : Event) => {
      console.group('getScoredDB onupgradeneeded()');
      console.log('event:', event);

      const db : IDBDatabase|false = getIDBDatabase(event);
      console.log('db:', db);
      console.log('db instanceof IDBDatabase:', db instanceof IDBDatabase);

      // setScoredDB(event);

      if (db instanceof IDBDatabase) {
        // Create current game store
        db.createObjectStore('appState');

        // Create current game store
        db.createObjectStore('currentGame');

        // Create custom game store
        initCustomGamesStore(db);

        // Create game type store
        initGameTypeStore(db);

        // Create a pastGames-gameType link store
        initGametypePastGameStore(db);

        // Create past games store
        initGamedataStore(db);

        // Create a player-gameType link store
        initPlayerGametypeStore(db);

        // Create a pastGames-player link store
        initPlayerPastgameStore(db);

        // Create a team-player link store
        initPlayerTeamStore(db);

        // Create player store
        initPlayerStore(db);

        // Create a team-gameType link store
        initTeamGametypeStore(db);

        // Create a pastGames-team link store
        initTeamPastgameStore(db);

        // Create team store
        initTeamStore(db);
      }
    }
  }
  console.log('scoredDB:', scoredDB);
  console.groupEnd();

  // return scoredDB;
};

//  END:  db initialisation
// ------------------------------------------------------------------
