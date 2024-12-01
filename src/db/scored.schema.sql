
DROP TABLE IF EXISTS J_playerGame;
DROP TABLE IF EXISTS J_playerTeam;
DROP TABLE IF EXISTS D_playerScores;
DROP TABLE IF EXISTS D_teams;
DROP TABLE IF EXISTS D_gameData;
DROP TABLE IF EXISTS D_gameType;
DROP TABLE IF EXISTS D_owners;
DROP TABLE IF EXISTS D_appState;
DROP TABLE IF EXISTS D_players;
DROP TABLE IF EXISTS E_gamePermissionsModes;
DROP TABLE IF EXISTS E_gameStates;
DROP TABLE IF EXISTS E_playerTypes;
DROP TABLE IF EXISTS E_scoreControlModes;
DELETE FROM sqlite_sequence;

-- =====================================================
-- Local only
-- (These table never change so don't need to be replicated/synced)


CREATE TABLE IF NOT EXISTS E_gamePermissionsModes
  -- Different permission modes for a game. (Not replicated/synced because it does not change.)
(
  gamePermissionsMode_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gamePermissionsMode_key VARCHAR(24) NOT NULL,
  gamePermissionsMode_label VARCHAR(24) NOT NULL,
  gamePermissionsMode_description CHAR(160) NOT NULL
);
CREATE UNIQUE INDEX UNI_gamePermissionsMode_key ON E_gamePermissionsModes(gamePermissionsMode_key);
-- SELECT crsql_as_crr('E_gameStates');

INSERT INTO E_gamePermissionsModes (
  gamePermissionsMode_id,
  gamePermissionsMode_key,
  gamePermissionsMode_label,
  gamePermissionsMode_description
) VALUES
  (
    1,
    'AUTOCRAT',
    'Autocrat',
    'Only the game owner can change anything.'
  ),
  (
    2,
    'CONTROL_FREAK',
    'Control freak',
    'Any player can add and update but the game owner must approve all changes.'
  ),
  (
    3,
    'BENEVOLENT_DICTATOR',
    'Benevolent dictator',
    'Any player can add scores. If there is a conflict the game owner must choose. Any player can update or delete scores but game owner must approve.'
  ),
  (
    4,
    'ANARCHIST',
    'Anarchist',
    'All players have the same rights. (If there is a conflict, the most recent update wins.)'
  );


-- - - - - - - - - - - - - - - - - - - - - - - - - - - - -


CREATE TABLE IF NOT EXISTS E_gameStates
  -- Names for the different states a game can be in. (Not replicated/synced because it does not change.)
(
  gameState_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gameState_key VARCHAR(11) NOT NULL,
  gameState_label CHAR(40) NOT NULL
);
CREATE UNIQUE INDEX UNI_gameState_key ON E_gameStates(gameState_key);
-- SELECT crsql_as_crr('E_gameStates');

INSERT INTO E_gameStates (
  gameState_id,
  gameState_key,
  gameState_label
) VALUES
  ( 1, 'SET_TYPE',       'Set the type of game being played' ),
  ( 2, 'ADD_PLAYERS',    'Add players/teams to game' ),
  ( 3, 'SET_PERMISSION', 'Set permissions for individual players' ),
  ( 4, 'PLAYING',        'Playing game (adding scores)' ),
  ( 5, 'SUSPENDED',      'Game is temporarily suspended' ),
  ( 6, 'GAME_OVER',      'Game over' );


-- - - - - - - - - - - - - - - - - - - - - - - - - - - - -


CREATE TABLE IF NOT EXISTS E_playerTypes
  -- Admin permission level for a player. (Not replicated/synced because it does not change.)
(
  playerType_id INTEGER PRIMARY KEY AUTOINCREMENT,
  playerType_key VARCHAR(11) NOT NULL,
  playerType_label CHAR(16) NOT NULL,
  playerType_description VARCHAR(255) NOT NULL
);
CREATE UNIQUE INDEX UNI_playerType_key ON E_playerTypes(playerType_key);
CREATE UNIQUE INDEX UNI_playerType_label ON E_playerTypes(playerType_label);
-- SELECT crsql_as_crr('E_playerTypes');

INSERT INTO E_playerTypes (
  playerType_id,
  playerType_key,
  playerType_label,
  playerType_description
) VALUES
  (
    1,
    'SYSTEM',
    'System',
    'Identifies rows created by the developer. Rows owned by System cannot be updated by any one. Only "System" can create the 1st super admin in a community. "System" cannot start new games or create "Admins", "Ordinary players" or additional "Super admins".'
  ),
  (
    2,
    'SUPER_ADMIN',
    'Super admin',
    'System admins (SAs) have complete control over a community. SAs can create other SAs but cannot delete or update SAs they did not create. The creator of a community is SA for that community. They can do everything an "Ordinary Player" and "Admin" can do.'
  ),
  (
    3,
    'ADMIN',
    'Admin' ,
    'Admins can create new game types and new players, plus do eveything an "Ordinary player" can do.'
  ),
  (
    4,
    'PLAYER',
    'Ordinary player',
    'Ordinary players can start new games, and (where allowed) add and update scores started by other players.'
  );


-- - - - - - - - - - - - - - - - - - - - - - - - - - - - -


CREATE TABLE IF NOT EXISTS E_scoreControlModes
  -- Different permission modes for a game. (Not replicated/synced because it does not change.)
(
  scoreControlMode_id INTEGER PRIMARY KEY AUTOINCREMENT,
  scoreControlMode_key VARCHAR(16) NOT NULL,
  scoreControlMode_label VARCHAR(40) NOT NULL
);
CREATE UNIQUE INDEX UNI_scoreControlMode_key ON E_scoreControlModes(scoreControlMode_key);
-- SELECT crsql_as_crr('E_gameStates');

INSERT INTO E_scoreControlModes (
  scoreControlMode_id,
  scoreControlMode_key,
  scoreControlMode_label
) VALUES
  (
    0,
    'No',
    'Player cannot do.'
  ),
  (
    1,
    'Partial',
    'Player can do but owner must approve.'
  ),
  (
    3,
    'Yes',
    'Player can do (without approval).'
  );


-- =====================================================
-- replicated/synced


CREATE TABLE IF NOT EXISTS D_players (
  player_id CHAR(21) NOT NULL,
  player_typeID TINYINT(3) NOT NULL DEFAULT 2,
  player_blocked BOOLEAN NOT NULL DEFAULT 0,
  player_createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  player_createdBy CHAR(21) NOT NULL,
  player_givenName VARCHAR(32) NOT NULL,
  player_familyName VARCHAR(32) NOT NULL DEFAULT '',
  player_nickName VARCHAR(32) NOT NULL,
  player_normalisedName VARCHAR(64) NOT NULL,
  player_updatedAt TIMESTAMP DEFAULT NULL,
  player_updatedBy CHAR(21) DEFAULT NULL,
  FOREIGN KEY(player_createdBy) REFERENCES E_playerTypes(playerType_id),
  FOREIGN KEY(player_typeID) REFERENCES D_players(player_id),
  FOREIGN KEY(player_updatedBy) REFERENCES D_players(player_id)
);

CREATE UNIQUE INDEX UNI_player_normalisedName ON D_players(player_normalisedName);
CREATE UNIQUE INDEX UNI_player_nickname ON D_players(player_nickname);
CREATE INDEX IND_player_blocked ON D_players(player_blocked);
CREATE INDEX IND_player_createdAt ON D_players(player_createdAt);
CREATE INDEX IND_player_createdBy ON D_players(player_createdBy);
CREATE INDEX IND_player_givenName ON D_players(player_givenName);
CREATE INDEX IND_player_familyName ON D_players(player_familyName);
CREATE INDEX IND_player_updatedAt ON D_players(player_updatedAt);
CREATE INDEX IND_player_updatedBy ON D_players(player_updatedBy);

INSERT INTO D_players (
  player_id,
  player_typeID,
  player_blocked,
  player_givenName,
  player_familyName,
  player_nickName,
  player_normalisedName,
  player_createdBy
) VALUES (
  'dFMhZwNE7JbD4bbGJEkP1',
  1,
  0,
  'System',
  'Admin',
  'admin',
  'systemadmin',
  'dFMhZwNE7JbD4bbGJEkP1'
);
SELECT crsql_as_crr('D_players');


-- =====================================================
-- replicated/synced

CREATE TABLE IF NOT EXISTS D_owners
 -- D_owners is a replicated/synced table that holds user preference data for a given user.
(
  owner_id CHAR(21) NOT NULL,
  owner_colourScheme TEXT DEFAULT NULL, -- JSON object containing custom colour palate values for this app
  owner_darkMode BOOLEAN DEFAULT NULL, -- Whether or not the user wants dark mode
  owner_defaultPermissionsMode TINYINT(3) NOT NULL, -- When player creates a new game this is the default permissions mode applied to the game
  owner_fontAdjust TINYINT(3) NOT NULL DEFAULT 1, -- the amount to up/down scale the base font size
  owner_gameID CHAR(21) DEFAULT NULL, -- Current game this user is playing
  owner_playerID CHAR(21) NOT NULL, -- the player ID this owner is linked to
  FOREIGN KEY(owner_gameID) REFERENCES D_gameData(gameData_id),
  FOREIGN KEY(owner_playerID) REFERENCES D_players(player_id),
  FOREIGN KEY(owner_defaultPermissionsMode) REFERENCES E_gamePermissionsModes(gamePermissionsMode_id)
);
SELECT crsql_as_crr('D_owner');


-- =====================================================
-- Local only


CREATE TABLE IF NOT EXISTS D_appState
  -- This table links the local application with an owner
(
  appState_id TINYINT(1) NOT NULL,
  appState_ownerID CHAR(21) NOT NULL,
  appState_lastURL VARCHAR(255) NOT NULL DEFAULT '', -- the last URL (within scored) the user went to
  FOREIGN KEY(appState_ownerID) REFERENCES D_owners(owner_id)
);


-- =====================================================
-- replicated/synced


CREATE TABLE IF NOT EXISTS D_gameType
  -- Game type provides basic info to help scoring a game
(
  gameType_id CHAR(21) NOT NULL,
  gameType_blocked BOOLEAN NOT NULL DEFAULT 0,
  gameType_builtIn BOOLEAN NOT NULL DEFAULT 0,
  gameType_callToWin BOOLEAN NOT NULL DEFAULT 0,
  gameType_lowestWins BOOLEAN NOT NULL DEFAULT 0,
  gameType_createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gameType_createdBy CHAR(21) NOT NULL,
  gameType_maxPlayers TINYINT(3) NOT NULL DEFAULT 0,
  gameType_maxScore INTEGER DEFAULT NULL,
  gameType_minPlayers TINYINT(3) NOT NULL DEFAULT 2,
  gameType_minScore INTEGER DEFAULT NULL,
  gameType_name VARCHAR(32) NOT NULL,
  gameType_possibleCalls BLOB DEFAULT NULL,
  gameType_requiresCall BOOLEAN NOT NULL DEFAULT 0,
  gameType_requiresTeams BOOLEAN NOT NULL DEFAULT 0,
  gameType_rules TEXT DEFAULT NULL,
  gameType_rulesURL VARCHAR(255) DEFAULT NULL,
  gameType_updatedAt TIMESTAMP DEFAULT NULL,
  gameType_updatedBy CHAR(21) DEFAULT NULL,
  PRIMARY KEY (gameType_id),
  FOREIGN KEY(gameType_createdBy) REFERENCES D_players(player_id),
  FOREIGN KEY(gameType_updatedBy) REFERENCES D_players(player_id)
);

CREATE UNIQUE INDEX UNI_gameType_name ON D_gameType(gameType_name);
CREATE INDEX IND_gameType_blocked ON D_gameType(gameType_blocked);
CREATE INDEX IND_gameType_builtIn ON D_gameType(gameType_builtIn);
CREATE INDEX IND_gameType_callToWin ON D_gameType(gameType_callToWin);
-- CREATE INDEX IND_gameType_lowestWins ON D_gameType(gameType_lowestWins);
CREATE INDEX IND_gameType_createdAt ON D_gameType(gameType_createdAt);
CREATE INDEX IND_gameType_createdBy ON D_gameType(gameType_createdBy);
-- CREATE INDEX IND_gameType_maxScore ON D_gameType(gameType_maxScore);
CREATE INDEX IND_gameType_maxPlayers ON D_gameType(gameType_maxPlayers);
-- CREATE INDEX IND_gameType_minScore ON D_gameType(gameType_minScore);
CREATE INDEX IND_gameType_minPlayers ON D_gameType(gameType_minPlayers);
CREATE INDEX IND_gameType_requiresCall ON D_gameType(gameType_requiresCall);
CREATE INDEX IND_gameType_requiresTeams ON D_gameType(gameType_requiresTeams);
CREATE INDEX IND_gameType_updatedAt ON D_gameType(gameType_updatedAt);
CREATE INDEX IND_gameType_updatedBy ON D_gameType(gameType_updatedBy);
SELECT crsql_as_crr('D_gameType');

INSERT INTO D_gameType (
  gameType_id,
  gameType_builtIn,
  gameType_callToWin,
  gameType_lowestWins,
  gameType_createdBy,
  gameType_maxPlayers,
  gameType_maxScore,
  gameType_minPlayers,
  gameType_minScore,
  gameType_name,
  gameType_possibleCalls,
  gameType_requiresCall,
  gameType_requiresTeams
) VALUES (
    'five-hundred',
    1,
    1,
    0,
    'dFMhZwNE7JbD4bbGJEkP1',
    2,
    500,
    2,
    -500,
    'Five hundred',
    '[{"id":"6S","name":"Six spades","score":40,"tricks":6},{"id":"6C","name":"Six clubs","score":60,"tricks":6},{"id":"6D","name":"Six diamonds","score":80,"tricks":6},{"id":"6H","name":"Six hearts","score":100,"tricks":6},{"id":"6NT","name":"Six no trumps","score":120,"tricks":6},{"id":"7S","name":"Seven spades","score":140,"tricks":7},{"id":"7C","name":"Seven clubs","score":160,"tricks":7},{"id":"7D","name":"Seven diamonds","score":180,"tricks":7},{"id":"7H","name":"Seven hearts","score":200,"tricks":7},{"id":"7NT","name":"Seven no trumps","score":220,"tricks":7},{"id":"M","name":"Misere","score":250,"tricks":10},{"id":"8S","name":"Eight spades","score":240,"tricks":8},{"id":"8C","name":"Eight clubs","score":260,"tricks":8},{"id":"8D","name":"Eight diamonds","score":280,"tricks":8},{"id":"8H","name":"Eight hearts","score":300,"tricks":8},{"id":"8NT","name":"Eight no trumps","score":320,"tricks":8},{"id":"9S","name":"Nine spades","score":340,"tricks":9},{"id":"9C","name":"Nine clubs","score":360,"tricks":9},{"id":"9D","name":"Nine diamonds","score":380,"tricks":9},{"id":"9H","name":"Nine hearts","score":400,"tricks":9},{"id":"9NT","name":"Nine no trumps","score":420,"tricks":9},{"id":"10S","name":"Ten spades","score":440,"tricks":10},{"id":"10C","name":"Ten clubs","score":460,"tricks":10},{"id":"10D","name":"Ten diamonds","score":480,"tricks":10},{"id":"10H","name":"Ten hearts","score":500,"tricks":10},{"id":"10NT","name":"Ten no trumps","score":520,"tricks":10},{"id":"OM","name":"Open misere","score":500,"tricks":10}]',
    1,
    1
  ), (
    'crazy-eights',
    1,
    0,
    1,
    'dFMhZwNE7JbD4bbGJEkP1',
    0,
    0,
    2,
    -100,
    'Crazy Eights',
    null,
    0,
    0
  ), (
    'any-individual',
    1,
    0,
    0,
    'dFMhZwNE7JbD4bbGJEkP1',
    0,
    null,
    2,
    null,
    'Non-Teams game',
    null,
    0,
    0
  ), (
    'any-team',
    1,
    0,
    0,
    'dFMhZwNE7JbD4bbGJEkP1',
    0,
    null,
    2,
    null,
    'Teams game',
    null,
    0,
    1
  );


-- =====================================================
-- replicated/synced


CREATE TABLE IF NOT EXISTS D_gameData (
  gameData_id CHAR(21) NOT NULL,
  gameData_createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gameData_createdBy CHAR(21) NOT NULL,
  gameData_endedAt TIMESTAMP DEFAULT NULL,
  gameData_forced BOOLEAN NOT NULL DEFAULT 0,
  gameData_gameTypeID CHAR(21) NOT NULL,
  gameData_gameStateID TINYINT(3) DEFAULT 0,
  gameData_lead BLOB NOT NULL DEFAULT NULL,
  gameData_locked BOOLEAN NOT NULL DEFAULT 0,
  gameData_looser CHAR(21) DEFAULT NULL,
  gameData_nextTurn TINYINT(3) DEFAULT NULL,
  gameData_permissionsModeID TINYINT(3) DEFAULT 0,
  gameData_playTime INT(8) DEFAULT 0,
  gameData_startedAt TIMESTAMP DEFAULT NULL,
  gameData_teams BOOLEAN NOT NULL DEFAULT 0,
  gameData_winner CHAR(21) DEFAULT NULL,
  gameData_updatedAt TIMESTAMP DEFAULT NULL,
  gameData_updatedBy CHAR(21) DEFAULT NULL,
  PRIMARY KEY (gameData_id),
  FOREIGN KEY(gameData_createdBy) REFERENCES D_players(player_id),
  FOREIGN KEY(gameData_updatedBy) REFERENCES D_players(player_id),
  FOREIGN KEY(gameData_gameTypeID) REFERENCES D_gameType(gameType_id),
  FOREIGN KEY(gameData_gameStateID) REFERENCES E_gameStates(gameState_id),
  FOREIGN KEY(gameData_permissionsModeID) REFERENCES E_gamePermissionsModes(gamePermissionsMode_id)
);
CREATE INDEX IND_gameData_createdAt ON D_gameData(gameData_createdAt);
CREATE INDEX IND_gameData_createdBy ON D_gameData(gameData_createdBy);
CREATE INDEX IND_gameData_endedAt ON D_gameData(gameData_endedAt);
CREATE INDEX IND_gameData_forced ON D_gameData(gameData_forced);
CREATE INDEX IND_gameData_gameTypeID ON D_gameData(gameData_gameTypeID);
CREATE INDEX IND_gameData_gameStateID ON D_gameData(gameData_gameStateID);
CREATE INDEX IND_gameData_locked ON D_gameData(gameData_locked);
CREATE INDEX IND_gameData_playTime ON D_gameData(gameData_playTime);
CREATE INDEX IND_gameData_startedAt ON D_gameData(gameData_startedAt);
CREATE INDEX IND_gameData_teams ON D_gameData(gameData_teams);
CREATE INDEX IND_gameData_winner ON D_gameData(gameData_winner);
SELECT crsql_as_crr('D_gameData');


-- =====================================================
-- replicated/synced


CREATE TABLE IF NOT EXISTS D_playerScores (
  playerScore_id CHAR(21) NOT NULL,
  playerScore_call VARCHAR(32) DEFAULT NULL, -- For call based games this is the call the player made at the start of the round
  playerScore_createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  playerScore_createdBy CHAR(21) NOT NULL,
  playerScore_gameID CHAR(21) NOT NULL,
  playerScore_gameTypeID CHAR(21) NOT NULL,
  playerScore_overallRank TINYINT(3) NOT NULL, -- Where the player sits (in this round) relative to the total scores of all players
  playerScore_highlight TINYINT(3) NOT NULL DEFAULT 0, -- Sometimes you want to mark scores as important for later. (0 = unimportant, 1 = important for good reasons, -1 = important for bad reasons)
  playerScore_isLead BOOLEAN DEFAULT NULL,
  playerScore_notes VARCHAR(255) DEFAULT NULL, -- sometimes it's useful to record notes about a particular score (especially if it's contentious)
  playerScore_pending BOOLEAN NOT NULL DEFAULT 0, -- when game is in "Control freak" mode a non-owner player adds or updates a score the score is marked pending until the owner approves the score. NOTE: if all scores for the next round are added, previous "pending" scores are marked as approved.
  playerScore_playerID CHAR(21) DEFAULT NULL, -- ID of player score applies to. Is `NULL` when scoring teams based games
  playerScore_round TINYINT(3) NOT NULL,
  playerScore_roundRank TINYINT(3) NOT NULL, -- Players rank for this round alone
  playerScore_score INT NOT NULL, -- score at the end of the round (for call based games this starts out at zero)
  playerScore_scoreIsFinal BOOLEAN DEFAULT 0, -- The final score for this player
  playerScore_teamID CHAR(21) DEFAULT NULL, -- ID of team score applies to. Is `NULL` when scoring individual player games.
  playerScore_updatedAt TIMESTAMP DEFAULT NULL,
  playerScore_updatedBy CHAR(21) DEFAULT NULL,
  PRIMARY KEY (playerScore_id),
  FOREIGN KEY(playerScore_createdBy) REFERENCES D_players(player_id),
  FOREIGN KEY(playerScore_gameID) REFERENCES D_gameData(gameData_id),
  FOREIGN KEY(playerScore_gameTypeID) REFERENCES D_gameType(gameType_id),
  FOREIGN KEY(playerScore_playerID) REFERENCES D_players(player_id),
  FOREIGN KEY(playerScore_teamID) REFERENCES D_teams(team_id),
  FOREIGN KEY(playerScore_updatedBy) REFERENCES D_players(player_id)
);

