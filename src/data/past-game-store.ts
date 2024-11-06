export const initGamedataStore = (db: IDBDatabase) : void => {
  const output = db.createObjectStore('gameData', { keyPath: 'id' });
  output.createIndex('end', 'end', { unique: false });
  output.createIndex('forced', 'forced', { unique: false });
  output.createIndex('looser', 'looser', { unique: false });
  output.createIndex('start', 'start', { unique: false });
  output.createIndex('teams', 'teams', { unique: false });
  output.createIndex('type', 'type', { unique: false });
  output.createIndex('winner', 'winner', { unique: false });
};

export const initGamedataGametypeStore = (db: IDBDatabase) : void => {
  const output = db.createObjectStore('gametypeGamedata', { keyPath: ['gameID', 'typeID'] });
  output.createIndex('gameID', 'gameID', { unique: false });
  output.createIndex('typeID', 'typeID', { unique: false });
  output.createIndex('gameIdTypeId', ['gameID', 'typeID'], { unique: true });
};
