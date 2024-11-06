import { IGameRules, TLead } from '../types/game-rules';
import { TCall } from '../types/game-rules';
import { IScoreEntryTrick, TScoreCard, TSimpleScore } from '../types/score-card';
import { getHighLow, getPlayer, getPlayerError, rankPlayers } from './game-utils';


/**
 * Get the true score from a 500 hand based on number of tricks won
 *
 * @param score Number of tricks won
 * @param lead  Whether or not player won the call
 * @param call  Info about the call that won the lead
 *
 * @returns The true score for the player.
 */
export const get500Score = (score: number, playerID: string, call: TLead) : IScoreEntryTrick => {
  if (call === null) {
    throw new Error(
      '500.getScore() expects third parameter call not to be null',
    );
  }

  const output : IScoreEntryTrick = {
    call: call.name,
    score: 0,
    success: null,
    time: Date.now(),
  }

  const isLead = (playerID === call.playerID);

  if (call.id === 'M' || call.id === 'OM') {
    if (isLead === false) {
      output.score = 0;
      output.success = false;

      return output;
    }

    output.score = (score > 0)
      ? call.score * -1
      : call.score;
    output.success === true;

    return output;
  }

  if (isLead === false) {
    output.score = score * 10;
  } else {
    output.success = (score >= call.tricks)
    output.score = (!output.success)
      ? call.score * -1
      : call.score;
  }

  return output;
};

const _possibleCalls : Array<TCall> = [
  { id: '6S', name: 'Six spades', score: 40, tricks: 6 },
  { id: '6C', name: 'Six clubs', score: 60, tricks: 6 },
  { id: '6D', name: 'Six diamonds', score: 80, tricks: 6 },
  { id: '6H', name: 'Six hearts', score: 100, tricks: 6 },
  { id: '6NT', name: 'Six no trumps', score: 120, tricks: 6 },
  { id: '7S', name: 'Seven spades', score: 140, tricks: 7 },
  { id: '7C', name: 'Seven clubs', score: 160, tricks: 7 },
  { id: '7D', name: 'Seven diamonds', score: 180, tricks: 7 },
  { id: '7H', name: 'Seven hearts', score: 200, tricks: 7 },
  { id: '7NT', name: 'Seven no trumps', score: 220, tricks: 7 },
  { id: 'M', name: 'Misere', score: 250, tricks: 10 },
  { id: '8S', name: 'Eight spades', score: 240, tricks: 8 },
  { id: '8C', name: 'Eight clubs', score: 260, tricks: 8 },
  { id: '8D', name: 'Eight diamonds', score: 280, tricks: 8 },
  { id: '8H', name: 'Eight hearts', score: 300, tricks: 8 },
  { id: '8NT', name: 'Eight no trumps', score: 320, tricks: 8 },
  { id: '9S', name: 'Nine spades', score: 340, tricks: 9 },
  { id: '9C', name: 'Nine clubs', score: 360, tricks: 9 },
  { id: '9D', name: 'Nine diamonds', score: 380, tricks: 9 },
  { id: '9H', name: 'Nine hearts', score: 400, tricks: 9 },
  { id: '9NT', name: 'Nine no trumps', score: 420, tricks: 9 },
  { id: '10S', name: 'Ten spades', score: 440, tricks: 10 },
  { id: '10C', name: 'Ten clubs', score: 460, tricks: 10 },
  { id: '10D', name: 'Ten diamonds', score: 480, tricks: 10 },
  { id: '10H', name: 'Ten hearts', score: 500, tricks: 10 },
  { id: '10NT', name: 'Ten no trumps', score: 520, tricks: 10 },
  { id: 'OM', name: 'Open misere', score: 500, tricks: 10 },
];

/**
 * Get error message when lead has not been set for current hand
 *
 * @param method   Name of method that will throw the error
 *
 * @returns Message to use when throwing an error.
 */
export const getLeadError = (method: string) : string => {
  return `500.${method}() expects lead to have already been set ` +
         'for this hand. Lead has not yet been set.';
}
export class FiveHundred implements IGameRules {
  // ================================================================
  // START: property declarations

  // ----------------------------------------------------------------
  // START: private property declarations

  _canUpdate: boolean = false;
  _gameOver: boolean = false;
  _lead: TLead|null = null;
  _looser: string = '';
  _pastLeads: Array<TLead> = [];
  _teams: Array<TScoreCard> = [];
  _winner: string = '';

  //  END:  private property declarations
  // ----------------------------------------------------------------
  // START: public property declarations
  readonly id: string = 'five-hundred';
  readonly lowestWins: boolean = false;
  readonly maxPlayers: number = 2;
  readonly maxScore: number = 500;
  readonly minPlayers: number = 2;
  readonly minScore: number = -500;
  readonly name: string = '500';
  readonly callToWin: boolean = true;
  readonly possibleCalls: Array<TCall> = _possibleCalls;
  readonly requiresCall: boolean = true;
  readonly requiresTeam: boolean = true;
  readonly rules: string = '';
  readonly teams: boolean = true;

