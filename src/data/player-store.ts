import { IIndividualPlayer } from "../../types/players";


export const initPlayerStore = (db: IDBDatabase) : IDBObjectStore => {
  const output = db.createObjectStore('players', { keyPath: 'id' });

  output.createIndex('name', 'name', { unique: false });
  output.createIndex('normalisedName', 'normalisedName', { unique: true });
  output.createIndex('secondName', 'secondName', { unique: false });

  return output;
};

/**
 * Write player data to the players object store
 *
 * @param store IndexedDB object atore transaction
 * @param data  Player data to write to the store
 * @param update Whether or not player data is being updated
 */
export const writePlayer = (
  store : IDBObjectStore,
  data: IIndividualPlayer,
  update : boolean = false
) : void => {
  const request = (update === true)
    ? store.put(data)
    : store.add(data);

  request.onsuccess = (event) => {
    const mode = (update === true)
      ? 'updated'
      : 'added';
    // console.group('writePlayer.onsuccess()');
    console.log(`Successfully ${mode} player: "${data.name}"`, event);
    // console.log('event:', event);
    // console.log('event.target:', event.target);
    // console.log('data:', data);
    // console.groupEnd();
  };

  request.onerror = (event) => {
    const mode = (update === true)
      ? 'update'
      : 'add';
    console.group('writePlayer.onerror()');
    console.error(`Failed to ${mode} player: "${data.name}"`);
    console.error('data:', data);
    console.error('event:', event);
    console.error('event.target:', event.target);
    console.error('Error:', (event.target as IDBRequest).error);
    console.groupEnd();
  };

  // console.log('store:', store);
  // console.log('request:', request);
}