CREATE UNIQUE INDEX UNI_gamePlayerRound ON D_playerScores(
  playerScore_gameID,
  playerScore_playerID,
  playerScore_round,
  playerScore_teamID
);
CREATE INDEX IND_playerScore_gameID ON D_playerScores(playerScore_gameID);
CREATE INDEX IND_playerScore_playerID ON D_playerScores(playerScore_playerID);
CREATE INDEX IND_playerScore_teamID ON D_playerScores(playerScore_teamID);
CREATE INDEX IND_playerScore_scoreIsFinal ON D_playerScores(
  playerScore_gameID,
  playerScore_scoreIsFinal
);
CREATE INDEX IND_playerScore_gameRound ON D_playerScores(
  playerScore_gameID,
  playerScore_round
);
CREATE INDEX IND_playerScore_playerGameType ON D_playerScores(
  playerScore_playerID,
  playerScore_gameTypeID
);
CREATE INDEX IND_playerScore_playerGameTypeRank ON D_playerScores(
  playerScore_playerID,
  playerScore_gameTypeID,
  playerScore_scoreIsFinal,
  playerScore_overallRank
);
CREATE INDEX IND_playerScore_teamGameType ON D_playerScores(
  playerScore_teamID,
  playerScore_gameTypeID
);
CREATE INDEX IND_playerScore_teamGameTypeRank ON D_playerScores(
  playerScore_teamID,
  playerScore_gameTypeID,
  playerScore_scoreIsFinal,
  playerScore_overallRank
);
SELECT crsql_as_crr('D_playerScores');