  //  END:  public property declarations
  // ----------------------------------------------------------------

  //  END:  property declarations
  // ================================================================
  // START: method declarations

  constructor(players: Array<string>) {
    this._teams = players.map((player) => ({
      id: player,
      scores: [],
      total: 0,
      position: 0,
    }));
    this.lowestWins = false;
    this.maxPlayers = 2;
    this.maxScore = 500;
    this.minPlayers = 2;
    this.minScore = -500;
    this.name = '500';
    this.callToWin = true;
    this.possibleCalls = _possibleCalls;
    this.requiresCall = true;
    this.requiresTeam = true;
    this.rules = '';
    this.teams = true;
  }

  canPlay () : boolean {
    return this._lead !== null && this._gameOver === false;
  };

  canUpdate () : boolean {
    return this._canUpdate;
  };

  forceGameEnd () : void {
    this._teams = rankPlayers(this._teams);
    const data = getHighLow(this._teams);

    this._winner = data.high.id;
    this._looser = data.low.id;

    this._gameOver = true;
    this._canUpdate = false;
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
      const data = getHighLow(this._teams);

      if (data.high.score >= 500 || data.low.score <= 500) {
        this._gameOver = true;
        this._winner = data.high.id;
        this._looser = data.low.id;
      }

      this._canUpdate = !this._gameOver;
    }

    return this._gameOver
  };

  getCalls () : Array<TCall> {
    return this.possibleCalls;
  };

  getCall (id: string) : TCall|null {
    const output = this.possibleCalls.filter((call) => call.id === id || call.name === id);
    return (output.length > 0)
      ? output[0]
      : null;
  };

  getLooser () : string {
    return (this.gameOver() === true)
      ? this._looser
      : '';
  };

  getPlayers () : Array<TScoreCard> {
    return this._teams;
  }

  getScore (playerID: string) : number {
    if (this._lead === null) {
      throw new Error(getLeadError('setScore'));
    }
    const player = getPlayer(this._teams, playerID);
    if (player === null) {
      throw new Error(getPlayerError(this.name, 'setLead', playerID));
    }

    return player.total;
  };

  getCurrentScores () : Array<TSimpleScore> {
    return this._teams.map((player) => {
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

  setLead (playerID: string, call: string) : void {
    if (this._lead !== null) {
      this._pastLeads = [...this._pastLeads, this._lead];
    }

    this._lead = null;
    const player = getPlayer(this._teams, playerID);

    if (player === null) {
      throw new Error(getPlayerError(this.name, 'setLead', playerID));
    }

    for (let a = 0; a < this.possibleCalls.length; a += 1) {
      if (this.possibleCalls[a].id === call || this.possibleCalls[a].name === call) {
        this._lead = {
          ...this.possibleCalls[a],
          playerID: playerID,
        };
        break;
      }
    }

    if (this._lead === null) {
      throw new Error(
        '500.setLead() expects second argument `call` to be the ' +
        `the ID or name of a known 500 call. "${call}" did not ` +
        'match any known 500 calls',
      );
    }
  };

  setScore (playerID: string, score: number) : IScoreEntryTrick {
    const tmp = getPlayer(this._teams, playerID);
    if (tmp === null) {
      throw new Error(getPlayerError(this.name, 'setScore', playerID));
    }
    if (this._lead === null) {
      throw new Error(getLeadError('setScore'));
    }

    return this._updateRankAndScore(
      tmp,
      [
        ...tmp.scores,
        get500Score(score, playerID, this._lead),
      ]
    );
  };

  updateScore (playerID: string, score: number, round: number) : IScoreEntryTrick {
    const tmp = getPlayer(this._teams, playerID);
    const _r = round - 1;
    if (tmp === null) {
      throw new Error(getPlayerError(this.name, 'setScore', playerID));
    }
    const lead = (round === this._pastLeads.length)
      ? this._lead
      : this._pastLeads[_r];

    if (typeof lead === 'undefined' || lead === null) {
      throw new Error(
        `500.updateScore() could not determin lead for round ${round}`,
      );
    }

    return this._updateRankAndScore(
      tmp,
      tmp.scores.map((_score, _index) => (_r === _index)
        ? get500Score(score, playerID, this._lead as TLead)
        : _score
      ),
    );
  };

  _updateRankAndScore (player: TScoreCard, newScores: Array<number>) : IScoreEntryTrick {
    const _tmp = {
      ...player,
      scores: newScores,
      total: newScores.reduce(
        (_total, _score) => (_total + _score),
        0,
      ),
    };

    this._teams = rankPlayers(
      this._teams.map(
        (_team) => (_team.id === _tmp.id)
          ? _team
          : _tmp,
      ),
    );

    if (this._teams[0].scores.length === this._teams[1].scores.length) {
      if (this._lead !== null) {
        this._pastLeads = [...this._pastLeads, this._lead];
        this._lead = null;
      }
    }

    return _tmp.total;
  }
}
