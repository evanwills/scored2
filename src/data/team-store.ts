import { ITeam, TJoinPlayerTeam } from '../../types/players';
import { FIdbSuccess } from '../../types/general';
import { getIDBrequest } from './indexedDB.utils';

export const initTeamStore = (db: IDBDatabase) : IDBObjectStore => {
  const output = db.createObjectStore('teams', { keyPath: 'id' });

  output.createIndex('memberCount', 'memberCount', { unique: false });
  output.createIndex('name', 'name', { unique: true });
  output.createIndex('normalisedName', 'normalisedName', { unique: true });

  return output;
};

const _joinTeamPlayer = (store: IDBObjectStore, join : TJoinPlayerTeam) : void => {
  const request = store.put(join);

  request.onsuccess = (event : Event) => {
    // console.group('joinTeamPlayer.onsuccess()');
    // console.log('event:', event);
    // console.log('join:', join);
    console.log(`Successfully added join for player/team: "${JSON.stringify(join)}"`, event);
    // console.groupEnd();
  };

  request.onerror = (event : Event) => {
    console.group('joinTeamPlayer.onerror()');
    console.error('event:', event);
    console.error('join:', join);
    console.error(`Failed to add player/team: "${JSON.stringify(join)}"`);
    console.groupEnd();
  };
};

const getTeamPlayerJoins = (
  store : IDBObjectStore,
  id: string,
  byPlayer : boolean = false,
) => {

}

/**
 * Write player data to the players object store
 *
 * @param store IndexedDB object atore transaction
 * @param data  Player data to write to the store
 * @param update Whether or not player data is being updated
 */
export const writeTeam = (
  db : IDBDatabase,
  team: ITeam,
  success : FIdbSuccess,
  update: boolean = false,
) : void => {
  const tStore = getIDBrequest(db, 'teams', true);
  const request = (update === true)
    ? tStore.put(team)
    : tStore.add(team);

  request.onsuccess = success;

  request.onerror = (event : Event) => {
    const mode = (update === true)
      ? 'update'
      : 'add';
    console.group('writeTeam.onerror()');
    console.info(`Failed to ${mode} team: "${team.name}"`);
    console.info('team:', team);
    console.info('event:', event);
    console.info('event.target:', event.target);
    console.error('Error:', (event.target as IDBRequest).error);
    console.groupEnd();
  };
};

export const writeTeamPlayerJoin = (
  db : IDBDatabase,
  team : ITeam,
) => {
  const jStore = getIDBrequest(db, 'playerTeam', true);

  const request = jStore.getAll();

  for (let a = 0; a < team.members.length; a += 1) {
    _joinTeamPlayer(
      jStore,
      {
        playerID: team.members[a],
        teamID: team.id,
        position: a + 1,
      },
    );
  }
}