-- =====================================================
-- replicated/synced


CREATE TABLE IF NOT EXISTS D_teams (
  team_id CHAR(21) NOT NULL,
  team_blocked BOOLEAN NOT NULL DEFAULT 0,
  team_createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  team_createdBy CHAR(21) NOT NULL,
  team_memberCount INTEGER NOT NULL,
  team_name VARCHAR(32) NOT NULL,
  team_normalisedName VARCHAR(64) NOT NULL,
  team_updatedAt TIMESTAMP DEFAULT NULL,
  team_updatedBy CHAR(21) DEFAULT NULL,
  PRIMARY KEY (team_id),
  FOREIGN KEY(team_createdBy) REFERENCES D_players(player_id),
  FOREIGN KEY(team_updatedBy) REFERENCES D_players(player_id)
);
CREATE UNIQUE INDEX UNI_team_normalisedName ON D_teams(team_normalisedName);
CREATE UNIQUE INDEX UNI_team_name ON D_teams(team_name);
CREATE INDEX IND_team_blocked ON D_teams(team_blocked);
CREATE INDEX IND_team_createdAt ON D_teams(team_createdAt);
CREATE INDEX IND_team_createdBy ON D_teams(team_createdBy);
CREATE INDEX IND_team_memberCount ON D_teams(team_memberCount);
CREATE INDEX IND_team_updatedAt ON D_teams(team_updatedAt);
CREATE INDEX IND_team_updatedBy ON D_teams(team_updatedBy);
SELECT crsql_as_crr('D_teams');


-- =====================================================
-- replicated/synced


CREATE TABLE IF NOT EXISTS J_playerTeam (
  playerTeam_id CHAR(21) NOT NULL,
  playerTeam_playerID CHAR(21) NOT NULL,
  playerTeam_teamID CHAR(21) NOT NULL,
  playerTeam_position TINYINT(3) NOT NULL,
  PRIMARY KEY (playerTeam_id),
  FOREIGN KEY(playerTeam_teamID) REFERENCES D_teams(team_id),
  FOREIGN KEY(playerTeam_playerID) REFERENCES D_players(player_id)
);
CREATE UNIQUE INDEX UNI_teamPlayer ON J_playerTeam(playerTeam_teamID, playerTeam_playerID);
CREATE UNIQUE INDEX UNI_teamPosition ON J_playerTeam(playerTeam_teamID, playerTeam_position);
CREATE INDEX IND_playerTeam_playerID ON J_playerTeam(playerTeam_playerID);
CREATE INDEX IND_playerTeam_teamID ON J_playerTeam(playerTeam_teamID);
SELECT crsql_as_crr('J_playerTeam');


-- =====================================================
-- replicated/synced


CREATE TABLE IF NOT EXISTS J_playerGame (
  playerGame_id CHAR(21) NOT NULL,
  playerGame_canAddOthersScore TINYINT(3) NOT NULL DEFAULT 0, -- Player can update their own scores
  playerGame_canAddOwnScore TINYINT(3) NOT NULL DEFAULT 0, -- Player can update their own scores
  playerGame_canUpdateOthersScore TINYINT(3) NOT NULL DEFAULT 0, -- Player can update any score
  playerGame_canUpdateOwnScore TINYINT(3) NOT NULL DEFAULT 0, -- Player can update their own scores
  playerGame_gameID CHAR(21) NOT NULL,
  playerGame_gameTypeID CHAR(21) NOT NULL,
  playerGame_order TINYINT(3) NOT NULL, -- Order the player plays in each round
  playerGame_playerID CHAR(21) NOT NULL,
  playerGame_teamID CHAR(21) DEFAULT NULL, -- only used for teams based games
  PRIMARY KEY (playerGame_id),
  FOREIGN KEY(playerGame_gameID) REFERENCES D_gameData(gameData_id),
  FOREIGN KEY(playerGame_gameTypeID) REFERENCES D_gameType(gameType_id),
  FOREIGN KEY(playerGame_playerID) REFERENCES D_players(player_id),
  FOREIGN KEY(playerGame_teamID) REFERENCES D_teams(team_id)
  FOREIGN KEY(playerGame_canAddOthersScore) REFERENCES E_scoreControlModes(scoreControlMode_id)
  FOREIGN KEY(playerGame_canAddOwnScore) REFERENCES E_scoreControlModes(scoreControlMode_id)
  FOREIGN KEY(playerGame_canUpdateOthersScore) REFERENCES E_scoreControlModes(scoreControlMode_id)
  FOREIGN KEY(playerGame_canUpdateOwnScore) REFERENCES E_scoreControlModes(scoreControlMode_id)
);
CREATE UNIQUE INDEX UNI_gamePlayer ON J_playerGame(
  playerGame_gameID,
  playerGame_playerID
);
CREATE UNIQUE INDEX UNI_gameOrder ON J_playerGame(
  playerGame_gameID,
  playerGame_order
);
CREATE INDEX IND_gamePlayer ON J_playerGame(playerGame_playerID);
CREATE INDEX IND_gameTeam ON J_playerGame(playerGame_teamID);
CREATE INDEX IND_gameType ON J_playerGame(playerGame_gameTypeID);
CREATE INDEX IND_gameTypePlayer ON J_playerGame(
  playerGame_gameTypeID,
  playerGame_playerID
);
CREATE INDEX IND_gameTypeTeam ON J_playerGame(
  playerGame_gameTypeID,
  playerGame_teamID
);
CREATE INDEX IND_gameOrder ON J_playerGame(
  playerGame_playerID,
  playerGame_order
);
SELECT crsql_as_crr('J_playerGame');


-- =====================================================


INSERT INTO D_players (
  player_id,
  player_typeID,
  player_givenName,
  player_nickname,
  player_familyName,
  player_normalisedName,
  player_createdBy
) VALUES (
    'YyRmxJU82fNXOFg0K0CnV',
    2,
    'Evan',
    'Evan',
    'Wills',
    'evanwills',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'F1tufg45ne9NqpOOb4uQU',
    3,
    'Georgina',
    'Georgie',
    'Pike',
    'georginapikegeorgie',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'VMcDDSw048oIXUnG64_6Y',
    4,
    'Mallee',
    'Mallee',
    'Pike Wills',
    'malleepikewills',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'Qhlw1t90rAtH3CVmCHZa8',
    3,
    'Ada',
    'Ada',
    'Pike Wills',
    'adapikewills',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'mBZ8CFx8CMzHfdenibbL3',
    4,
    'Carmel',
    'Carmel',
    'Pike',
    'carmelpike',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'OEIT7nZAvV__5jgLK4CRH',
    3,
    'Jessica',
    'Jess',
    'Pike',
    'jessicapike',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'IC5L-1P9zQbTXxGP9gEvE',
    3,
    'Stuart',
    'Stu',
    'Pike',
    'stuartpike',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '1EvqXuAOfw-16R2LGytKU',
    3,
    'Katie',
    'Katie',
    'Pike',
    'katiepike',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'Q6WE6u8xUTKDlBHwva_K_',
    3,
    'Allison',
    'Ally',
    'Burg',
    'allisonburgally',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'J8Hvt0sC20FqAVvou7Q03',
    3,
    'Matt',
    'Matt',
    'Burg',
    'mattburg',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'RevBvfcP_-NaWDMfH8QIy',
    3,
    'Marlo',
    'Marlo',
    'Thompson',
    'marlothompson',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '9k2PYQu98XE2e85ehrJMR',
    4,
    'James',
    'James',
    'Pike',
    'jamespike',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'XkRMIlGmBdVAi04lz1bNi',
    4,
    'Archi',
    'Archi',
    'Pike',
    'archipike',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '5hLOZtWjWnnD0aZPavGBH',
    4,
    'Ellanor',
    'Ella',
    'Pike',
    'ellanorpike',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'j4tPZ2N9V4NSNVQh34cRK',
    4,
    'Leo',
    'Leo',
    'Burg',
    'leoburg',
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'QMA1Y6J9HG0QdkRJ-oF56',
    4,
    'Daisy',
    'Daisy',
    'Burg',
    'daisyburg',
    'YyRmxJU82fNXOFg0K0CnV'
  );

