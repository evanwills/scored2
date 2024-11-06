import { IDBPDatabase, IDBPObjectStore } from 'idb';
import { IGameRuleData, IGameRules } from '../../../types/game-rules';
import { FiveHundred } from '../../game-rules/500';
import { AnyIndividual } from '../../game-rules/any-individual';
import { AnyTeam } from '../../game-rules/any-teams';
import { CrazyEights } from '../../game-rules/crazy-eights';

// ------------------------------------------------------------------
// START: game type store object initialisation

export const initGameTypeStore = (db: IDBPDatabase) : void => {
  const output = db.createObjectStore('gameTypes', { keyPath: 'id' });
  output.createIndex('name', 'name', { unique: true });
  output.createIndex('maxPlayers', 'maxPlayers', { unique: false });
  output.createIndex('minPlayers', 'minPlayers', { unique: false });
  output.createIndex('requiresTeam', 'requiresTeam', { unique: false });
};

// START: game type store object initialisation
// ------------------------------------------------------------------
//  END:  game type data initialisation


const _initSetRuleSuccess = (rule : IGameRuleData) => (event : Event) => {
  // console.group('getRule.onsuccess()');
  console.log(`Successfully added game type: "${rule.name}"`, event);
  // console.log('event:', event);
  // console.groupEnd();
};

const _initSetRuleError = (rule : IGameRuleData) => (event : Event) => {
  console.group('getRule.[request]onerror()');
  console.log(`Failed to add game type: "${rule.name}"`);
  console.error('event:', event);
  console.groupEnd();
};

const _initSetRule = (store : IDBPObjectStore, preBuilt : IGameRules) : void => {
  const rule : IGameRuleData = {
    id: preBuilt.id,
    lowestWins: preBuilt.lowestWins,
    maxPlayers: preBuilt.maxPlayers,
    maxScore: preBuilt.maxScore,
    minPlayers: preBuilt.minPlayers,
    minScore: preBuilt.minScore,
    name: preBuilt.name,
    callToWin: preBuilt.callToWin,
    possibleCalls: preBuilt.possibleCalls,
    requiresTeam: preBuilt.requiresTeam,
    requiresCall: preBuilt.requiresCall,
    rules: preBuilt.rules,
    teams: preBuilt.teams,
  };

  const request = store.add(rule);

  request.onsuccess = _initSetRuleSuccess(rule);
  request.onerror = _initSetRuleError(rule);
};

export const initGameTypesData = async (db : IDBPDatabase) => {
  // @TODO check that rules exist before adding inbuilt rules
  const store = db.transaction('gameTypes', 'readwrite').objectStore('gameTypes');

  const games = await store.getAll(null, 4);

  console.log('games:', games);

  _initSetRule(store, new FiveHundred([]));
  _initSetRule(store, new CrazyEights([]));
  _initSetRule(store, new AnyIndividual([]));
  _initSetRule(store, new AnyTeam([]));
};

//  END:  game type data initialisation
// ------------------------------------------------------------------
