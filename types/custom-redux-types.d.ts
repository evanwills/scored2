// import { AnyAction } from '@reduxjs/toolkit';
import { TGameData } from './game-data';

export interface IPastGameAction {
  payload: TGameData
}

export type TGameType = {
  id: string,
  name: string,
  description: string,
}

export type TGameTypes = Array<TGameType>;
