import { ITeam } from '../../types/players';
import { FIdbSuccess } from '../../types/general';
import { getIDBrequest } from './indexedDB.utils';
import { writeTeam, writeTeamPlayerJoin } from './team-store';

const initialData : ITeam[] = [
  {
    id: "YpzV-52pd2ejVnjV_XVU7",
    name: "Evan & Georgie",
    members: ["DsaGJXvfavRJLjMCCKgIv", "-ZYd2yScYkOgLCVU8aDpP"],
    normalisedName: "georgieevan",
  },
  {
    id: "B9N6l5wjrdSrDNl70-lUc",
    name: "Evan & Ada",
    members: ["DsaGJXvfavRJLjMCCKgIv", "khx9ZsrHr3cNn9DGBCgRB"],
    normalisedName: "evanada",
  },
  {
    id: "-rukQJEN44A0vnzWjmxqg",
    name: "Evan & Mallee",
    members: ["DsaGJXvfavRJLjMCCKgIv", "ZwRyWeWNje-1JxKE_hhiW"],
    normalisedName: "evanmallee",
  },
  {
    id: "qXQm_5CPG7feJOQoBapFN",
    name: "Georgie & Ada",
    members: ["-ZYd2yScYkOgLCVU8aDpP", "khx9ZsrHr3cNn9DGBCgRB"],
    normalisedName: "georgieada",
  },
  {
    id: "NwR3OZNH5Ec8WwosoGGnf",
    name: "Georgie & Mallee",
    members: ["-ZYd2yScYkOgLCVU8aDpP", "ZwRyWeWNje-1JxKE_hhiW"],
    normalisedName: "georgiemallee",
  },
  {
    id: "t2dXtyuHWZe_DBPg8RLTk",
    name: "Mallee & Ada",
    members: ["ZwRyWeWNje-1JxKE_hhiW", "khx9ZsrHr3cNn9DGBCgRB"],
    normalisedName: "malleeada",
  },
];

const initTeamsData = (db: IDBDatabase) : void => {
  // console.group('initTeams()');
  // console.log('db:', db);

  const TStore = getIDBrequest(db, 'teams', true);

  const countRequest = TStore.count();

  console.log('TStore:', TStore);

  const success : FIdbSuccess = (event : Event) => {
    console.group('initTeamsData.success() -> writeTeam.onsuccess()');
    console.log('Successfully added team all teams', event);
    console.log('event:', event);
    console.log('event.target:', event.target);
    console.groupEnd();
    for (const team of initialData) {
      writeTeamPlayerJoin(db, team);
    }
  };

  countRequest.onsuccess = () => {
    if (typeof countRequest.result === 'number'
      && countRequest.result < initialData.length
    ) {
      for (const team of initialData) {
        writeTeam(db, team, success);
      }
    }
  }

  // console.groupEnd();
};

export default initTeamsData;
