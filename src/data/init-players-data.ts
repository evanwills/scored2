import { IIndividualPlayer } from '../../types/players';
import { getIDBrequest } from './indexedDB.utils';
import { writePlayer } from './player-store';

const initialData : IIndividualPlayer[] = [
  { id: 'DsaGJXvfavRJLjMCCKgIv', name: 'Evan', secondName: 'Wills', normalisedName: 'evan' },
  { id: '-ZYd2yScYkOgLCVU8aDpP', name: 'Georgie', secondName: 'Pike', normalisedName: 'georgie' },
  { id: 'ZwRyWeWNje-1JxKE_hhiW', name: 'Mallee', secondName: 'Pike Wills', normalisedName: 'mallee' },
  { id: 'khx9ZsrHr3cNn9DGBCgRB', name: 'Ada', secondName: '', normalisedName: 'ada' },
  { id: 'NIGhDSx4bVUfRrUCFe9MT', name: 'Carmel', secondName: 'Pike', normalisedName: 'carmel' },
  { id: 'RNyNQ0siFUTooQSVMsiHd', name: 'Jess', secondName: '', normalisedName: 'jess' },
  { id: 'LI_IT_gg_rkOggWn0sf2R', name: 'Stu', secondName: '', normalisedName: 'stu' },
  { id: '2m1HyyzigyDeK9ojvSW3q', name: 'Ally', secondName: '', normalisedName: 'ally' },
  { id: 'f2CmGuyOP6U0b_6S1uI91', name: 'Matt', secondName: '', normalisedName: 'matt' },
];

const initPlayersData = (db: IDBDatabase) : void => {
  // console.group('initPlayersData()');
  // console.log('db:', db);
  const store = getIDBrequest(db, 'players', true);

  for (const player of initialData) {
    writePlayer(store, player);
  }

  // console.groupEnd();
};

export default initPlayersData
