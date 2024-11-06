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
  db : IDBDatabase,
  storeName : string,
  write : boolean = false,
  message : string = '',
) : IDBObjectStore => {
  const mode = (write === true)
      ? 'readwrite'
      : 'readonly'
  const trans = db.transaction([storeName], mode);

  trans.oncomplete = (event : Event) => {
    console.group(`${storeName} ${mode} transaction complete`);
    if (message !== '') {
      console.log(message);
    }
    console.log('event:', event);
    console.groupEnd();
  };

  trans.onerror = (event : Event) => {
    console.group(`${storeName} ${mode} transaction error`);
    if (message !== '') {
      console.log(message);
    }
    console.error('event:', event);
    console.groupEnd();
  };

  return trans.objectStore(storeName);
};
