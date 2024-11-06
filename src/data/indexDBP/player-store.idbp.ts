import { IDBPDatabase, IDBPObjectStore } from "idb";
import { IIndividualPlayer } from "../../../types/players";


export const initPlayerStore = (db: IDBPDatabase) : void => {
  const output = db.createObjectStore('players', { keyPath: 'id' });

  output.createIndex('name', 'name', { unique: false });
  output.createIndex('normalisedName', 'normalisedName', { unique: true });
  output.createIndex('secondName', 'secondName', { unique: false });
};

/**
 * Write player data to the players object store
 *
 * @param store IndexedDB object atore transaction
 * @param data  Player data to write to the store
 * @param update Whether or not player data is being updated
 */
export const writePlayer = async (
  store : IDBPObjectStore,
  data: IIndividualPlayer,
  update : boolean = false
) => {
  if (typeof store !== 'undefined') {
    if (update === true) {
      if (typeof store.put !== 'undefined') {
        await store.put(data);
      }
    } else {
      if (typeof store.add !== 'undefined') {
        await store.add(data);
      }
    }
  }
};