INSERT INTO D_teams (
  team_id,
  team_name,
  team_normalisedName,
  team_memberCount,
  team_createdBy
) VALUES (
    '3o20hCz7n11TRcgoXvrbY',
    'Evan & Georgie',
    'evangeorgina',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'g43hS4O2rgRXT1Bkbe3Zm',
    'Evan & Mallee',
    'evanmallee',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'pZNnB4Dyl5C_j4cXxHfNy',
    'Evan & Ada',
    'evanada',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'N69cNq-MApePtn-u_vNVJ',
    'Evan & Carmel',
    'evancarmel',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'HR4_Jr6aTynUE3KCdJ_0I',
    'Evan & Jess',
    'evanjessica',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'TkTrXydvR8MU_ZG02ve4-',
    'Evan & Stu',
    'evanstuart',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'vtHL4i5XjTkwuZl0tfM0p',
    'Evan & Katie',
    'evankatie',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'mzqIvzzI4-S__iNl8kCyo',
    'Evan & Ally',
    'evanallison',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'FYP4V-H-EftoS45cjL2Gv',
    'Evan & Matt',
    'evanmatt',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'ehM8f8P6Clg5gZAPIyITE',
    'Evan & Marlo',
    'evanmarlo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'lI-VZYSOw4vyB1dsU0E-f',
    'Evan & James',
    'evanjames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'kMYrIJAux8qTgO05ANTPg',
    'Evan & Archi',
    'evanarchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'ZZdAuuLZL7InGyp-3nbta',
    'Evan & Ella',
    'evanellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'aplFkcfBTIr4gM4pFGkt4',
    'Evan & Leo',
    'evanleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '02zgHDqZ-ZO4YqaXlt2By',
    'Evan & Daisy',
    'evandaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '9gQLxIR4We9EmrSELja41',
    'Georgie & Mallee',
    'georginamallee',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'BwKEJEPDqGm2taPioaVUu',
    'Georgie & Ada',
    'georginaada',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '2XQiMDSE_nriMjEtGsgnk',
    'Georgie & Carmel',
    'georginacarmel',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'LJMmvqaKH4hLsDoQEQut_',
    'Georgie & Jess',
    'georginajessica',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'flIJzJZIqbmKpByhuYagr',
    'Georgie & Stu',
    'georginastuart',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'wEV8DfyCrL85cytDY5OCB',
    'Georgie & Katie',
    'georginakatie',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'c24sFhSzlE5JXBq8AyGaw',
    'Georgie & Ally',
    'georginaallison',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'Q1qMj99wDsi-9fDrUibtC',
    'Georgie & Matt',
    'georginamatt',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'GXOtzUfqQf6M4gea0q2PF',
    'Georgie & Marlo',
    'georginamarlo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'cQH-nk7W-Ux2SFZudl0X2',
    'Georgie & James',
    'georginajames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'O3tyrx8_dPZ2vTquhlQhK',
    'Georgie & Archi',
    'georginaarchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'dPG1rTS3C5KMA90dgn0Pa',
    'Georgie & Ella',
    'georginaellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'px4L5KVpvutyXr852WxJh',
    'Georgie & Leo',
    'georginaleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'pD3U0JSLKkYhqIQDPi1Dz',
    'Georgie & Daisy',
    'georginadaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'iaiEnLZWxubKrgHmFfYTf',
    'Mallee & Ada',
    'malleeada',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'e1dbpaB-kRJbBWXRblxeq',
    'Mallee & Carmel',
    'malleecarmel',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'Jg64q66QFPndqxshmgcml',
    'Mallee & Jess',
    'malleejessica',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'WrfaJtzN1XTnbmoaZyj2x',
    'Mallee & Stu',
    'malleestuart',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'eLBpMGmevHqMDdRERD1KY',
    'Mallee & Katie',
    'malleekatie',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '8j5EUJruhvizyrrizSH2n',
    'Mallee & Ally',
    'malleeallison',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'cIxXTHyb3Jbu_yuuukCu8',
    'Mallee & Matt',
    'malleematt',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '_S44cnoXpuDGfEaBvzBWZ',
    'Mallee & Marlo',
    'malleemarlo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'RQXUs63cDWiJTlM1-YmEg',
    'Mallee & James',
    'malleejames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'oonqtQSiyKgjd3ljhhoKt',
    'Mallee & Archi',
    'malleearchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'UFzr6pl6jk72-WR43oPh0',
    'Mallee & Ella',
    'malleeellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'Fc4vG728FNjo9qOJ9DP_f',
    'Mallee & Leo',
    'malleeleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'OGHG9ZhiAjHZ7G4zLxeUc',
    'Mallee & Daisy',
    'malleedaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'aQXcTNzehFzaukpBhA4M1',
    'Ada & Carmel',
    'adacarmel',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'GQ1Gjntx2c-NBwNVaJEbY',
    'Ada & Jess',
    'adajessica',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'i2m6i0cIQAnVWuMB1YaQu',
    'Ada & Stu',
    'adastuart',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'pTUMnuml7itADMPbpao0W',
    'Ada & Katie',
    'adakatie',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'kC4DMqkW-mAsthIlf1js3',
    'Ada & Ally',
    'adaallison',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'qzt_YVQhDDv6E0otNm6BD',
    'Ada & Matt',
    'adamatt',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'stIwfdlUa0Im8Z5BTfAN_',
    'Ada & Marlo',
    'adamarlo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'DST3zhRR1MelAj9-6rdmI',
    'Ada & James',
    'adajames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'HDeQXbWIzhDE5NzzKTBYJ',
    'Ada & Archi',
    'adaarchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '0ylUKXApxUVCHY8NI3-Ll',
    'Ada & Ella',
    'adaellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'F8CwFeqnEyMOY_IztUK6_',
    'Ada & Leo',
    'adaleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'n9OQHEPlFL3kNandL21zZ',
    'Ada & Daisy',
    'adadaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'VVShmZ9UG5I1PYo4vE9T-',
    'Carmel & Jess',
    'carmeljessica',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '_BUp6ff6Uo-IUZ9CRXcW7',
    'Carmel & Stu',
    'carmelstuart',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'iROelMQuMpmgnZ-Nz1EqP',
    'Carmel & Katie',
    'carmelkatie',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'nQXEbtIFRKyOncJQRvaKZ',
    'Carmel & Ally',
    'carmelallison',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '3L0N1VQiM_08Jm9xO0WVt',
    'Carmel & Matt',
    'carmelmatt',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'zwCr29m1Or_x8r1MdyMkS',
    'Carmel & Marlo',
    'carmelmarlo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'HDloM6rz42i2qPCH_khwq',
    'Carmel & James',
    'carmeljames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'CXHytdB2_Vh2UxbuukySo',
    'Carmel & Archi',
    'carmelarchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '9680gdSOmWB2nx8f2mTgy',
    'Carmel & Ella',
    'carmelellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '5Epk1aiX-Ukk-CrJCEgTu',
    'Carmel & Leo',
    'carmelleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'P_L4801wL1ekj8XkYJFx2',
    'Carmel & Daisy',
    'carmeldaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'kwOkAEknBqTvIwVO3kHC5',
    'Jess & Stu',
    'jessicastuart',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'CzWWBbVxynchowRCzxoD7',
    'Jess & Katie',
    'jessicakatie',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'HPQrHXc5ZZ2iMT6wjLBfs',
    'Jess & Ally',
    'jessicaallison',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'xvRSAXTjWtpVF1I731qiS',
    'Jess & Matt',
    'jessicamatt',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'I_FTiYrhAKht4bVJtb6tb',
    'Jess & Marlo',
    'jessicamarlo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '93o9bZYOr5-PlD6yySW1f',
    'Jess & James',
    'jessicajames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'iw1FxWVUckEbJoDpr8y89',
    'Jess & Archi',
    'jessicaarchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'TXJKLyaGYGPlK0TAOFEV5',
    'Jess & Ella',
    'jessicaellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'MOfrXVO1xcX52bs1LkfF0',
    'Jess & Leo',
    'jessicaleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'beX3gTdsR4HsbhUYhfhj2',
    'Jess & Daisy',
    'jessicadaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'SW_0zAafk6ZcqkbjhXGZz',
    'Stu & Katie',
    'stuartkatie',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'yDq-2fkJcnabQKmrbOwbX',
    'Stu & Ally',
    'stuartallison',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'jmaqvw7MPuzBEh9yarYrY',
    'Stu & Matt',
    'stuartmatt',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'lnaeQIzAJjz45xv8_IqR3',
    'Stu & Marlo',
    'stuartmarlo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '2WCR-Q_4F_yxFxxcDjQog',
    'Stu & James',
    'stuartjames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '33Cg23eqxdlyoK6gA9U2r',
    'Stu & Archi',
    'stuartarchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'SdoANgIFy-G4yHfm2AP1B',
    'Stu & Ella',
    'stuartellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '2LSqqrcoKK5bUQHH5KtgU',
    'Stu & Leo',
    'stuartleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'qJKavm4RnqgResT7Psy6w',
    'Stu & Daisy',
    'stuartdaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'IVT-0CdCEq5QmfSXeiZn8',
    'Katie & Ally',
    'katieallison',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'KI_gTgNZgdvMKMLJZv47f',
    'Katie & Matt',
    'katiematt',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'zgvExdjpKAZ45HHqY-NcB',
    'Katie & Marlo',
    'katiemarlo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'MeugDe8c3wlnLQ2wXbtQr',
    'Katie & James',
    'katiejames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'wgl57oUuDPGaENRk82b8y',
    'Katie & Archi',
    'katiearchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'pZEvRCsXpsqJJ0K5rsiCM',
    'Katie & Ella',
    'katieellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'w51asMt1vdlctMFRJwjVD',
    'Katie & Leo',
    'katieleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'bik49RBSlW_0b2eEd6en3',
    'Katie & Daisy',
    'katiedaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'sZXD2vYondnn2ZRqtDYN1',
    'Ally & Matt',
    'allisonmatt',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'eS-7distNGXriSbTh6ZP3',
    'Ally & Marlo',
    'allisonmarlo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '82hCVe02CZZZ7oqVvGNMz',
    'Ally & James',
    'allisonjames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'LjJbyn-2ZwqnzP8WBS_SI',
    'Ally & Archi',
    'allisonarchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'UbKXgVvMqvDUFF9kAvgWX',
    'Ally & Ella',
    'allisonellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'A9BF_qeXFG4IySzn6FVX4',
    'Ally & Leo',
    'allisonleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'IpWAW2XMesDwJ_M6qIZNb',
    'Ally & Daisy',
    'allisondaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'xdmUWTR1KaDvv5LhB6gqw',
    'Matt & Marlo',
    'mattmarlo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '9S-zXqGNHUWS9VkzDd-yP',
    'Matt & James',
    'mattjames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'cznIk1WCJ9lsOj31MaRwk',
    'Matt & Archi',
    'mattarchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'CZWlWFaMeudAhZepE8wAo',
    'Matt & Ella',
    'mattellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'kPex2ye3ewrSjKPSbaONX',
    'Matt & Leo',
    'mattleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '1KlNbo-ZmFGzFVeK214_g',
    'Matt & Daisy',
    'mattdaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '1FlDMxhrsxwaov37R2NAI',
    'Marlo & James',
    'marlojames',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '9gFCsYhaHI-tQ7_U73DB4',
    'Marlo & Archi',
    'marloarchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'wezUNNXzHvzMDTtGLeesj',
    'Marlo & Ella',
    'marloellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'Fxmw2LsP-3c9RtQaN4Bhq',
    'Marlo & Leo',
    'marloleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'LF1zqwyIz146ZPu7aeyRT',
    'Marlo & Daisy',
    'marlodaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'VhnlAEte22tF4btdKVaqJ',
    'James & Archi',
    'jamesarchi',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'aXdmf0kH2OtarmClA0D9N',
    'James & Ella',
    'jamesellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'zE5zO-8osuvL8QOw4-eIR',
    'James & Leo',
    'jamesleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'BkXFskuf63FfRBrikLvuf',
    'James & Daisy',
    'jamesdaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'GtyKso8Y4QPv3mGMfMlh1',
    'Archi & Ella',
    'archiellanor',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'HKqphFIgIX6sv1fcYuc6W',
    'Archi & Leo',
    'archileo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    '3mO7ZXrQBLlrxEMYi0TwR',
    'Archi & Daisy',
    'archidaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'K2hmFYSYATWyPCQLFmGPF',
    'Ella & Leo',
    'ellanorleo',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'tn7_5WEOmmrEiU6FOJe_z',
    'Ella & Daisy',
    'ellanordaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  ), (
    'jGKvjIHsTtyu9lmohCyOI',
    'Leo & Daisy',
    'leodaisy',
    2,
    'YyRmxJU82fNXOFg0K0CnV'
  );

