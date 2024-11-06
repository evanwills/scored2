import { UID } from './base-types';
import { TGameScoreCard, TScoreCard } from './score-card'

export type TCall = {
  id: UID,
  name: string,
  score: number,
  tricks: number,
}

export interface TLead extends TCall {
  id: UID,
  name: string,
  score: number,
  tricks: number,
  playerID: UID
}

export type FHasWon = () => string;
export type FUpdateScore = (playerID: UID, score: number, round: number) => IScoreEntry;

export type FGetScore = (playerID: UID) => number;

export interface IGameRuleData {
  /**
   * For trick based games (like 500) a game can only be won if the
   * winning team won the call at the start of th hand
   *
   * @property
   */
  callToWin: boolean,

  /**
   * ID of the game being scored
   *
   * @property
   */
  id: UID,

  /**
   * Some games are played so that the person with the lowest
   * score wins or the person with the lowest score looses (which
   * is almost the same).
   *
   * e.g. In Crazy Eights the first person to 100 looses.
   *
   * @property
   */
  lowestWins: boolean,

  /**
   * Maximum number of players who can play the game
   *
   * zero means there is no maximum
   *
   * @property
   */
  maxPlayers: number|null,

  /**
   * Maximum score over which a winner (or looser) can be declared
   *
   * @property
   */
  maxScore: number|null,

  /**
   * Minimum number of players who can play the game.
   * (This would normally be two)
   *
   * @property
   */
  minPlayers: number,

  /**
   * Minimum score over which a looser (or winner) can be declared
   *
   * @property
   */
  minScore: number|null,

  /**
   * Name of the game being scored
   *
   * @property
   */
  name: string,

  /**
   * For trick based games (like 500) there are a fixed set of calls
   * that are made at the start of each hand. This specifies all the
   * allowed calles and their scores.
   *
   * @property
   */
  possibleCalls: Array<TCall>,

  /**
   * For trick based games (like 500), at the start of each hand,
   * each player can make a call on how many tricks they think they
   * can win that hand. The winner of the call gets the kitty
   * scoring and game play is affected by the call.
   *
   * @property
   */
  requiresTeam: boolean,

  /**
   * Some games like 500 & Bridge are played in teams.
   *
   * @property
   */
  requiresCall: boolean,

  /**
   * Description of how to play the game
   *
   * @property
   */
  rules: string,

  /**
   * Whether or not this game requires teams.
   *
   * @property
   */
  teams: boolean,
}

export interface IGameRules extends IGameRuleData {
  canPlay: () => boolean,
  canUpdate: () => boolean,
  forceGameEnd: () => void,
  gameOver: () => boolean,
  getCalls: () => Array<TCall>,
  getCall: (id: string) => TCall|null,
  getLooser: () => string,
  getPlayers: () => Array<TScoreCard>,
  getScore: FGetScore,
  getWinner: () => string,
  setLead: (playerID: string, call: string) => void,
  setScore: (playerID: string, score: number) => IScoreEntry,
  updateScore: FUpdateScore,
  readonly id: string,
  readonly lowestWins: boolean,
  readonly maxPlayers: number|null,
  readonly maxScore: number|null,
  readonly minPlayers: number,
  readonly minScore: number|null,
  readonly name: string,
  readonly callToWin: boolean,
  readonly possibleCalls: Array<TCall>,
  readonly requiresTeam: boolean,
  readonly requiresCall: boolean,
  readonly rules: string,
}
