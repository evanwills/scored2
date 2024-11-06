import { TWinnerLooser } from '../types/game-data.d';
import { TScoreCard } from '../types/score-card';

/**
 * Set the position/rank of players based on their score.
 *
 * @param players list of players in game
 *
 * @returns Updated list of players with latest ranking set.
 */
export const rankPlayers = (players: Array<TScoreCard>, rev: boolean = false) : Array<TScoreCard> => {
  const ranking = players.map(
    (player, index) => ({
      i: index,
      id: player.id,
      total: player.total,
      rank: 0
    }),
  );

  const higher = (rev === true)
    ? -1
    : 1;

  const lower = higher * -1;

  // Sort players from highest to lowest by their score
  ranking.sort(
    (a, b) => {
      if (a.total > b.total) {
        return higher;
      } else if (a.total < b.total) {
        return -lower;
      } else {
        return 0;
      }
    }
  );

  // Set players rank based on their sorted position
  for (let a = 0; a < ranking.length; a += 1) {
    ranking[a].rank = a + 1;
  }

  // Put players back in their original order
  ranking.sort((a, b) => {
    if (a.i > b.i) {
      return 1;
    } else if (a.i < b.i) {
      return -1;
    } else {
      return 0;
    }
  });

  // Update the rankings for each player and return the whole lot.
  return players.map((player, index) => {
    if (player.id !== ranking[index].id) {
      throw new Error(
        `Player ${player.id} could not be ranked because ID ` +
        'didn\'t match rank ID.',
      );
    }

    return {
      ...player,
      position: ranking[index].rank
    };
  });
}

/**
 * Update the score for a given player then update the ranking for
 * all the players
 *
 * @param players   List of all the players in the game
 * @param player    Object for the player being updated
 * @param newScores Updated list of scores for the player being
 *                  updated
 * @param rev       Whether or not the players should be ranked from
 *                  highest to lowest or the reverse.
 *
 * @returns Updated list of players
 */
export const updateScoreAndRank = (players: Array<TScoreCard>, player: TScoreCard, newScores: Array<number>, rev: boolean = false) => {
  const _tmp = {
    ...player,
    scores: newScores,
    total: newScores.reduce(
      (_total, _score) => (_total + _score), 0
    ),
  };

  return {
    players: rankPlayers(
      players.map(
        (_player) => (_player.id === _tmp.id)
          ? _player
          : _tmp,
      ),
      rev,
    ),
  };
};

/**
 * Get the player/team object matching the player ID
 *
 * @param players  List of players for the game.
 * @param playerID ID of player/team being requested
 *
 * @returns A single player/team object if matched by ID or
 *          NULL if ID could not be matched
 */
export const getPlayer = (players : Array<TScoreCard>, playerID : string) : TScoreCard|null => {
  for (let a = 0; a < players.length; a += 1) {
    if (players[a].id === playerID) {
      return players[a];
    }
  }
  return null;
};

/**
 * Get error message when unknown player ID has been supplied
 *
 * @param method   Name of method that will throw the error
 * @param playerID ID of player/team that could not be found
 *
 * @returns Message to use when throwing an error.
 */
export const getPlayerError = (gameName: string, method: string, playerID: string) : string => {
  return `${gameName}.${method}() expects argument \`playerID\` ` +
         'to be the name of a known player for this game. ' +
         `"${playerID}" did not match any known players`;
};


/**
 * Get the score(s) and ID(s) of the highest and lowest point
 * scorer(s) in the game
 *
 * @param players List of score cards for all the players/teams in
 *                the game.
 * @returns The score and ID of the highest and lowest point
 *          scorer(s) of the game
 */
export const getHighLow = (players: Array<TScoreCard>) : TWinnerLooser => {
  let highestScore : number = -100000;
  let highestID : string = '';
  let lowestScore : number = 100000;
  let lowestID : string = '';
  let prefix : string = '';

  for (let a = 0; a < players.length; a += 1) {
    if (players[a].total > highestScore) {
      highestScore = players[a].total;
      highestID = players[a].id
    } else if (players[a].total === highestScore) {
      prefix = (highestID !== '')
        ? ', '
        : '';
        highestID += prefix + players[a].id;
    }

    if (players[a].total < lowestScore) {
      lowestScore = players[a].total;
      lowestID = players[a].id
    } else if (players[a].total === lowestScore) {
      prefix = (highestID !== '')
        ? ', '
        : '';
      lowestID += prefix + players[a].id;
    }
  }

  return {
    high: {
      id: highestID,
      score: highestScore,
    },
    low: {
      id: lowestID,
      score: lowestScore,
    }
  }
}
