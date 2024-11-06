import { UID } from "./base-types";

export interface IPlayer {
  id: UID,
  name: string,
  normalisedName: string,
}

export interface IIndividualPlayer extends IPlayer {
  id: UID,
  name: string,
  normalisedName: string,
  secondName: string,
}

export interface ITeam extends IPlayer {
  id: UID,
  name: string,
  normalisedName: string,
  members: Array<string>,
}

export type TPlayerList = Array<IIndividualPlayer|ITeam>;

export type TPlayerSelectedDetail = {
  IDs: string[],
  players: IIndividualPlayer[],
}

export type TJoinPlayerTeam = {
  playerID: string,
  teamID: string,
  position: number,
};
