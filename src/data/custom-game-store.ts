
export const initCustomGamesStore = (db: IDBDatabase) : void => {
  const output = db.createObjectStore('customGames', { keyPath: 'id' });
  output.createIndex('name', 'name', { unique: true });
  output.createIndex('maxPlayers', 'maxPlayers', { unique: false });
  output.createIndex('minPlayers', 'minPlayers', { unique: false });
  output.createIndex('requiresTeam', 'requiresTeam', { unique: false });
};
