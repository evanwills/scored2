import { IDBPDatabase, IDBPObjectStore } from "idb";

/**
 * Get an object store transaction for a single object store
 *
 * @param db IndexedDb connection object
 * @param storeName Name of the object store we are working with
 * @param write Whether actions are read-write
 *
 * @returns A transaction wrapped object store
 */
export const getIDBrequest = (
  db : IDBPDatabase,
  storeName : string,
  write : boolean = false,
) : IDBPObjectStore => {
  const mode : IDBTransactionMode = (write === true)
      ? 'readwrite'
      : 'readonly';

  return db.transaction(storeName, mode).objectStore(storeName);
};
