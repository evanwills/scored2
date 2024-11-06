import { IGameRuleData, IGameRules } from '../../types/game-rules';
import { FiveHundred } from '../game-rules/500';
import { AnyIndividual } from '../game-rules/any-individual';
import { AnyTeam } from '../game-rules/any-teams';
import { CrazyEights } from '../game-rules/crazy-eights';

// ------------------------------------------------------------------
// START: game type store object initialisation

export const initGameTypeStore = (db: IDBDatabase) : IDBObjectStore => {
  const output = db.createObjectStore('gameTypes', { keyPath: 'id' });
  output.createIndex('name', 'name', { unique: true });
  output.createIndex('maxPlayers', 'maxPlayers', { unique: false });
  output.createIndex('minPlayers', 'minPlayers', { unique: false });
  output.createIndex('requiresTeam', 'requiresTeam', { unique: false });

  // initGameTypes(db);

  return output;
};

// START: game type store object initialisation
// ------------------------------------------------------------------
//  END:  game type data initialisation

const _initGameTypeTransComplete = (event : Event) => {
  console.log('Game type initialisation complete!', event);
  // console.log('event:', event);
};

const _initGameTypeTransError = (event : Event) => {
  console.group('getRule.[transaction]onerror()');
  console.error('Something went wrong with adding one or all game types!');
  console.error('event:', event);
  console.groupEnd();
};

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

const _initSetRule = (transaction : IDBTransaction, preBuilt : IGameRules) : void => {
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

  const store = transaction.objectStore('gameTypes');

  const request = store.add(rule);

  request.onsuccess = _initSetRuleSuccess(rule);
  request.onerror = _initSetRuleError(rule);
};

export const initGameTypesData = (db : IDBDatabase) => {
  // @TODO check that rules exist before adding inbuilt rules
  const transaction = db.transaction(['gameTypes'], 'readwrite');

  transaction.oncomplete = _initGameTypeTransComplete;
  transaction.onerror = _initGameTypeTransError;

  _initSetRule(transaction, new FiveHundred([]));
  _initSetRule(transaction, new CrazyEights([]));
  _initSetRule(transaction, new AnyIndividual([]));
  _initSetRule(transaction, new AnyTeam([]));
};

//  END:  game type data initialisation
// ------------------------------------------------------------------
