// import { EAppStates } from "../redux/app-state";
// import { TGameTypes } from "./custom-redux-types";
// import { TGameData } from "./game-data";
// import { IIndividualPlayer, ITeam } from "./players";

export type FEpre = (method: string, before: boolean|null|string) => string;

export type TAppRoute = {
  anchor: string,
  label: string,
  icon: string,
};

export type FIdbSuccess = (event : Event) => void;

export type UID = string;
export type ISO8601 = string;