INSERT INTO J_playerTeam (
  playerTeam_id,
  playerTeam_teamID,
  playerTeam_playerID,
  playerTeam_position
) VALUES (
    'RJZfkX9XSr0EZ4YW2PjbS',
    '3o20hCz7n11TRcgoXvrbY',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'WAj3ifngcL5WKmg2qh9qp',
    '3o20hCz7n11TRcgoXvrbY',
    'F1tufg45ne9NqpOOb4uQU',
    2
  ), (
    're3aIL9wHu1wmT8BcW9wo',
    'g43hS4O2rgRXT1Bkbe3Zm',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'UKbvXTRoGwHGV-9QHoiq6',
    'g43hS4O2rgRXT1Bkbe3Zm',
    'VMcDDSw048oIXUnG64_6Y',
    2
  ), (
    '3EEhrou215-LUf1VZlCPM',
    'pZNnB4Dyl5C_j4cXxHfNy',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'k74aOZu0diO3SvHCzfvw3',
    'pZNnB4Dyl5C_j4cXxHfNy',
    'Qhlw1t90rAtH3CVmCHZa8',
    2
  ), (
    'Q0VemegrCuQSG6y3YZKLt',
    'N69cNq-MApePtn-u_vNVJ',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    '5h7Xk4ccOSa8lqF-SXG5r',
    'N69cNq-MApePtn-u_vNVJ',
    'mBZ8CFx8CMzHfdenibbL3',
    2
  ), (
    '7v2blXRppNkr9sCtMaZ2b',
    'HR4_Jr6aTynUE3KCdJ_0I',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'pk_lo01nFgHCSsZ1KC4PG',
    'HR4_Jr6aTynUE3KCdJ_0I',
    'OEIT7nZAvV__5jgLK4CRH',
    2
  ), (
    'Sdd7LVKlMiSlNQBQLxt6i',
    'TkTrXydvR8MU_ZG02ve4-',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'L0IUav4TZxxEW4T3GKvrp',
    'TkTrXydvR8MU_ZG02ve4-',
    'IC5L-1P9zQbTXxGP9gEvE',
    2
  ), (
    'qFb7p_VsYTs6NfZA5m9mF',
    'vtHL4i5XjTkwuZl0tfM0p',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'i1zs5_H2DR3oV_WSP3VYD',
    'vtHL4i5XjTkwuZl0tfM0p',
    '1EvqXuAOfw-16R2LGytKU',
    2
  ), (
    '9IHaUDv4qYK2oQqtWJSdW',
    'mzqIvzzI4-S__iNl8kCyo',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    '825iJPtPZmYsg8S84_6ck',
    'mzqIvzzI4-S__iNl8kCyo',
    'Q6WE6u8xUTKDlBHwva_K_',
    2
  ), (
    'SL8kpJ_xe0nfDAbX8OlZd',
    'FYP4V-H-EftoS45cjL2Gv',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'gWSoc4PQtXoNvNEgJ9r0F',
    'FYP4V-H-EftoS45cjL2Gv',
    'J8Hvt0sC20FqAVvou7Q03',
    2
  ), (
    'P6MNQ1dmhKqjuH-mOY2ER',
    'ehM8f8P6Clg5gZAPIyITE',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'YKjQnjKpUVE39T9KJ_pN9',
    'ehM8f8P6Clg5gZAPIyITE',
    'RevBvfcP_-NaWDMfH8QIy',
    2
  ), (
    'zpiw3PPuGdHCjS0PTFMX3',
    'lI-VZYSOw4vyB1dsU0E-f',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'eGxLuQUMXIzK8nJL8Dbaa',
    'lI-VZYSOw4vyB1dsU0E-f',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    'XryyE5reJOTeW5IbmxQJp',
    'kMYrIJAux8qTgO05ANTPg',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'jM4qZo_hO1sofwiAwE9yk',
    'kMYrIJAux8qTgO05ANTPg',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    '60ywujdBDMoURRiuiAGmZ',
    'ZZdAuuLZL7InGyp-3nbta',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'qVQg29jeEzXaXQ-sZ3E8n',
    'ZZdAuuLZL7InGyp-3nbta',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'cagud6XbwouvYvQUNwcIV',
    'aplFkcfBTIr4gM4pFGkt4',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'e3pj8ZOKimOVMzZOrsRpT',
    'aplFkcfBTIr4gM4pFGkt4',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'aM369NwhfIy_6aJL1fmtX',
    '02zgHDqZ-ZO4YqaXlt2By',
    'YyRmxJU82fNXOFg0K0CnV',
    1
  ), (
    'e0VhLiDzW5rtjWQBYAI_G',
    '02zgHDqZ-ZO4YqaXlt2By',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'sqPjQxT7xoYMqIIKuc_6V',
    '9gQLxIR4We9EmrSELja41',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'op5PxzzKp8-DrLTZXm5Pk',
    '9gQLxIR4We9EmrSELja41',
    'VMcDDSw048oIXUnG64_6Y',
    2
  ), (
    'NB3cFHEupxvFOPs54ZhEz',
    'BwKEJEPDqGm2taPioaVUu',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'GToxhoYk6ksqQ0ORKK_Vv',
    'BwKEJEPDqGm2taPioaVUu',
    'Qhlw1t90rAtH3CVmCHZa8',
    2
  ), (
    'PcCoOmG4OqCgI4T_gKhBH',
    '2XQiMDSE_nriMjEtGsgnk',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    '4ollJk1HytErZ7JGQsOWl',
    '2XQiMDSE_nriMjEtGsgnk',
    'mBZ8CFx8CMzHfdenibbL3',
    2
  ), (
    'oyyUEJxehOb1UP-NvJie9',
    'LJMmvqaKH4hLsDoQEQut_',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'VofbjkerM1VaQaaWfbbJ6',
    'LJMmvqaKH4hLsDoQEQut_',
    'OEIT7nZAvV__5jgLK4CRH',
    2
  ), (
    'zVcGEuXGDNz3-faiTYHsn',
    'flIJzJZIqbmKpByhuYagr',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'cY9AucJxSIa56BMw-qDgk',
    'flIJzJZIqbmKpByhuYagr',
    'IC5L-1P9zQbTXxGP9gEvE',
    2
  ), (
    'O95V4uSAcr6ePnyro8lZ3',
    'wEV8DfyCrL85cytDY5OCB',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'd8MMQeexr_iktDq3b2DHp',
    'wEV8DfyCrL85cytDY5OCB',
    '1EvqXuAOfw-16R2LGytKU',
    2
  ), (
    'iprJIEEi-JGTFTcMLKT5-',
    'c24sFhSzlE5JXBq8AyGaw',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'OleYY6l1cC8O0za6puPS5',
    'c24sFhSzlE5JXBq8AyGaw',
    'Q6WE6u8xUTKDlBHwva_K_',
    2
  ), (
    'NL01dI4-_GFCe-S3h_oUr',
    'Q1qMj99wDsi-9fDrUibtC',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'AfO_cyEftTM2Wylphc8qF',
    'Q1qMj99wDsi-9fDrUibtC',
    'J8Hvt0sC20FqAVvou7Q03',
    2
  ), (
    'HeXsmk3sF_4utKpx-7m1G',
    'GXOtzUfqQf6M4gea0q2PF',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'GZDCveNjRElm34aOQBldo',
    'GXOtzUfqQf6M4gea0q2PF',
    'RevBvfcP_-NaWDMfH8QIy',
    2
  ), (
    'M52e6t6eioJYhsLhFQ1p1',
    'cQH-nk7W-Ux2SFZudl0X2',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'SMQ_ixsxJJLUatcQiX9vR',
    'cQH-nk7W-Ux2SFZudl0X2',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    'y3pLeZ3vzkiZ4MT1uzIBY',
    'O3tyrx8_dPZ2vTquhlQhK',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'E2251RB_18Z3cQfNbxzbv',
    'O3tyrx8_dPZ2vTquhlQhK',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    '4d6XxImmj2wSgfWRKDsmr',
    'dPG1rTS3C5KMA90dgn0Pa',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'wW-2cPrxpGT-l5Umkt0z0',
    'dPG1rTS3C5KMA90dgn0Pa',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'iRaBOhJsZauj16Huo-keY',
    'px4L5KVpvutyXr852WxJh',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'WOkj7N_KdCUCOFD2Gnf0T',
    'px4L5KVpvutyXr852WxJh',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'Y1fkeFR82kV0FbdNL4uck',
    'pD3U0JSLKkYhqIQDPi1Dz',
    'F1tufg45ne9NqpOOb4uQU',
    1
  ), (
    'juoWu5WfZgLrm9YwKqUCN',
    'pD3U0JSLKkYhqIQDPi1Dz',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'jq15qXQ0nqgutuNMJ9NPu',
    'iaiEnLZWxubKrgHmFfYTf',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    'gGvuqEKY727rpepkGbmIS',
    'iaiEnLZWxubKrgHmFfYTf',
    'Qhlw1t90rAtH3CVmCHZa8',
    2
  ), (
    'lhPW7KMxd_dOZ_oVj-7pu',
    'e1dbpaB-kRJbBWXRblxeq',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    'UgivD_LlpNCr8EiyFuBVi',
    'e1dbpaB-kRJbBWXRblxeq',
    'mBZ8CFx8CMzHfdenibbL3',
    2
  ), (
    'HMavw3zRzz0NLu_DeaYen',
    'Jg64q66QFPndqxshmgcml',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    'Ky5VNzbfskr7jtNSNWKBM',
    'Jg64q66QFPndqxshmgcml',
    'OEIT7nZAvV__5jgLK4CRH',
    2
  ), (
    'wNTss-QU4_g6IRBFjE_wi',
    'WrfaJtzN1XTnbmoaZyj2x',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    'HgY_w4HecFpgbU9u6taHA',
    'WrfaJtzN1XTnbmoaZyj2x',
    'IC5L-1P9zQbTXxGP9gEvE',
    2
  ), (
    'y4FJDBwML3gA7D-YXDhiA',
    'eLBpMGmevHqMDdRERD1KY',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    '4Tv-VdehG0FljEvkJ0SHv',
    'eLBpMGmevHqMDdRERD1KY',
    '1EvqXuAOfw-16R2LGytKU',
    2
  ), (
    '5RsQ79iHQFVAu21xFgaLC',
    '8j5EUJruhvizyrrizSH2n',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    'UqHHfQakUR6ppHOWTh5c3',
    '8j5EUJruhvizyrrizSH2n',
    'Q6WE6u8xUTKDlBHwva_K_',
    2
  ), (
    'LZfSFeWRcUtlRhw8mEIaG',
    'cIxXTHyb3Jbu_yuuukCu8',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    '5XPO1EyQo46JjTZdrh0KT',
    'cIxXTHyb3Jbu_yuuukCu8',
    'J8Hvt0sC20FqAVvou7Q03',
    2
  ), (
    'dL4vGRBj6PdGet7Ou11o0',
    '_S44cnoXpuDGfEaBvzBWZ',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    '5krz_dwqQsDyo6HGLUiHI',
    '_S44cnoXpuDGfEaBvzBWZ',
    'RevBvfcP_-NaWDMfH8QIy',
    2
  ), (
    'WL59muuHhMIt6L-cF3kLP',
    'RQXUs63cDWiJTlM1-YmEg',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    '6cYoMi-ses7biQOIgkjMH',
    'RQXUs63cDWiJTlM1-YmEg',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    'K1sotnhLrRqfci8hTu8IE',
    'oonqtQSiyKgjd3ljhhoKt',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    'g4iPkXT0R0S4ageP0y7DB',
    'oonqtQSiyKgjd3ljhhoKt',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    '0wsaVPIGKPZvRM1zT5vBN',
    'UFzr6pl6jk72-WR43oPh0',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    'z_D6dgYlRhXg3QZhcqQmC',
    'UFzr6pl6jk72-WR43oPh0',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'aydtQJWxfZyH7ohQFnQRL',
    'Fc4vG728FNjo9qOJ9DP_f',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    '0tMoekIGo0ttQmfcI6m2k',
    'Fc4vG728FNjo9qOJ9DP_f',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'BCiYNkz0WcCg1gN4_YWFD',
    'OGHG9ZhiAjHZ7G4zLxeUc',
    'VMcDDSw048oIXUnG64_6Y',
    1
  ), (
    'LITd5-DeIU2gco0xaGBJQ',
    'OGHG9ZhiAjHZ7G4zLxeUc',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'xgz_0qL3ZrVSR6cG5vOrI',
    'aQXcTNzehFzaukpBhA4M1',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    'vqpQtKhWkonJlC-GQ6ojw',
    'aQXcTNzehFzaukpBhA4M1',
    'mBZ8CFx8CMzHfdenibbL3',
    2
  ), (
    'kyEy-mpzN-Itwt6j7kQLk',
    'GQ1Gjntx2c-NBwNVaJEbY',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    '1Ywa8W2s58E_K5bi9yT4m',
    'GQ1Gjntx2c-NBwNVaJEbY',
    'OEIT7nZAvV__5jgLK4CRH',
    2
  ), (
    'TxCDATnMWHKFuVYW39UK4',
    'i2m6i0cIQAnVWuMB1YaQu',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    '6yQ99YWEpkY8xKKoxki6-',
    'i2m6i0cIQAnVWuMB1YaQu',
    'IC5L-1P9zQbTXxGP9gEvE',
    2
  ), (
    'vn5DwoO7j1rDB9wHBBt2Q',
    'pTUMnuml7itADMPbpao0W',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    'npnEFgmmAxGRZdZmqw0af',
    'pTUMnuml7itADMPbpao0W',
    '1EvqXuAOfw-16R2LGytKU',
    2
  ), (
    '0Fv1iyUR2g1Q0ZO9gZzfk',
    'kC4DMqkW-mAsthIlf1js3',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    'DvZYcEApruEXquWsaU9kI',
    'kC4DMqkW-mAsthIlf1js3',
    'Q6WE6u8xUTKDlBHwva_K_',
    2
  ), (
    'L0p-EpYqtMV8xA55b9c3c',
    'qzt_YVQhDDv6E0otNm6BD',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    'OkuFtgEXFUPC4YtNB9mL3',
    'qzt_YVQhDDv6E0otNm6BD',
    'J8Hvt0sC20FqAVvou7Q03',
    2
  ), (
    '4BLlDakwCugzN0DRI81gK',
    'stIwfdlUa0Im8Z5BTfAN_',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    'd0DLT4LIQLnJDvu4z2xTU',
    'stIwfdlUa0Im8Z5BTfAN_',
    'RevBvfcP_-NaWDMfH8QIy',
    2
  ), (
    'y6kXVY0TcYLM0C64-Mc7z',
    'DST3zhRR1MelAj9-6rdmI',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    'bcvhxwGF4OVlex2yDSft0',
    'DST3zhRR1MelAj9-6rdmI',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    'Ffmqs1angBGpKov_tZ9pD',
    'HDeQXbWIzhDE5NzzKTBYJ',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    'kelZ9aTyyUhRnjqurxeJK',
    'HDeQXbWIzhDE5NzzKTBYJ',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    'JRDpGU1FNR42gXqIjBZJy',
    '0ylUKXApxUVCHY8NI3-Ll',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    '7GOp3vLu1OjoN6DeOTwyD',
    '0ylUKXApxUVCHY8NI3-Ll',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    '8_CG-VnASyFQVGaoapxwW',
    'F8CwFeqnEyMOY_IztUK6_',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    'gpgCY0ei2OSvQ_nFavRO6',
    'F8CwFeqnEyMOY_IztUK6_',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'vUhDBU782-SnrGjw0Dwdd',
    'n9OQHEPlFL3kNandL21zZ',
    'Qhlw1t90rAtH3CVmCHZa8',
    1
  ), (
    'cKlulCgHAfzWTwCcm8xjk',
    'n9OQHEPlFL3kNandL21zZ',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'gE52nckaouThwmxSN-6VX',
    'VVShmZ9UG5I1PYo4vE9T-',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    '4ZsfmvPAI7Biu5HcQ2F0I',
    'VVShmZ9UG5I1PYo4vE9T-',
    'OEIT7nZAvV__5jgLK4CRH',
    2
  ), (
    'q-J8347r931vqqsDpKr1v',
    '_BUp6ff6Uo-IUZ9CRXcW7',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    'yZpk79OBdaYI5hUbbbLr7',
    '_BUp6ff6Uo-IUZ9CRXcW7',
    'IC5L-1P9zQbTXxGP9gEvE',
    2
  ), (
    'm8oj1dg0XvTdQ80ghv5MV',
    'iROelMQuMpmgnZ-Nz1EqP',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    'dKLqwLz4SHHVpqOQTFbQK',
    'iROelMQuMpmgnZ-Nz1EqP',
    '1EvqXuAOfw-16R2LGytKU',
    2
  ), (
    'yr3RR33ksH10Ah7SfQ_Xr',
    'nQXEbtIFRKyOncJQRvaKZ',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    'pLWya8D5TY8KV-q0bTnn0',
    'nQXEbtIFRKyOncJQRvaKZ',
    'Q6WE6u8xUTKDlBHwva_K_',
    2
  ), (
    '0QMQho1avDiFY_dBNJDt_',
    '3L0N1VQiM_08Jm9xO0WVt',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    'PiPWqPurvA2R4HHgoRGhO',
    '3L0N1VQiM_08Jm9xO0WVt',
    'J8Hvt0sC20FqAVvou7Q03',
    2
  ), (
    'WTjxwkhWMFtfURRZKGCGX',
    'zwCr29m1Or_x8r1MdyMkS',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    'BTvW4c7FgOhq5Vj_KkA8W',
    'zwCr29m1Or_x8r1MdyMkS',
    'RevBvfcP_-NaWDMfH8QIy',
    2
  ), (
    'n4eL4--O-UiB3PrbCZXUk',
    'HDloM6rz42i2qPCH_khwq',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    'imnKMHhhZhvOCuR6LVbPp',
    'HDloM6rz42i2qPCH_khwq',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    'dl0DDwXIj4hqMErj4i9Od',
    'CXHytdB2_Vh2UxbuukySo',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    'c96MCsQ487X77zPhxlI_g',
    'CXHytdB2_Vh2UxbuukySo',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    'Kh1Ba6gwl2yXd2tF2gfxM',
    '9680gdSOmWB2nx8f2mTgy',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    'Y1CyoXlo9lLvBMmyCCOil',
    '9680gdSOmWB2nx8f2mTgy',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'WAq33mhBsW0fjDQR1FhSz',
    '5Epk1aiX-Ukk-CrJCEgTu',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    'twUGGiu0UyfrYpBwNuhHm',
    '5Epk1aiX-Ukk-CrJCEgTu',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'Pah0Z_uQTCRxUTESMqCwU',
    'P_L4801wL1ekj8XkYJFx2',
    'mBZ8CFx8CMzHfdenibbL3',
    1
  ), (
    'SwSjLXLZw-cuXZlRPcvc6',
    'P_L4801wL1ekj8XkYJFx2',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    '-f-aT6nI05gpzYZgAO-Oz',
    'kwOkAEknBqTvIwVO3kHC5',
    'OEIT7nZAvV__5jgLK4CRH',
    1
  ), (
    '2A6-w2DosgmTNYXtFEBT-',
    'kwOkAEknBqTvIwVO3kHC5',
    'IC5L-1P9zQbTXxGP9gEvE',
    2
  ), (
    'XI-A3ySNp5qFX-3QJfOc7',
    'CzWWBbVxynchowRCzxoD7',
    'OEIT7nZAvV__5jgLK4CRH',
    1
  ), (
    '9f8XebwI9T8UWdQ4PZ9wR',
    'CzWWBbVxynchowRCzxoD7',
    '1EvqXuAOfw-16R2LGytKU',
    2
  ), (
    'fUZk2WvXgHl3WptDcR6X_',
    'HPQrHXc5ZZ2iMT6wjLBfs',
    'OEIT7nZAvV__5jgLK4CRH',
    1
  ), (
    '2-z2PvewHaVfO8qp9Yp2n',
    'HPQrHXc5ZZ2iMT6wjLBfs',
    'Q6WE6u8xUTKDlBHwva_K_',
    2
  ), (
    'jPDI2iso0tLoNTwcYDvw4',
    'xvRSAXTjWtpVF1I731qiS',
    'OEIT7nZAvV__5jgLK4CRH',
    1
  ), (
    'crBZXBz0-hZztJKxbb4LA',
    'xvRSAXTjWtpVF1I731qiS',
    'J8Hvt0sC20FqAVvou7Q03',
    2
  ), (
    'JxjpWBohH4vrWDgVqyfYO',
    'I_FTiYrhAKht4bVJtb6tb',
    'OEIT7nZAvV__5jgLK4CRH',
    1
  ), (
    'hCEt2wmdLBqLPrh0bLNVA',
    'I_FTiYrhAKht4bVJtb6tb',
    'RevBvfcP_-NaWDMfH8QIy',
    2
  ), (
    'gWXuoPa8CVdwnoxgjAzTl',
    '93o9bZYOr5-PlD6yySW1f',
    'OEIT7nZAvV__5jgLK4CRH',
    1
  ), (
    'RR40Rb1SpBeeyvX7fuXKH',
    '93o9bZYOr5-PlD6yySW1f',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    'z0kzbqWCZUb7thd3zxsZ5',
    'iw1FxWVUckEbJoDpr8y89',
    'OEIT7nZAvV__5jgLK4CRH',
    1
  ), (
    't92lJwZMVjrE_qhC2gACl',
    'iw1FxWVUckEbJoDpr8y89',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    'c2ab3pJlFbx2egoA9tgn9',
    'TXJKLyaGYGPlK0TAOFEV5',
    'OEIT7nZAvV__5jgLK4CRH',
    1
  ), (
    'TO4xMcpxlZcRZKzkizaOW',
    'TXJKLyaGYGPlK0TAOFEV5',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'dk6VH886y6YYos-2LG58M',
    'MOfrXVO1xcX52bs1LkfF0',
    'OEIT7nZAvV__5jgLK4CRH',
    1
  ), (
    'l0SAzOFz6OLOwkli4H0_0',
    'MOfrXVO1xcX52bs1LkfF0',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'BXgagHxVyCCxXFcycjxEF',
    'beX3gTdsR4HsbhUYhfhj2',
    'OEIT7nZAvV__5jgLK4CRH',
    1
  ), (
    'CByj71hBtEhAHsquJws-C',
    'beX3gTdsR4HsbhUYhfhj2',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    '--wEjW4224IJKbQCgquC5',
    'SW_0zAafk6ZcqkbjhXGZz',
    'IC5L-1P9zQbTXxGP9gEvE',
    1
  ), (
    'eMHRXTx81RXn42sX8sYRX',
    'SW_0zAafk6ZcqkbjhXGZz',
    '1EvqXuAOfw-16R2LGytKU',
    2
  ), (
    '5ZEjC8cLAWN8KOf_Xk11P',
    'yDq-2fkJcnabQKmrbOwbX',
    'IC5L-1P9zQbTXxGP9gEvE',
    1
  ), (
    'Or7cVsZSjX-4XPp-w-XxU',
    'yDq-2fkJcnabQKmrbOwbX',
    'Q6WE6u8xUTKDlBHwva_K_',
    2
  ), (
    'MRaBccEYOrqEE4pkJ7eMo',
    'jmaqvw7MPuzBEh9yarYrY',
    'IC5L-1P9zQbTXxGP9gEvE',
    1
  ), (
    'EUqghTvH2zaok5b2zupKA',
    'jmaqvw7MPuzBEh9yarYrY',
    'J8Hvt0sC20FqAVvou7Q03',
    2
  ), (
    'g77GjvDmhRkPqAGQX3Uqf',
    'lnaeQIzAJjz45xv8_IqR3',
    'IC5L-1P9zQbTXxGP9gEvE',
    1
  ), (
    'DBC341Rsu4IuvdPhBnjgJ',
    'lnaeQIzAJjz45xv8_IqR3',
    'RevBvfcP_-NaWDMfH8QIy',
    2
  ), (
    'BvQ6D_6v8nUH7o8MpjgBZ',
    '2WCR-Q_4F_yxFxxcDjQog',
    'IC5L-1P9zQbTXxGP9gEvE',
    1
  ), (
    'VVgMpJ5A-y1VnI67S2J3v',
    '2WCR-Q_4F_yxFxxcDjQog',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    'cBWjkOqKzUUvTR-o5DXpb',
    '33Cg23eqxdlyoK6gA9U2r',
    'IC5L-1P9zQbTXxGP9gEvE',
    1
  ), (
    'JRtbL8xuNCTe5zWqYCpeJ',
    '33Cg23eqxdlyoK6gA9U2r',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    'AI_MMSFWKazeBRwNOvUwt',
    'SdoANgIFy-G4yHfm2AP1B',
    'IC5L-1P9zQbTXxGP9gEvE',
    1
  ), (
    'L6Xrs_X7HesWUAlOgS86g',
    'SdoANgIFy-G4yHfm2AP1B',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'ns3MQhfpHak_SVvqTNSP8',
    '2LSqqrcoKK5bUQHH5KtgU',
    'IC5L-1P9zQbTXxGP9gEvE',
    1
  ), (
    'UcySEnasLUt3Q2rKSJu6y',
    '2LSqqrcoKK5bUQHH5KtgU',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    '3WWgOHL-H18HyL5_xSYwd',
    'qJKavm4RnqgResT7Psy6w',
    'IC5L-1P9zQbTXxGP9gEvE',
    1
  ), (
    'pxqE3UFCDrz5TkvkVHdME',
    'qJKavm4RnqgResT7Psy6w',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'hyGK4aWHqro4CwzPXIaI5',
    'IVT-0CdCEq5QmfSXeiZn8',
    '1EvqXuAOfw-16R2LGytKU',
    1
  ), (
    'VMCL_bKE2egGvpkztVVN9',
    'IVT-0CdCEq5QmfSXeiZn8',
    'Q6WE6u8xUTKDlBHwva_K_',
    2
  ), (
    'oZd3poTdjYjH2cU2C2EMD',
    'KI_gTgNZgdvMKMLJZv47f',
    '1EvqXuAOfw-16R2LGytKU',
    1
  ), (
    'FY4xgSKyLS1u1eLZq54u3',
    'KI_gTgNZgdvMKMLJZv47f',
    'J8Hvt0sC20FqAVvou7Q03',
    2
  ), (
    'u5ygugUeRuXmnKfbEQer5',
    'zgvExdjpKAZ45HHqY-NcB',
    '1EvqXuAOfw-16R2LGytKU',
    1
  ), (
    'kISvJUHqg4slZ6LS8RnEZ',
    'zgvExdjpKAZ45HHqY-NcB',
    'RevBvfcP_-NaWDMfH8QIy',
    2
  ), (
    'Kr1tLEmq9dtEwD3D-mmv5',
    'MeugDe8c3wlnLQ2wXbtQr',
    '1EvqXuAOfw-16R2LGytKU',
    1
  ), (
    'EuXhhVAVEERWXpwVXa4pB',
    'MeugDe8c3wlnLQ2wXbtQr',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    'F5nJN0bDq6L7B8lwnPBN6',
    'wgl57oUuDPGaENRk82b8y',
    '1EvqXuAOfw-16R2LGytKU',
    1
  ), (
    'FRwcPfodQkQ36mX6MEVmR',
    'wgl57oUuDPGaENRk82b8y',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    '14F6uk-HXvc_53fZ-ms-J',
    'pZEvRCsXpsqJJ0K5rsiCM',
    '1EvqXuAOfw-16R2LGytKU',
    1
  ), (
    'p7vwt7AbFiIPOuA8fqPIt',
    'pZEvRCsXpsqJJ0K5rsiCM',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'g_Z5Ck6z1YmPlDgFfnAyH',
    'w51asMt1vdlctMFRJwjVD',
    '1EvqXuAOfw-16R2LGytKU',
    1
  ), (
    'kkNAkFjJKpekw8ihMLSoJ',
    'w51asMt1vdlctMFRJwjVD',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'd1273gPuiP7If4TIOSdH6',
    'bik49RBSlW_0b2eEd6en3',
    '1EvqXuAOfw-16R2LGytKU',
    1
  ), (
    'gD5-hzgIENJpbejgvegNV',
    'bik49RBSlW_0b2eEd6en3',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'U-sJ0EgLREKXqJQIyDuKn',
    'sZXD2vYondnn2ZRqtDYN1',
    'Q6WE6u8xUTKDlBHwva_K_',
    1
  ), (
    'M6pMknPu1-iCmI1m2Flvn',
    'sZXD2vYondnn2ZRqtDYN1',
    'J8Hvt0sC20FqAVvou7Q03',
    2
  ), (
    'ODr3KuEYDs2SEfV0cPw5z',
    'eS-7distNGXriSbTh6ZP3',
    'Q6WE6u8xUTKDlBHwva_K_',
    1
  ), (
    'Hx8YRZRWxr_ALtHThjJ0G',
    'eS-7distNGXriSbTh6ZP3',
    'RevBvfcP_-NaWDMfH8QIy',
    2
  ), (
    'WN4MlUsH0Njq5kk1cGJk8',
    '82hCVe02CZZZ7oqVvGNMz',
    'Q6WE6u8xUTKDlBHwva_K_',
    1
  ), (
    'EA-sYTjQRnt3afFUxQofG',
    '82hCVe02CZZZ7oqVvGNMz',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    'GWEpBcI728OGD2iRkkodl',
    'LjJbyn-2ZwqnzP8WBS_SI',
    'Q6WE6u8xUTKDlBHwva_K_',
    1
  ), (
    'wAErn7Pozwwgjs-hMF4kL',
    'LjJbyn-2ZwqnzP8WBS_SI',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    '6QK2tLIc_D4fOCsDiYtUm',
    'UbKXgVvMqvDUFF9kAvgWX',
    'Q6WE6u8xUTKDlBHwva_K_',
    1
  ), (
    'ds0fqcDkv4RJzlKFruLOg',
    'UbKXgVvMqvDUFF9kAvgWX',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'nY2IejLuHDZXrWQRGZnc7',
    'A9BF_qeXFG4IySzn6FVX4',
    'Q6WE6u8xUTKDlBHwva_K_',
    1
  ), (
    '6vUhxkEInsZ1MPCi-YnUN',
    'A9BF_qeXFG4IySzn6FVX4',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'YHWmLnCFJMBjKYaiZ21XK',
    'IpWAW2XMesDwJ_M6qIZNb',
    'Q6WE6u8xUTKDlBHwva_K_',
    1
  ), (
    'IM512QWAC7iQvhFPA2Sd6',
    'IpWAW2XMesDwJ_M6qIZNb',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'gosZ9LBqMsQuwluRWXbXR',
    'xdmUWTR1KaDvv5LhB6gqw',
    'J8Hvt0sC20FqAVvou7Q03',
    1
  ), (
    'GutehakrpSDqheIUc-teR',
    'xdmUWTR1KaDvv5LhB6gqw',
    'RevBvfcP_-NaWDMfH8QIy',
    2
  ), (
    'MWbuWTIbQcakmYjJ3NgRK',
    '9S-zXqGNHUWS9VkzDd-yP',
    'J8Hvt0sC20FqAVvou7Q03',
    1
  ), (
    '-LDRKnri5SfZdjcFNWHUn',
    '9S-zXqGNHUWS9VkzDd-yP',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    '268k41y9iWIozT7xPh7Tw',
    'cznIk1WCJ9lsOj31MaRwk',
    'J8Hvt0sC20FqAVvou7Q03',
    1
  ), (
    '8yfGn3LhGVKj7Xkb-ZHGh',
    'cznIk1WCJ9lsOj31MaRwk',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    'FVQfK09c1mB3fXUeGy6ni',
    'CZWlWFaMeudAhZepE8wAo',
    'J8Hvt0sC20FqAVvou7Q03',
    1
  ), (
    'hWsHO8A1IpsE5rV7GPlIF',
    'CZWlWFaMeudAhZepE8wAo',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'EhyvVbDbazii4TSrerGk5',
    'kPex2ye3ewrSjKPSbaONX',
    'J8Hvt0sC20FqAVvou7Q03',
    1
  ), (
    '15p1y2oTegVcu_Mf8Kp7X',
    'kPex2ye3ewrSjKPSbaONX',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'BqR5ObgvBit1in1qx26iE',
    '1KlNbo-ZmFGzFVeK214_g',
    'J8Hvt0sC20FqAVvou7Q03',
    1
  ), (
    'GQMH4eifvCpIE36QCXxkU',
    '1KlNbo-ZmFGzFVeK214_g',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'QtC1yo_Wugdsn59Pw2_sF',
    '1FlDMxhrsxwaov37R2NAI',
    'RevBvfcP_-NaWDMfH8QIy',
    1
  ), (
    'ZFrfxiD5FJ4UCv03rFX6f',
    '1FlDMxhrsxwaov37R2NAI',
    '9k2PYQu98XE2e85ehrJMR',
    2
  ), (
    'wZ9CLu3CrslU91VU9b368',
    '9gFCsYhaHI-tQ7_U73DB4',
    'RevBvfcP_-NaWDMfH8QIy',
    1
  ), (
    'VVN3xBHwQ8LJmcbjQJKFK',
    '9gFCsYhaHI-tQ7_U73DB4',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    'sZWiPImQSftFdfnh5qNum',
    'wezUNNXzHvzMDTtGLeesj',
    'RevBvfcP_-NaWDMfH8QIy',
    1
  ), (
    'abij7AIO9L_jb0JYFfcAY',
    'wezUNNXzHvzMDTtGLeesj',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    '2dwbhDc_HuYBbOrSOFRZE',
    'Fxmw2LsP-3c9RtQaN4Bhq',
    'RevBvfcP_-NaWDMfH8QIy',
    1
  ), (
    'NXpSsRTSmJD07t5AoQ296',
    'Fxmw2LsP-3c9RtQaN4Bhq',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    '8Ftiwx1MlxpsA6ZMnA6Tz',
    'LF1zqwyIz146ZPu7aeyRT',
    'RevBvfcP_-NaWDMfH8QIy',
    1
  ), (
    'lYP8OsXC5V7yTlD3I8I7v',
    'LF1zqwyIz146ZPu7aeyRT',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'maeRTQPWLXiHt10pJyciX',
    'VhnlAEte22tF4btdKVaqJ',
    '9k2PYQu98XE2e85ehrJMR',
    1
  ), (
    'PdoeMEbE2IOu0kC-x8gO1',
    'VhnlAEte22tF4btdKVaqJ',
    'XkRMIlGmBdVAi04lz1bNi',
    2
  ), (
    'R5HjhS0_wI0MDfy3jTsab',
    'aXdmf0kH2OtarmClA0D9N',
    '9k2PYQu98XE2e85ehrJMR',
    1
  ), (
    '6s6j8GosfSRl5T_HqC2Ag',
    'aXdmf0kH2OtarmClA0D9N',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'WUm6f2-F9JTc8_zXlY1Kx',
    'zE5zO-8osuvL8QOw4-eIR',
    '9k2PYQu98XE2e85ehrJMR',
    1
  ), (
    'LF1qyxb7x1GrGz3n1Lzl2',
    'zE5zO-8osuvL8QOw4-eIR',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'UmqNaDgpwurg3GtQF_ifh',
    'BkXFskuf63FfRBrikLvuf',
    '9k2PYQu98XE2e85ehrJMR',
    1
  ), (
    'kLdviZ6oT2Xt4zizqnF2T',
    'BkXFskuf63FfRBrikLvuf',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'noKxoNlDVYAEyw4dKjplY',
    'GtyKso8Y4QPv3mGMfMlh1',
    'XkRMIlGmBdVAi04lz1bNi',
    1
  ), (
    'OF7blr20zM8w7tdEKsL2y',
    'GtyKso8Y4QPv3mGMfMlh1',
    '5hLOZtWjWnnD0aZPavGBH',
    2
  ), (
    'aPpKbGcMEJ2d1yq9nmVFL',
    'HKqphFIgIX6sv1fcYuc6W',
    'XkRMIlGmBdVAi04lz1bNi',
    1
  ), (
    'qEEpv5phFtc6Z1rVO1Nws',
    'HKqphFIgIX6sv1fcYuc6W',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    'jdqnexjGk_ZKS9UkvMJ1Z',
    '3mO7ZXrQBLlrxEMYi0TwR',
    'XkRMIlGmBdVAi04lz1bNi',
    1
  ), (
    'PF5d2K6EythSlPQe1E2Jy',
    '3mO7ZXrQBLlrxEMYi0TwR',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'LRoc3cZLB694RQXNrFu6n',
    'K2hmFYSYATWyPCQLFmGPF',
    '5hLOZtWjWnnD0aZPavGBH',
    1
  ), (
    'Y2PSqFlvPbwTHrw0ydAqI',
    'K2hmFYSYATWyPCQLFmGPF',
    'j4tPZ2N9V4NSNVQh34cRK',
    2
  ), (
    '--6uInyvQz4bT9THGkuPk',
    'tn7_5WEOmmrEiU6FOJe_z',
    '5hLOZtWjWnnD0aZPavGBH',
    1
  ), (
    '0r6F0FiDloVkibOzTA1N1',
    'tn7_5WEOmmrEiU6FOJe_z',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  ), (
    'T3HFiw_T7tdF0NX-txrry',
    'jGKvjIHsTtyu9lmohCyOI',
    'j4tPZ2N9V4NSNVQh34cRK',
    1
  ), (
    'wwapUsDffdKZ6SMq44QOq',
    'jGKvjIHsTtyu9lmohCyOI',
    'QMA1Y6J9HG0QdkRJ-oF56',
    2
  );
