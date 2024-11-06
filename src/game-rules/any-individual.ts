import { IGameRules } from "../types/game-rules";
import { TCall } from "../types/game-rules";
import { TScoreCard, TSimpleScore } from "../types/score-card";
import { getPlayer, getPlayerError, rankPlayers } from "./game-utils";


export class AnyIndividual implements IGameRules {
  // ================================================================
  // START: property declarations

  // ----------------------------------------------------------------
  // START: private property declarations

  _canUpdate: boolean = false;
  _looser: string = '';
  _winner: string = '';
  _gameOver: boolean = false;
  _players: Array<TScoreCard> = [];

  //  END:  private property declarations
  // ----------------------------------------------------------------
  // START: public property declarations

  readonly id : string = 'any-individual'
  readonly lowestWins: boolean = false;
  readonly name: string = 'Non-Teams game';
  readonly maxPlayers: number|null = null;
  readonly maxScore: number = 10000;
  readonly minPlayers: number = 2;
  readonly minScore: number|null = null;
  readonly callToWin: boolean = false;
  readonly possibleCalls: TCall[] = [];
  readonly requiresCall: boolean = false;
  readonly requiresTeam: boolean = false;
  readonly rules: string = '';
  readonly teams: boolean = false;

  //  END:  public property declarations
  // ----------------------------------------------------------------

  //  END:  property declarations
  // ================================================================
  // START: method declarations

  constructor(players: Array<string>) {
    this._players = players.map((player) => ({
      id: player,
      scores: [],
      total: 0,
      position: 0,
    }));
    this.id = 'any-individual'
    this.lowestWins = false;
    this.name = 'Non-Teams game';
    this.maxPlayers = null;
    this.maxScore = 10000;
    this.minPlayers = 2;
    this.minScore = null;
    this.callToWin = false;
    this.possibleCalls = [];
    this.requiresCall = false;
    this.requiresTeam = false;
    this.rules = '';
    this.teams = false;
    this.gameOver = () => this._gameOver;
  }

  canPlay () : boolean {
    return !this._gameOver;
  };

  canUpdate () : boolean {
    return this._canUpdate;
  };

  forceGameEnd () : void {
    if (this._gameOver === false) {
      let winnerScore = this.maxScore;
      let winnerID = '';
      let looserScore = this.maxScore;
      let looserID = '';
      let prefix = '';

      for (let a = 0; a < this._players.length; a += 1) {
        if (this._players[a].total > looserScore) {
          looserScore = this._players[a].total;
          looserID = this._players[a].id
        } else if (this._players[a].total === looserScore) {
          prefix = (winnerID !== '')
            ? ', '
            : '';
          looserID += prefix + this._players[a].id;
        }
        if (this._players[a].total < winnerScore) {
          winnerScore = this._players[a].total;
          winnerID = this._players[a].id
        } else if (this._players[a].total === winnerScore) {
          prefix = (winnerID !== '')
            ? ', '
            : '';
            winnerID += prefix + this._players[a].id;
        }
      }

      this._gameOver = true;
      this._canUpdate = false;
    }
  };

  /**
   * Check whether the game is over.
   *
   * NOTE: If the private _gameOver property is false, gameOver() will
   *
   * @returns TRUE if one or more players has a score that is creater
   *          than 500 or less than -500. FALSE otherwise.
   */
  gameOver () : boolean {
    if (this._gameOver === false) {
      let looserScore = 100;
      let looserID = '';

      for (let a = 0; a < this._players.length; a += 1) {
        if (this._players[a].total >= 100) {
          this._looser = this._players[a].id;
          this._gameOver = true;
        } else if (this._players[a].total < looserScore) {
          looserScore = this._players[a].total;
          looserID = this._players[a].id
        } else if (this._players[a].total === looserScore) {
          const prefix = (looserID !== '')
            ? ', '
            : '';

          looserID += prefix + this._players[a].id;
        }
      }

      this._canUpdate = !this._gameOver;
    }

    return this._gameOver
  };

  getCalls () : [] {
    return [];
  };

  getCall (_id: string) : null {
    return null;
  };

  getLooser () : string {
    return (this.gameOver() === true)
      ? this._looser
      : '';
  };

  getPlayers () : Array<TScoreCard> {
    return this._players;
  }

  getScore (playerID: string) : number {
    const player = getPlayer(this._players, playerID);
    if (player === null) {
      throw new Error(getPlayerError(this.name, 'setLead', playerID));
    }

    return player.total;
  };

  getCurrentScores () : Array<TSimpleScore> {
    return this._players.map((player) => {
      const output : TSimpleScore = {};
      output[player.id] = player.total;
      return output;
    })
  }

  getWinner () : string {
    return (this.gameOver() === true)
      ? this._winner
      : '';
  };

  setLead (_playerID: string, _call: string) : void {
  };

  setScore (playerID: string, score: number) : number {
    const tmp = getPlayer(this._players, playerID);
    if (tmp === null) {
      throw new Error(getPlayerError(this.name, 'setScore', playerID));
    }

    return this._updateRankAndScore(
      tmp,
      [
        ...tmp.scores,
        score,
      ]
    );
  };

  updateScore (playerID: string, score: number, round: number) : number {
    const tmp = getPlayer(this._players, playerID);
    const _r = round - 1;
    if (tmp === null) {
      throw new Error(getPlayerError(this.name, 'updatetScore', playerID));
    }

    return this._updateRankAndScore(
      tmp,
      tmp.scores.map((_score, _index) => (_r === _index)
        ? score
        : _score
      ),
    );
  };

  _updateRankAndScore (player: TScoreCard, newScores: Array<number>) : number {
    const _tmp = {
      ...player,
      scores: newScores,
      total: newScores.reduce(
        (_total, _score) => (_total + _score),
        0,
      ),
    };

    this._players = rankPlayers(
      this._players.map(
        (_team) => (_team.id === _tmp.id)
          ? _team
          : _tmp,
      ),
    );

    return _tmp.total;
  }
}
