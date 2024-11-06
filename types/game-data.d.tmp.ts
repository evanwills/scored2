import { IPlayer, IIndividualPlayer, TTeam } from './players';
import { TScoreCard } from './score-card';

export type TGameLead = {
  player: IPlayer,
  call: number,
  suit: string,
};

/**
 * States for game data
 *
 * @readonly
 * @enum {string}
 */
export enum EGameStates {
  /**
   * Current game is in type selection mode
   *
   * * Default state when a new TGameData object is created
   * * If players list is empty, next state must be `ADD_PLAYERS`
   * * Current game cannot move into `SET_TYPE` mode if it has been
   *   in `PLAYING mode
   *
   * @member {string}
   */
  SET_TYPE,
  /**
   * Current game is in add player mode
   *
   * Can transition either to `PLAYING` mode or `SET_TYPE` mode.
   *
   * > __Note:__ Depending on the game, "players" may be individual
   *             players or teans.
   *
   * > __Note also:__ If current game is an "indiviual player" type
   *             game
   *             *and*
   *             the players list is not empty and current game moves
   *             to `SET_TYPE` mode
   *             *and*
   *             the updated "type" is a teams type game, the
   *             players list will be emptied.
   *             The same applies if the inital game type is a
   *             "teams" type game and the new type is an
   *             "individual player" type game
   *
   * @member {string}
   */
  ADD_PLAYERS,
  /**
   * Current game is in playing/scoring mode
   *
   * * Can only transition from `ADD_PLAYERS` to `PLAYING` mode
   * * Can only transition to `GAME_OVER`
   *
   * @member {string}
   */
  PLAYING,
  /**
   * Game is over and scores cannot be added or updated
   *
   * * Can only transition from `PLAYING`
   * * If `TGameData.forced` is `TRUE`, can transition back to
   *   `PLAYING`
   *
   * @member {string}
   */
  GAME_OVER,
};

/**
 * @type Data for a single game
 */
export type TGameData = {
  /**
   * @property ISO 8601 date-time string for when the game ended
   */
  end: string|null,

  /**
   * Whether or not the game was force finished.
   *
   * If `forced` is TRUE, the game can be resumed at a later date.
   *
   * @property
   */
  forced: boolean,

  /**
   * @property Unique ID for this game
   */
  id: string,

  lead: TGameLead|null,

  /**
   *
   *
   * @property Name of losing player/team
   */
  looser: string|null,

  /**
   * State of the current game
   *
   * Possible states are:
   * * SET_TYPE - Set the type of game being played
   * * ADD_PLAYERS - Add players to game
   * * PLAYING - Add scores
   * * GAME_OVER
   *
   * __Note:__ If a TGameData object is in the past games list it
   *           will only ever be in `GAME_OVER` state.
   *
   * @property
   */
  mode: EGameStates,

  /**
   * @property List of players (or teams) who are/were playing this
   *           game
   */
  players: Array<IPlayer>,

  /**
   * @property Score cards for each player
   */
  scores: Array<TScoreCard>,

  /**
   * ISO 8601 date-time string for when the game started
   *
   * > __Note:__ `start` will be set on initialisation of a new game
   * >           and will be updated when game's `state` value goes
   * >           from `EGameStates.ADD_PLAYERS`
   * >           to   `EGameStates.PLAYING`
   *
   * @property
   */
  start: string,

  /**
   * @property Whether or not the players are actually teams
   */
  teams: boolean,

  /**
   * @property The type ID of game this score is for
   */
  type: string,

  /**
   * @property ID of the winning player or team
   */
  winner: string|null,
};

/**
 * @property data for the whole app
 */
export type TScoredStore = {
  /**
   * @property The game currently in progress and taking scores
   */
  currentGame: TGameData|null,

  /**
   * @property List of configuration settings for custom games
   */
  customGames: Array<IGameRuleData>,

  /**
   * @property List of configuration settings for custom games
   */
  gameTypes: Array<IGameRuleData>,

  /**
   * @property List of all the past games scored by this app
   */
  pastGames: Array<TGameData>,

  /**
   * @property List of all players who have ever played a game
   *           scored by this app
   */
  players: Array<IIndividualPlayer>,

  /**
   * @property List of all teans who have ever played a game
   *           scored by this app
   */
  teams: Array<TTeam>,
}

export type TWinnerLooser = {
  high: {
    id: string,
    score: number,
  },
  low: {
    id: string,
    score: number,
  },
};

export type TActionPayloadNewGame = null;
export type TActionPayloadGameMode = { mode: EGameStates, start: string };
export type TActionPayloadGameLead = { id: string, call: number, suit: string };
export type TActionPayloadGameSetScore = { id: string, score: number };
export type TActionPayloadGameUpdateScore = {id: string, round: number, score: number };
