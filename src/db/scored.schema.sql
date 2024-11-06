
DROP TABLE IF EXISTS J_playerGame;
DROP TABLE IF EXISTS J_playerTeam;
DROP TABLE IF EXISTS D_playerScores;
DROP TABLE IF EXISTS D_teams;
DROP TABLE IF EXISTS D_gameData;
DROP TABLE IF EXISTS D_gameType;
DROP TABLE IF EXISTS D_appState;
DROP TABLE IF EXISTS D_players;
DROP TABLE IF EXISTS E_gameStates;
DROP TABLE IF EXISTS E_playerTypes;


-- =====================================================


CREATE TABLE IF NOT EXISTS E_gameStates (
  gameState_id INTEGER PRIMARY KEY AUTOINCREMENT,
  gameState_key VARCHAR(11) NOT NULL,
  gameState_label CHAR(40) NOT NULL
);
CREATE UNIQUE INDEX UNI_gameState_key ON E_gameStates(gameState_key);

INSERT INTO E_gameStates (
  gameState_id,
  gameState_key,
  gameState_label
) VALUES
  ( 1, 'SET_TYPE',    'Set the type of game being played' ),
  ( 2, 'ADD_PLAYERS', 'Add players/teams to game' ),
  ( 3, 'PLAYING',     'Playing game (adding scores)' ),
  ( 4, 'SUSPENDED',   'Game is temporarily suspended' ),
  ( 5, 'GAME_OVER',   'Game over' );


CREATE TABLE IF NOT EXISTS E_playerTypes (
  playerType_id INTEGER PRIMARY KEY AUTOINCREMENT,
  playerType_key VARCHAR(6) NOT NULL,
  playerType_label CHAR(20) NOT NULL
);
CREATE UNIQUE INDEX UNI_playerType_key ON E_playerTypes(playerType_key);
CREATE UNIQUE INDEX UNI_playerType_label ON E_playerTypes(playerType_label);

INSERT INTO E_playerTypes (
  playerType_id,
  playerType_key,
  playerType_label
) VALUES
  ( 1, 'SYSTEM', 'System (developer)' ),
  ( 2, 'SUPER_ADMIN',  'Super admin' ),
  ( 3, 'ADMIN',  'Player group admin' ),
  ( 4, 'PLAYER', 'Ordinary player' );


-- =====================================================


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


-- =====================================================


CREATE TABLE IF NOT EXISTS D_appState (
  appState_id TINYINT(1) NOT NULL DEFAULT 0,
  appState_gameID CHAR(21) DEFAULT NULL,
  appState_darkMode BOOLEAN DEFAULT NULL,
  appState_fontAdjust TINYINT(3) NOT NULL DEFAULT 1,
  appState_lastURL VARCHAR(255) NOT NULL DEFAULT '',
  appState_ownerID CHAR(21) NOT NULL,
  FOREIGN KEY(appState_gameID) REFERENCES D_gameData(gameData_id),
  FOREIGN KEY(appState_ownerID) REFERENCES D_players(player_id)
);


-- =====================================================


CREATE TABLE IF NOT EXISTS D_gameType (
  gameType_id CHAR(21) NOT NULL,
  gameType_blocked BOOLEAN NOT NULL DEFAULT 0,
  gameType_builtIn BOOLEAN NOT NULL DEFAULT 0,
  gameType_callToWin BOOLEAN NOT NULL DEFAULT 0,
  gameType_createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gameType_createdBy CHAR(21) NOT NULL,
  gameType_maxPlayers TINYINT(3) NOT NULL,
  gameType_maxScore TINYINT(3) NOT NULL,
  gameType_minPlayers TINYINT(3) NOT NULL,
  gameType_minScore TINYINT(3) DEFAULT NULL,
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
CREATE INDEX IND_gameType_createdAt ON D_gameType(gameType_createdAt);
CREATE INDEX IND_gameType_createdBy ON D_gameType(gameType_createdBy);
CREATE INDEX IND_gameType_maxScore ON D_gameType(gameType_maxScore);
CREATE INDEX IND_gameType_maxPlayers ON D_gameType(gameType_maxPlayers);
CREATE INDEX IND_gameType_minScore ON D_gameType(gameType_minScore);
CREATE INDEX IND_gameType_minPlayers ON D_gameType(gameType_minPlayers);
CREATE INDEX IND_gameType_requiresCall ON D_gameType(gameType_requiresCall);
CREATE INDEX IND_gameType_requiresTeams ON D_gameType(gameType_requiresTeams);
CREATE INDEX IND_gameType_teams ON D_gameType(gameType_teams);
CREATE INDEX IND_gameType_updatedAt ON D_gameType(gameType_updatedAt);
CREATE INDEX IND_gameType_updatedBy ON D_gameType(gameType_updatedBy);


-- =====================================================


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
  FOREIGN KEY(gameData_gameStateID) REFERENCES E_gameStates(gameState_id)
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


-- =====================================================


CREATE TABLE IF NOT EXISTS D_playerScores (
  playerScore_id CHAR(21) NOT NULL,
  playerScore_createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  playerScore_createdBy CHAR(21) NOT NULL,
  playerScore_gameID CHAR(21) NOT NULL,
  playerScore_gameTypeID CHAR(21) NOT NULL,
  playerScore_overallRank TINYINT(3) NOT NULL,
  playerScore_notes VARCHAR(255) DEFAULT NULL,
  playerScore_playerID CHAR(21) DEFAULT NULL,
  playerScore_round TINYINT(3) NOT NULL,
  playerScore_roundRank TINYINT(3) NOT NULL,
  playerScore_score INT NOT NULL,
  playerScore_scoreIsFinal BOOLEAN DEFAULT 0,
  playerScore_teamID CHAR(21) DEFAULT NULL,
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


-- =====================================================


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


-- =====================================================


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


-- =====================================================


CREATE TABLE IF NOT EXISTS J_playerGame (
  playerGame_id CHAR(21) NOT NULL,
  playerGame_gameID CHAR(21) NOT NULL,
  playerGame_gameTypeID CHAR(21) NOT NULL,
  playerGame_order TINYINT(3) NOT NULL,
  playerGame_playerID CHAR(21) NOT NULL,
  playerGame_teamID CHAR(21) DEFAULT NULL,
  PRIMARY KEY (playerGame_id),
  FOREIGN KEY(playerGame_gameID) REFERENCES D_gameData(gameData_id),
  FOREIGN KEY(playerGame_gameTypeID) REFERENCES D_gameType(gameType_id),
  FOREIGN KEY(playerGame_playerID) REFERENCES D_players(player_id),
  FOREIGN KEY(playerGame_teamID) REFERENCES D_teams(team_id)
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


-- =====================================================


INSERT INTO D_players (
  player_id,
  player_typeID,
  player_givenName,
  player_nickname,
  player_familyName,
  player_normalisedName,  player_createdBy
 ) VALUES (
    'KSJrwuzUaSra1FJFM-RMd',
    2,
    'Evan',
    'Evan',
    'Wills',
    'evanwills',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'QoJkYN0UR0xTacPO_o42M',
    3,
    'Georgina',
    'Georgie',
    'Pike',
    'georginapike',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'mJyWHfJWrjZTNtAyY5m34',
    4,
    'Mallee',
    'Mallee',
    'Pike Wills',
    'malleepike wills',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'nF1h_c6L_QGPlFG-nlz9F',
    3,
    'Ada',
    'Ada',
    'Pike Wills',
    'adapike wills',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'GbSDRDnaH7hM4xveJXATh',
    4,
    'Carmel',
    'Carmel',
    'Pike',
    'carmelpike',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'EKDWeOQNU-NCqTkD-lzDI',
    3,
    'Jessica',
    'Jess',
    'Pike',
    'jessicapike',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'WbTTXjntL3-GLFcRqbAkd',
    3,
    'Stuart',
    'Stu',
    'Pike',
    'stuartpike',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'J_vmmZOVUPQg9XUCgaOEO',
    3,
    'Katie',
    'Katie',
    'Pike',
    'katiepike',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '6Uoav5K0twfZoJNY_pHxm',
    3,
    'Allison',
    'Ally',
    'Burg',
    'allisonburg',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'Q9EufimEwmWPQNWbYLGi2',
    3,
    'Matt',
    'Matt',
    'Burg',
    'mattburg',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'CouJfJhTREuiC7G9L181F',
    3,
    'Marlo',
    'Marlo',
    'Thompson',
    'marlothompson',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'dYCVOH4fFbJdBgj26Vkf7',
    4,
    'James',
    'James',
    'Pike',
    'jamespike',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'W8E_IWDiYhhr5RgR4P-4e',
    4,
    'Archi',
    'Archi',
    'Pike',
    'archipike',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '9WazkiuPE5ENVL92uK7Dm',
    4,
    'Ellanor',
    'Ella',
    'Pike',
    'ellanorpike',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'kSzv2orAITq3IKEECFItK',
    4,
    'Leo',
    'Leo',
    'Burg',
    'leoburg',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'Zt3DW6VLOhkdpQzcHeQoI',
    4,
    'Daisy',
    'Daisy',
    'Burg',
    'daisyburg',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '_tyhGhXcyC57GV1S6H0dl',
    4,
    'Charlie',
    'Charlie',
    'Thompson',
    'charliethompson',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'XloI9otPWM6armGSyaXHN',
    4,
    'Nigel',
    'Nige',
    'Thompson',
    'nigelthompson',
    'dFMhZwNE7JbD4bbGJEkP1'
  );

INSERT INTO D_teams (
  team_id,
  team_name,
  team_memberCount,
  team_normalisedName,
  team_createdBy
) VALUES (
    'MpXWd23UDpq_hr-QIxy-Z',
    'Evan & Georgie',
    'evangeorgina',
    'KSJrwuzUaSra1FJFM-RMd,QoJkYN0UR0xTacPO_o42M',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'isncJoi5uKq955JOfMdzd',
    'Evan & Mallee',
    'evanmallee',
    'KSJrwuzUaSra1FJFM-RMd,mJyWHfJWrjZTNtAyY5m34',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'd5lsVL8szW64ZHmsgP0Fu',
    'Evan & Ada',
    'evanada',
    'KSJrwuzUaSra1FJFM-RMd,nF1h_c6L_QGPlFG-nlz9F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'PWLnfPv3FvDd9sAnQNHJL',
    'Evan & Carmel',
    'evancarmel',
    'KSJrwuzUaSra1FJFM-RMd,GbSDRDnaH7hM4xveJXATh',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'Ogu68ApXNL1gJQUzdgsCT',
    'Evan & Jess',
    'evanjessica',
    'KSJrwuzUaSra1FJFM-RMd,EKDWeOQNU-NCqTkD-lzDI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'uDtZ_ZwCZYjJDalHDzFVF',
    'Evan & Stu',
    'evanstuart',
    'KSJrwuzUaSra1FJFM-RMd,WbTTXjntL3-GLFcRqbAkd',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '_C2tsKHVvFaEWtbVBARPi',
    'Evan & Katie',
    'evankatie',
    'KSJrwuzUaSra1FJFM-RMd,J_vmmZOVUPQg9XUCgaOEO',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'BUewY_NBsBYjZSOfamXDX',
    'Evan & Ally',
    'evanallison',
    'KSJrwuzUaSra1FJFM-RMd,6Uoav5K0twfZoJNY_pHxm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'lvaFc_VVTkGOfS7iU4Oin',
    'Evan & Matt',
    'evanmatt',
    'KSJrwuzUaSra1FJFM-RMd,Q9EufimEwmWPQNWbYLGi2',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '0gzGOqMqQkmzao_UzXi79',
    'Evan & Marlo',
    'evanmarlo',
    'KSJrwuzUaSra1FJFM-RMd,CouJfJhTREuiC7G9L181F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ssRr_Wos2WxnOpybv37cS',
    'Evan & James',
    'evanjames',
    'KSJrwuzUaSra1FJFM-RMd,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'IcHK2izOe1H42zzmkgFpn',
    'Evan & Archi',
    'evanarchi',
    'KSJrwuzUaSra1FJFM-RMd,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'a_vnSI4szZ0BBiDxb8e4p',
    'Evan & Ella',
    'evanellanor',
    'KSJrwuzUaSra1FJFM-RMd,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    't6ltsf-U28TqtVqqDAQnB',
    'Evan & Leo',
    'evanleo',
    'KSJrwuzUaSra1FJFM-RMd,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ZVnHNSG1bSK_5HFroqQWC',
    'Evan & Daisy',
    'evandaisy',
    'KSJrwuzUaSra1FJFM-RMd,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'JwmfiP2OKeZns7GOzeEc8',
    'Evan & Charlie',
    'evancharlie',
    'KSJrwuzUaSra1FJFM-RMd,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'Zu7yH6tevLxe6RvNUNsaW',
    'Evan & Nige',
    'evannigel',
    'KSJrwuzUaSra1FJFM-RMd,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'tDIceVngfxtnWYE0j5Kwq',
    'Georgie & Mallee',
    'georginamallee',
    'QoJkYN0UR0xTacPO_o42M,mJyWHfJWrjZTNtAyY5m34',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'Nori4BVYxiN8rrf9YBfD-',
    'Georgie & Ada',
    'georginaada',
    'QoJkYN0UR0xTacPO_o42M,nF1h_c6L_QGPlFG-nlz9F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'B8jP_ojsvHjMtu4c7ERCP',
    'Georgie & Carmel',
    'georginacarmel',
    'QoJkYN0UR0xTacPO_o42M,GbSDRDnaH7hM4xveJXATh',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'WuZfHqaR33tf3MLGoKCQ_',
    'Georgie & Jess',
    'georginajessica',
    'QoJkYN0UR0xTacPO_o42M,EKDWeOQNU-NCqTkD-lzDI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'XEjyTQPR8xyaHw6sPjxml',
    'Georgie & Stu',
    'georginastuart',
    'QoJkYN0UR0xTacPO_o42M,WbTTXjntL3-GLFcRqbAkd',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '7qV_H7c59zN3mZXzyme85',
    'Georgie & Katie',
    'georginakatie',
    'QoJkYN0UR0xTacPO_o42M,J_vmmZOVUPQg9XUCgaOEO',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'LbkafCO69nixp3A1tq8K5',
    'Georgie & Ally',
    'georginaallison',
    'QoJkYN0UR0xTacPO_o42M,6Uoav5K0twfZoJNY_pHxm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'P9vSbmfBaCyIysHwdVcEG',
    'Georgie & Matt',
    'georginamatt',
    'QoJkYN0UR0xTacPO_o42M,Q9EufimEwmWPQNWbYLGi2',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'gZhk-UTzo2DB8tM5eR9OJ',
    'Georgie & Marlo',
    'georginamarlo',
    'QoJkYN0UR0xTacPO_o42M,CouJfJhTREuiC7G9L181F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '69TWFGnhcEuEexxKmMIZf',
    'Georgie & James',
    'georginajames',
    'QoJkYN0UR0xTacPO_o42M,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'pH0wbxA8JfdTC9-t5O3RJ',
    'Georgie & Archi',
    'georginaarchi',
    'QoJkYN0UR0xTacPO_o42M,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'FBscC3WLWdVci8VPtuLAT',
    'Georgie & Ella',
    'georginaellanor',
    'QoJkYN0UR0xTacPO_o42M,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'Z94cl3enowQeMgZnnqpFT',
    'Georgie & Leo',
    'georginaleo',
    'QoJkYN0UR0xTacPO_o42M,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'QJm54Gr0Up4JyxSzbnUt_',
    'Georgie & Daisy',
    'georginadaisy',
    'QoJkYN0UR0xTacPO_o42M,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'pYZBudC2jN2KZ_DhskagY',
    'Georgie & Charlie',
    'georginacharlie',
    'QoJkYN0UR0xTacPO_o42M,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'nszy4dSUyKPi6FUX2urwy',
    'Georgie & Nige',
    'georginanigel',
    'QoJkYN0UR0xTacPO_o42M,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'EP6OJYW-rcWjNKhc9QN-V',
    'Mallee & Ada',
    'malleeada',
    'mJyWHfJWrjZTNtAyY5m34,nF1h_c6L_QGPlFG-nlz9F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    's9fIvQAkLMdkan_n-Vph8',
    'Mallee & Carmel',
    'malleecarmel',
    'mJyWHfJWrjZTNtAyY5m34,GbSDRDnaH7hM4xveJXATh',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'nS6IdbfgqQdV2rtq3tRiB',
    'Mallee & Jess',
    'malleejessica',
    'mJyWHfJWrjZTNtAyY5m34,EKDWeOQNU-NCqTkD-lzDI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'IhZlUKU4p2m9BS1_4_c9h',
    'Mallee & Stu',
    'malleestuart',
    'mJyWHfJWrjZTNtAyY5m34,WbTTXjntL3-GLFcRqbAkd',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'bFCbMM_7nqh9PdNP_yqfr',
    'Mallee & Katie',
    'malleekatie',
    'mJyWHfJWrjZTNtAyY5m34,J_vmmZOVUPQg9XUCgaOEO',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '4KGfUPSe3LjkIPuw2w5XM',
    'Mallee & Ally',
    'malleeallison',
    'mJyWHfJWrjZTNtAyY5m34,6Uoav5K0twfZoJNY_pHxm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'JDtOEY9M1RZpVRDxfUuyg',
    'Mallee & Matt',
    'malleematt',
    'mJyWHfJWrjZTNtAyY5m34,Q9EufimEwmWPQNWbYLGi2',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'UJTulvsG60cdYnrBqETXj',
    'Mallee & Marlo',
    'malleemarlo',
    'mJyWHfJWrjZTNtAyY5m34,CouJfJhTREuiC7G9L181F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'i00BePlXjWAoBfHVPgLR8',
    'Mallee & James',
    'malleejames',
    'mJyWHfJWrjZTNtAyY5m34,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'n9iPjKPLWfQCJ0_onBqtt',
    'Mallee & Archi',
    'malleearchi',
    'mJyWHfJWrjZTNtAyY5m34,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'T4mz-YpkZEqRfeA2TYfum',
    'Mallee & Ella',
    'malleeellanor',
    'mJyWHfJWrjZTNtAyY5m34,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'LsVDUBuOJuQ9cAYeDMDKg',
    'Mallee & Leo',
    'malleeleo',
    'mJyWHfJWrjZTNtAyY5m34,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '5_8Jmsx9Abl9lk9632hAs',
    'Mallee & Daisy',
    'malleedaisy',
    'mJyWHfJWrjZTNtAyY5m34,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'gQDCZSbtdw3FcPMU5Vij5',
    'Mallee & Charlie',
    'malleecharlie',
    'mJyWHfJWrjZTNtAyY5m34,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '6243kao6lmjAkPKAX29Vh',
    'Mallee & Nige',
    'malleenigel',
    'mJyWHfJWrjZTNtAyY5m34,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '2zmdyIY8p6HacyrWdRjc9',
    'Ada & Carmel',
    'adacarmel',
    'nF1h_c6L_QGPlFG-nlz9F,GbSDRDnaH7hM4xveJXATh',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'sPs8S6qYDdrFSDffcDO4H',
    'Ada & Jess',
    'adajessica',
    'nF1h_c6L_QGPlFG-nlz9F,EKDWeOQNU-NCqTkD-lzDI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'NjFWa33gsnHEXiZo8XNrl',
    'Ada & Stu',
    'adastuart',
    'nF1h_c6L_QGPlFG-nlz9F,WbTTXjntL3-GLFcRqbAkd',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'fz_dRoSQX66lxFej4U1cx',
    'Ada & Katie',
    'adakatie',
    'nF1h_c6L_QGPlFG-nlz9F,J_vmmZOVUPQg9XUCgaOEO',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '8zE9UnyhbxUGNkyEmzJOg',
    'Ada & Ally',
    'adaallison',
    'nF1h_c6L_QGPlFG-nlz9F,6Uoav5K0twfZoJNY_pHxm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ypJY0DXoT474VBa5-K3GB',
    'Ada & Matt',
    'adamatt',
    'nF1h_c6L_QGPlFG-nlz9F,Q9EufimEwmWPQNWbYLGi2',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'owawhK5HkROq_BTGGYw6q',
    'Ada & Marlo',
    'adamarlo',
    'nF1h_c6L_QGPlFG-nlz9F,CouJfJhTREuiC7G9L181F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'uOfBUNFxwPgiGntuq5k6L',
    'Ada & James',
    'adajames',
    'nF1h_c6L_QGPlFG-nlz9F,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'FfAGILhntsGkH2mprDjhc',
    'Ada & Archi',
    'adaarchi',
    'nF1h_c6L_QGPlFG-nlz9F,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'n-iuSvZ_UTEDzJGdspb5C',
    'Ada & Ella',
    'adaellanor',
    'nF1h_c6L_QGPlFG-nlz9F,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'gzhR_eDS30Y9RoHdKBdPS',
    'Ada & Leo',
    'adaleo',
    'nF1h_c6L_QGPlFG-nlz9F,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'y1t3DW1MKOubK3KSH_4kb',
    'Ada & Daisy',
    'adadaisy',
    'nF1h_c6L_QGPlFG-nlz9F,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'JNCJqL_xcNWYyzlESwIqF',
    'Ada & Charlie',
    'adacharlie',
    'nF1h_c6L_QGPlFG-nlz9F,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'wNYtNVpQW5upGZqFEzl-G',
    'Ada & Nige',
    'adanigel',
    'nF1h_c6L_QGPlFG-nlz9F,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'jjbnFEPXLdQGo5KCAAIuI',
    'Carmel & Jess',
    'carmeljessica',
    'GbSDRDnaH7hM4xveJXATh,EKDWeOQNU-NCqTkD-lzDI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'StZCujal9K729-4Jf63T-',
    'Carmel & Stu',
    'carmelstuart',
    'GbSDRDnaH7hM4xveJXATh,WbTTXjntL3-GLFcRqbAkd',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '2lV4q-lm78uR2zRFMEK2p',
    'Carmel & Katie',
    'carmelkatie',
    'GbSDRDnaH7hM4xveJXATh,J_vmmZOVUPQg9XUCgaOEO',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'gMkMNTQ1C7-FNXS3Qg0pQ',
    'Carmel & Ally',
    'carmelallison',
    'GbSDRDnaH7hM4xveJXATh,6Uoav5K0twfZoJNY_pHxm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ti6wzQz2ZHCWOEWEWQYbQ',
    'Carmel & Matt',
    'carmelmatt',
    'GbSDRDnaH7hM4xveJXATh,Q9EufimEwmWPQNWbYLGi2',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'RohD_Yx7DreJmTO9kUYtG',
    'Carmel & Marlo',
    'carmelmarlo',
    'GbSDRDnaH7hM4xveJXATh,CouJfJhTREuiC7G9L181F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'uMSVfEiJXxprhzEYrFzT6',
    'Carmel & James',
    'carmeljames',
    'GbSDRDnaH7hM4xveJXATh,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '-PgFCueTJevx5Y56jIDoS',
    'Carmel & Archi',
    'carmelarchi',
    'GbSDRDnaH7hM4xveJXATh,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '0F0CQK91dXZLS51r9hc9W',
    'Carmel & Ella',
    'carmelellanor',
    'GbSDRDnaH7hM4xveJXATh,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'kmVH0TINhBB0P0IrXEtRE',
    'Carmel & Leo',
    'carmelleo',
    'GbSDRDnaH7hM4xveJXATh,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '9Bb1anIpWYtjaoLbJtpcW',
    'Carmel & Daisy',
    'carmeldaisy',
    'GbSDRDnaH7hM4xveJXATh,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'X1jmBuxIzW6Svrk5ewFL3',
    'Carmel & Charlie',
    'carmelcharlie',
    'GbSDRDnaH7hM4xveJXATh,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'un0Y62YSk8pSJ95Wbh_uN',
    'Carmel & Nige',
    'carmelnigel',
    'GbSDRDnaH7hM4xveJXATh,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'RBvwEDJBcXZQ2Z8hla0Jv',
    'Jess & Stu',
    'jessicastuart',
    'EKDWeOQNU-NCqTkD-lzDI,WbTTXjntL3-GLFcRqbAkd',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'G2LslvLM1KvSV1NbZ319g',
    'Jess & Katie',
    'jessicakatie',
    'EKDWeOQNU-NCqTkD-lzDI,J_vmmZOVUPQg9XUCgaOEO',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '10U5aPmbCOTloLq2JojMh',
    'Jess & Ally',
    'jessicaallison',
    'EKDWeOQNU-NCqTkD-lzDI,6Uoav5K0twfZoJNY_pHxm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'J67HXrtBrNRoWjb9XKndC',
    'Jess & Matt',
    'jessicamatt',
    'EKDWeOQNU-NCqTkD-lzDI,Q9EufimEwmWPQNWbYLGi2',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'L_X704eq678xMGaNKQLOr',
    'Jess & Marlo',
    'jessicamarlo',
    'EKDWeOQNU-NCqTkD-lzDI,CouJfJhTREuiC7G9L181F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '6xA66gBwXsZSrG3qPmpiX',
    'Jess & James',
    'jessicajames',
    'EKDWeOQNU-NCqTkD-lzDI,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ZZq2Yv8lL84Z3QnZFOlJE',
    'Jess & Archi',
    'jessicaarchi',
    'EKDWeOQNU-NCqTkD-lzDI,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ZViMc_fOYJySZpff_O1aM',
    'Jess & Ella',
    'jessicaellanor',
    'EKDWeOQNU-NCqTkD-lzDI,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '71dbhrmhHw13Foe9hAgS7',
    'Jess & Leo',
    'jessicaleo',
    'EKDWeOQNU-NCqTkD-lzDI,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'm0NuhODVtjGjN_SmQKAzN',
    'Jess & Daisy',
    'jessicadaisy',
    'EKDWeOQNU-NCqTkD-lzDI,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'R-eoidLTJLyTPl0mpb3-G',
    'Jess & Charlie',
    'jessicacharlie',
    'EKDWeOQNU-NCqTkD-lzDI,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'kshU_Qknld_QhA4-v2nMw',
    'Jess & Nige',
    'jessicanigel',
    'EKDWeOQNU-NCqTkD-lzDI,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'nNvfldF8YAY2KNxXZ655v',
    'Stu & Katie',
    'stuartkatie',
    'WbTTXjntL3-GLFcRqbAkd,J_vmmZOVUPQg9XUCgaOEO',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'hSOa_y2xl5lPCqTMt3lwF',
    'Stu & Ally',
    'stuartallison',
    'WbTTXjntL3-GLFcRqbAkd,6Uoav5K0twfZoJNY_pHxm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'LxSrmGy5AogpR05BNoR1u',
    'Stu & Matt',
    'stuartmatt',
    'WbTTXjntL3-GLFcRqbAkd,Q9EufimEwmWPQNWbYLGi2',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '5F5GpX0SXNWHWLIAGOwbT',
    'Stu & Marlo',
    'stuartmarlo',
    'WbTTXjntL3-GLFcRqbAkd,CouJfJhTREuiC7G9L181F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'YMatC9yI_2pP33C_zKYfv',
    'Stu & James',
    'stuartjames',
    'WbTTXjntL3-GLFcRqbAkd,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'QpRME1vx4gyfp5GwDZwBI',
    'Stu & Archi',
    'stuartarchi',
    'WbTTXjntL3-GLFcRqbAkd,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'PzfLJy5i4ENb_rzribuYt',
    'Stu & Ella',
    'stuartellanor',
    'WbTTXjntL3-GLFcRqbAkd,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'sJz3ZA4aO_dUyHnBOJo-V',
    'Stu & Leo',
    'stuartleo',
    'WbTTXjntL3-GLFcRqbAkd,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'Gbo1ouUPQoX0u6O2lTAHd',
    'Stu & Daisy',
    'stuartdaisy',
    'WbTTXjntL3-GLFcRqbAkd,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'xJDLFiLDY-uOJYWtfabHz',
    'Stu & Charlie',
    'stuartcharlie',
    'WbTTXjntL3-GLFcRqbAkd,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '-U-WlUxDhcOuc4Ag5-k0-',
    'Stu & Nige',
    'stuartnigel',
    'WbTTXjntL3-GLFcRqbAkd,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'kUposskAAD77GozxmuAjt',
    'Katie & Ally',
    'katieallison',
    'J_vmmZOVUPQg9XUCgaOEO,6Uoav5K0twfZoJNY_pHxm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'Fm6LQe7wW0HVZa2fPzBAj',
    'Katie & Matt',
    'katiematt',
    'J_vmmZOVUPQg9XUCgaOEO,Q9EufimEwmWPQNWbYLGi2',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'm-xOoOZKU6Rj5YNZ-Infm',
    'Katie & Marlo',
    'katiemarlo',
    'J_vmmZOVUPQg9XUCgaOEO,CouJfJhTREuiC7G9L181F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'OTnF_AzFiis1aXpuUCwNc',
    'Katie & James',
    'katiejames',
    'J_vmmZOVUPQg9XUCgaOEO,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'pqWVt6hiB55h58KEMnEnw',
    'Katie & Archi',
    'katiearchi',
    'J_vmmZOVUPQg9XUCgaOEO,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'SeQn7JrOA12jMaaX7UZVw',
    'Katie & Ella',
    'katieellanor',
    'J_vmmZOVUPQg9XUCgaOEO,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'NMZLjnvRhPm0bakKxg-lL',
    'Katie & Leo',
    'katieleo',
    'J_vmmZOVUPQg9XUCgaOEO,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'MuZy1SpDMv4GNpvycYzDk',
    'Katie & Daisy',
    'katiedaisy',
    'J_vmmZOVUPQg9XUCgaOEO,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '54bJUE9YTBqM735rVv7DQ',
    'Katie & Charlie',
    'katiecharlie',
    'J_vmmZOVUPQg9XUCgaOEO,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '0npcVnN7MCqrwzUp70EG_',
    'Katie & Nige',
    'katienigel',
    'J_vmmZOVUPQg9XUCgaOEO,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'InMudWfKX5KM352DynHTD',
    'Ally & Matt',
    'allisonmatt',
    '6Uoav5K0twfZoJNY_pHxm,Q9EufimEwmWPQNWbYLGi2',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'jWdoxJvomz6_ThqR6LB6w',
    'Ally & Marlo',
    'allisonmarlo',
    '6Uoav5K0twfZoJNY_pHxm,CouJfJhTREuiC7G9L181F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ngCPNF2sWvvleBf9n0w1N',
    'Ally & James',
    'allisonjames',
    '6Uoav5K0twfZoJNY_pHxm,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'hG57QCmLD4d6XdSlVtIZL',
    'Ally & Archi',
    'allisonarchi',
    '6Uoav5K0twfZoJNY_pHxm,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'Bct0_XybhCxzxGUe2bN2V',
    'Ally & Ella',
    'allisonellanor',
    '6Uoav5K0twfZoJNY_pHxm,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '_VOP3DXeu9AN39Vm4kIA9',
    'Ally & Leo',
    'allisonleo',
    '6Uoav5K0twfZoJNY_pHxm,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'qYS8IuSA1ljEUNCWjpv8L',
    'Ally & Daisy',
    'allisondaisy',
    '6Uoav5K0twfZoJNY_pHxm,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'DAcgq47iU_Gn5V4uDtrMx',
    'Ally & Charlie',
    'allisoncharlie',
    '6Uoav5K0twfZoJNY_pHxm,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ZXq7nuDQlEFhR0bNXeT1W',
    'Ally & Nige',
    'allisonnigel',
    '6Uoav5K0twfZoJNY_pHxm,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '4LINmI-eZULjDdV4PjuEN',
    'Matt & Marlo',
    'mattmarlo',
    'Q9EufimEwmWPQNWbYLGi2,CouJfJhTREuiC7G9L181F',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ABM286aUdRW8WHi7CZSh4',
    'Matt & James',
    'mattjames',
    'Q9EufimEwmWPQNWbYLGi2,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '1aSpCQBJIX-ZDufOBbriJ',
    'Matt & Archi',
    'mattarchi',
    'Q9EufimEwmWPQNWbYLGi2,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ZvhB7QPDxNFWaEM8bRgZc',
    'Matt & Ella',
    'mattellanor',
    'Q9EufimEwmWPQNWbYLGi2,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'wQmqlxJYS7FhT796BV_t5',
    'Matt & Leo',
    'mattleo',
    'Q9EufimEwmWPQNWbYLGi2,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'K0x9B70Eca6knQje2ClKn',
    'Matt & Daisy',
    'mattdaisy',
    'Q9EufimEwmWPQNWbYLGi2,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '91ECekQEBvTnbM5mf2oNS',
    'Matt & Charlie',
    'mattcharlie',
    'Q9EufimEwmWPQNWbYLGi2,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '42PTtt1RyTr-mw8EsNUve',
    'Matt & Nige',
    'mattnigel',
    'Q9EufimEwmWPQNWbYLGi2,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'I1A6Vu99VHG5D46Oq1FXl',
    'Marlo & James',
    'marlojames',
    'CouJfJhTREuiC7G9L181F,dYCVOH4fFbJdBgj26Vkf7',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '9DXl2rLU4GA-Lvt0H1qQF',
    'Marlo & Archi',
    'marloarchi',
    'CouJfJhTREuiC7G9L181F,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'LrQenDAKS7qJIcW2g986D',
    'Marlo & Ella',
    'marloellanor',
    'CouJfJhTREuiC7G9L181F,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'tLbPkwu0oxUsmhPYkA0Q1',
    'Marlo & Leo',
    'marloleo',
    'CouJfJhTREuiC7G9L181F,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'Urz1ejIUZ2VlBkgHTLg6c',
    'Marlo & Daisy',
    'marlodaisy',
    'CouJfJhTREuiC7G9L181F,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'U-d5ytShO8Q3SUwL65rr3',
    'Marlo & Charlie',
    'marlocharlie',
    'CouJfJhTREuiC7G9L181F,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '5WbzZ5RelK-tmg4VKfy9r',
    'Marlo & Nige',
    'marlonigel',
    'CouJfJhTREuiC7G9L181F,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '1dFfbCLnLIQ7KCfalrADW',
    'James & Archi',
    'jamesarchi',
    'dYCVOH4fFbJdBgj26Vkf7,W8E_IWDiYhhr5RgR4P-4e',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '48uZfQChD_RM-vFzpSIFW',
    'James & Ella',
    'jamesellanor',
    'dYCVOH4fFbJdBgj26Vkf7,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '80Rz78muMM8i4sGmZLLrc',
    'James & Leo',
    'jamesleo',
    'dYCVOH4fFbJdBgj26Vkf7,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'M1tqEKjcIoHodTKuKzNF3',
    'James & Daisy',
    'jamesdaisy',
    'dYCVOH4fFbJdBgj26Vkf7,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'EQkR2Y2sNDsct-xndrXXq',
    'James & Charlie',
    'jamescharlie',
    'dYCVOH4fFbJdBgj26Vkf7,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ujuQ7Pgsc0jGDmTBjvkMX',
    'James & Nige',
    'jamesnigel',
    'dYCVOH4fFbJdBgj26Vkf7,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ql1u7bJoxaG9ldsjZtfKi',
    'Archi & Ella',
    'archiellanor',
    'W8E_IWDiYhhr5RgR4P-4e,9WazkiuPE5ENVL92uK7Dm',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'hg4CXkVxTukCKWjzKEK4u',
    'Archi & Leo',
    'archileo',
    'W8E_IWDiYhhr5RgR4P-4e,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'NHaIFiiZQPVC7CRP2hyh_',
    'Archi & Daisy',
    'archidaisy',
    'W8E_IWDiYhhr5RgR4P-4e,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'FhlUSODiszQSvYq7kbezA',
    'Archi & Charlie',
    'archicharlie',
    'W8E_IWDiYhhr5RgR4P-4e,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'ch73mFF3QnRVJek7MIxiJ',
    'Archi & Nige',
    'archinigel',
    'W8E_IWDiYhhr5RgR4P-4e,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'jwnevBGzLTO0NrlV01Lpk',
    'Ella & Leo',
    'ellanorleo',
    '9WazkiuPE5ENVL92uK7Dm,kSzv2orAITq3IKEECFItK',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '_3SzXBc-_jaxTogFuD6SZ',
    'Ella & Daisy',
    'ellanordaisy',
    '9WazkiuPE5ENVL92uK7Dm,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'gWcZXeRwjgf9BJJSq6UKR',
    'Ella & Charlie',
    'ellanorcharlie',
    '9WazkiuPE5ENVL92uK7Dm,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '89mWfgJH03vbXlZyvxwff',
    'Ella & Nige',
    'ellanornigel',
    '9WazkiuPE5ENVL92uK7Dm,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'y_LPjzTIatLMoYAIPiFOB',
    'Leo & Daisy',
    'leodaisy',
    'kSzv2orAITq3IKEECFItK,Zt3DW6VLOhkdpQzcHeQoI',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '906FrQDxlIYwEuc0sXSaK',
    'Leo & Charlie',
    'leocharlie',
    'kSzv2orAITq3IKEECFItK,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    '3y7b5wHb3uNPK7pcr5YLD',
    'Leo & Nige',
    'leonigel',
    'kSzv2orAITq3IKEECFItK,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'EQ_T019eRzug2VxsJ56ok',
    'Daisy & Charlie',
    'daisycharlie',
    'Zt3DW6VLOhkdpQzcHeQoI,_tyhGhXcyC57GV1S6H0dl',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'wUG5pHFHs66YQNOI475GP',
    'Daisy & Nige',
    'daisynigel',
    'Zt3DW6VLOhkdpQzcHeQoI,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  ), (
    'cTdRjGB1Izgu5Wbz8bnx2',
    'Charlie & Nige',
    'charlienigel',
    '_tyhGhXcyC57GV1S6H0dl,XloI9otPWM6armGSyaXHN',
    'dFMhZwNE7JbD4bbGJEkP1'
  );

INSERT INTO J_playerTeam (
  playerTeam_id,
  playerTeam_teamID,
  playerTeam_playerID,
  playerTeam_position
) VALUES (
    'i2gYhKGaCYM9tkuf0pKxO',
    'MpXWd23UDpq_hr-QIxy-Z',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'pMYnV7tSQ8bphclFNzoTA',
    'MpXWd23UDpq_hr-QIxy-Z',
    'QoJkYN0UR0xTacPO_o42M',
    2
  ), (
    'FtJadltTFIgYqKuHDtv9j',
    'isncJoi5uKq955JOfMdzd',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'qnH1De5OCmGAOlZIg9OW0',
    'isncJoi5uKq955JOfMdzd',
    'mJyWHfJWrjZTNtAyY5m34',
    2
  ), (
    '3cS0ORILGZ8HDGSK3NpM6',
    'd5lsVL8szW64ZHmsgP0Fu',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    '5I_qu5fe44gHzxYfMFNXb',
    'd5lsVL8szW64ZHmsgP0Fu',
    'nF1h_c6L_QGPlFG-nlz9F',
    2
  ), (
    'wxjplT00TQ_sZIwPkfRcb',
    'PWLnfPv3FvDd9sAnQNHJL',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    '57UBDbUd6Lky6xut-pitk',
    'PWLnfPv3FvDd9sAnQNHJL',
    'GbSDRDnaH7hM4xveJXATh',
    2
  ), (
    'q2h--14Qxc5p_0tOp751a',
    'Ogu68ApXNL1gJQUzdgsCT',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'n-1Vm7ngcUxAPH8Xl8-Nz',
    'Ogu68ApXNL1gJQUzdgsCT',
    'EKDWeOQNU-NCqTkD-lzDI',
    2
  ), (
    'D8XjQ_uLtPWg4tzRdDp0K',
    'uDtZ_ZwCZYjJDalHDzFVF',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'tEItGHP3B2E_AAtDdm24H',
    'uDtZ_ZwCZYjJDalHDzFVF',
    'WbTTXjntL3-GLFcRqbAkd',
    2
  ), (
    'rD5yExRtXTlHU0iM978al',
    '_C2tsKHVvFaEWtbVBARPi',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'QrFoVikmZoJ3ixVo2m68M',
    '_C2tsKHVvFaEWtbVBARPi',
    'J_vmmZOVUPQg9XUCgaOEO',
    2
  ), (
    'Q1aqPtubf3nDv8hkwqwJT',
    'BUewY_NBsBYjZSOfamXDX',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'jenZCIl9OhPW8MpxP7eCh',
    'BUewY_NBsBYjZSOfamXDX',
    '6Uoav5K0twfZoJNY_pHxm',
    2
  ), (
    'f0BnD_zOzesK5VmBrlaob',
    'lvaFc_VVTkGOfS7iU4Oin',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'dwleNIhAhcz9SaFia-0Cl',
    'lvaFc_VVTkGOfS7iU4Oin',
    'Q9EufimEwmWPQNWbYLGi2',
    2
  ), (
    'DFWTW_4o90JDLjh6dFvtj',
    '0gzGOqMqQkmzao_UzXi79',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'BxmLYtOXbP4QhUCRe68_f',
    '0gzGOqMqQkmzao_UzXi79',
    'CouJfJhTREuiC7G9L181F',
    2
  ), (
    '755GsjEgI8AanZcmDyMJx',
    'ssRr_Wos2WxnOpybv37cS',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'fv-XSEfUyXwy2uDGIGBvg',
    'ssRr_Wos2WxnOpybv37cS',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    'cXMEVoN42NMQna_YJOtdQ',
    'IcHK2izOe1H42zzmkgFpn',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'F5vnaOcKmV8c2L4lLxxQS',
    'IcHK2izOe1H42zzmkgFpn',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    'EQht9RGc1PjDTWxN8iTpu',
    'a_vnSI4szZ0BBiDxb8e4p',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'RG5FPDdqw0w8uEkoQoyOL',
    'a_vnSI4szZ0BBiDxb8e4p',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    'Yc4Aq1WJNuO5MN9I9DeRf',
    't6ltsf-U28TqtVqqDAQnB',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'hnnLNSkhxnTuYyUItpPtf',
    't6ltsf-U28TqtVqqDAQnB',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'Dy5EfXzhoImPa4KvbyY_L',
    'ZVnHNSG1bSK_5HFroqQWC',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    'IaPAA8YQCMXZOqMmEpnnv',
    'ZVnHNSG1bSK_5HFroqQWC',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'Z8nvkiR86OZ5B773lYmxg',
    'JwmfiP2OKeZns7GOzeEc8',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    '_hebsyMWZ-BehFLAP_QDI',
    'JwmfiP2OKeZns7GOzeEc8',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'WqKNQacirbDyYmk59e3PR',
    'Zu7yH6tevLxe6RvNUNsaW',
    'KSJrwuzUaSra1FJFM-RMd',
    1
  ), (
    '-BjjX7xlNFeREHl8gL3Ww',
    'Zu7yH6tevLxe6RvNUNsaW',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'S333s_QXrXK_YQxQ5IiCP',
    'tDIceVngfxtnWYE0j5Kwq',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'G4LJu8japWgYGNJwHBpqf',
    'tDIceVngfxtnWYE0j5Kwq',
    'mJyWHfJWrjZTNtAyY5m34',
    2
  ), (
    'OXqC2koesDdGMTNHEhPJu',
    'Nori4BVYxiN8rrf9YBfD-',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    '9dpCCKCiprqKbgD-iDshZ',
    'Nori4BVYxiN8rrf9YBfD-',
    'nF1h_c6L_QGPlFG-nlz9F',
    2
  ), (
    'duTNMxg7aeiZRg_EGSvaV',
    'B8jP_ojsvHjMtu4c7ERCP',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'S7AYDAhkWvlIl7myqY3ou',
    'B8jP_ojsvHjMtu4c7ERCP',
    'GbSDRDnaH7hM4xveJXATh',
    2
  ), (
    'aQj7uxx9a1ykIgD47QXiI',
    'WuZfHqaR33tf3MLGoKCQ_',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'u2da320rLhcY8RqNCOcc8',
    'WuZfHqaR33tf3MLGoKCQ_',
    'EKDWeOQNU-NCqTkD-lzDI',
    2
  ), (
    '_wVCw29dUOXgh2fTucKKm',
    'XEjyTQPR8xyaHw6sPjxml',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'LrhdPjcMoz6X7xptsm2YD',
    'XEjyTQPR8xyaHw6sPjxml',
    'WbTTXjntL3-GLFcRqbAkd',
    2
  ), (
    'AFyP3mDHDgwX6Cy4-O9zi',
    '7qV_H7c59zN3mZXzyme85',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'thFLRrCtE3E0bFDN_I7Vy',
    '7qV_H7c59zN3mZXzyme85',
    'J_vmmZOVUPQg9XUCgaOEO',
    2
  ), (
    'uPbdqvV_NeZ0RTaN8ldty',
    'LbkafCO69nixp3A1tq8K5',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'a5ojXtOCZN-RxxKE7ANzd',
    'LbkafCO69nixp3A1tq8K5',
    '6Uoav5K0twfZoJNY_pHxm',
    2
  ), (
    '0itf5-aKpz_wttkg3_xVQ',
    'P9vSbmfBaCyIysHwdVcEG',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    '-EHk3d4H_vuRkFn_PEFO-',
    'P9vSbmfBaCyIysHwdVcEG',
    'Q9EufimEwmWPQNWbYLGi2',
    2
  ), (
    'Vva1-cohcMRI_i__MGwZZ',
    'gZhk-UTzo2DB8tM5eR9OJ',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'Z7d8p-WaZf4QnbpNE_icw',
    'gZhk-UTzo2DB8tM5eR9OJ',
    'CouJfJhTREuiC7G9L181F',
    2
  ), (
    'kTtexktWZtuteVv-AnOTC',
    '69TWFGnhcEuEexxKmMIZf',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'hHXEI96P2tl2W1EoWE2Lj',
    '69TWFGnhcEuEexxKmMIZf',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    'X-8KbqY3E2bU5mNU0Eey2',
    'pH0wbxA8JfdTC9-t5O3RJ',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'FXThiXhQLyt4KVDKKt5Ne',
    'pH0wbxA8JfdTC9-t5O3RJ',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    'ONbixuWSHxdLRiGYnt5oa',
    'FBscC3WLWdVci8VPtuLAT',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'O38I41H1kdk31ezLDeCXT',
    'FBscC3WLWdVci8VPtuLAT',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    'yM8L08RVzjv8xh_oM1Sc5',
    'Z94cl3enowQeMgZnnqpFT',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    '0_xjEqjGHUuXC_qMnTfDp',
    'Z94cl3enowQeMgZnnqpFT',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'x9Z4C0xA5rqzyS_gGfJSI',
    'QJm54Gr0Up4JyxSzbnUt_',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'izAtCmu_qjitNimBPNQSP',
    'QJm54Gr0Up4JyxSzbnUt_',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    '3mwUhQvDH-h-HrPsHaekR',
    'pYZBudC2jN2KZ_DhskagY',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    'mUfoLVjq5IK1cqVypXDaw',
    'pYZBudC2jN2KZ_DhskagY',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'KGKcewjVInklXCD6gZhKW',
    'nszy4dSUyKPi6FUX2urwy',
    'QoJkYN0UR0xTacPO_o42M',
    1
  ), (
    '2X1CJiLJ32jCeVdJlIv8d',
    'nszy4dSUyKPi6FUX2urwy',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    '81X6ps-rnPouwVQUTEC8p',
    'EP6OJYW-rcWjNKhc9QN-V',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    '5aiCZMwflp9T7pZTMQY-U',
    'EP6OJYW-rcWjNKhc9QN-V',
    'nF1h_c6L_QGPlFG-nlz9F',
    2
  ), (
    'nXVzRdkxHJCIVNbzILmye',
    's9fIvQAkLMdkan_n-Vph8',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    'dj1OoBJg8Fjf0sOnwQbjR',
    's9fIvQAkLMdkan_n-Vph8',
    'GbSDRDnaH7hM4xveJXATh',
    2
  ), (
    'DTy6RhuA-PunDDcKEcl9_',
    'nS6IdbfgqQdV2rtq3tRiB',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    'Pcx9wJOXVky0XxNjl1I7E',
    'nS6IdbfgqQdV2rtq3tRiB',
    'EKDWeOQNU-NCqTkD-lzDI',
    2
  ), (
    'gzlRx0h9QZbzU5qrTEZWk',
    'IhZlUKU4p2m9BS1_4_c9h',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    'gMCxG_kOiGo7bZvyL1dXN',
    'IhZlUKU4p2m9BS1_4_c9h',
    'WbTTXjntL3-GLFcRqbAkd',
    2
  ), (
    'qcnQOFaNDCp1fJFlH5Kk7',
    'bFCbMM_7nqh9PdNP_yqfr',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    'XI65ij_EYLoC6FCXJXDqj',
    'bFCbMM_7nqh9PdNP_yqfr',
    'J_vmmZOVUPQg9XUCgaOEO',
    2
  ), (
    '8RT9gjRIiUXw4vgo9XlhV',
    '4KGfUPSe3LjkIPuw2w5XM',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    'l1ixli1cacYssE5oUI_oC',
    '4KGfUPSe3LjkIPuw2w5XM',
    '6Uoav5K0twfZoJNY_pHxm',
    2
  ), (
    'WUirVF7QXRoJNnjRlz3GO',
    'JDtOEY9M1RZpVRDxfUuyg',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    'hwezPh-AwblTwUgueY6Mf',
    'JDtOEY9M1RZpVRDxfUuyg',
    'Q9EufimEwmWPQNWbYLGi2',
    2
  ), (
    'WL3bKnUTWPuYtkJVPAgOL',
    'UJTulvsG60cdYnrBqETXj',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    'SN700Ly001JYYuhDmtz_9',
    'UJTulvsG60cdYnrBqETXj',
    'CouJfJhTREuiC7G9L181F',
    2
  ), (
    'rJw9TPW6MtUnLree2kx8a',
    'i00BePlXjWAoBfHVPgLR8',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    'TcqGbKogz-JE6vUT45ijd',
    'i00BePlXjWAoBfHVPgLR8',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    'yDbuy2tu_uVeHPpEgXmhh',
    'n9iPjKPLWfQCJ0_onBqtt',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    '2ei2IGqyiSss7Lh2ckLkQ',
    'n9iPjKPLWfQCJ0_onBqtt',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    'a-ThnS0uS8DWsyqtMohwv',
    'T4mz-YpkZEqRfeA2TYfum',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    'xWBvLp21qaN2_M2gCHg6z',
    'T4mz-YpkZEqRfeA2TYfum',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    'KDTcZzM_dVQyfMj44d_wN',
    'LsVDUBuOJuQ9cAYeDMDKg',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    'IFeWFBcxb4z0w3zsxZGH9',
    'LsVDUBuOJuQ9cAYeDMDKg',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    '705JkC5IQBa-uSQE18J9P',
    '5_8Jmsx9Abl9lk9632hAs',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    '5j9s8DRm7zsdMfjglWpeA',
    '5_8Jmsx9Abl9lk9632hAs',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'GKcZY3ESr73IJym1nSY1r',
    'gQDCZSbtdw3FcPMU5Vij5',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    '-JjCO-z9sKLIOuafsKdXH',
    'gQDCZSbtdw3FcPMU5Vij5',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'EPElm2TtSTCY2h8JUmF2c',
    '6243kao6lmjAkPKAX29Vh',
    'mJyWHfJWrjZTNtAyY5m34',
    1
  ), (
    '5eIj9SpdlocWLCFxFrTZ7',
    '6243kao6lmjAkPKAX29Vh',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'UiGIjnA1_CfC1PJKg556b',
    '2zmdyIY8p6HacyrWdRjc9',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    'UwwKEewpCzmhdHBfu9ldn',
    '2zmdyIY8p6HacyrWdRjc9',
    'GbSDRDnaH7hM4xveJXATh',
    2
  ), (
    '3X62xF8D8B_tXR9IC4OS9',
    'sPs8S6qYDdrFSDffcDO4H',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    '2N2fYIHKkn3CMO5FNj0R-',
    'sPs8S6qYDdrFSDffcDO4H',
    'EKDWeOQNU-NCqTkD-lzDI',
    2
  ), (
    'qtv3wdcmY5aWN7hKAOaBE',
    'NjFWa33gsnHEXiZo8XNrl',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    'tSgH4ufbtVZ5jg8Tx4nMe',
    'NjFWa33gsnHEXiZo8XNrl',
    'WbTTXjntL3-GLFcRqbAkd',
    2
  ), (
    'jjGKWYgcuntZ5J2hOQc6x',
    'fz_dRoSQX66lxFej4U1cx',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    'E1bmkpUb0djwCjLFxRyrO',
    'fz_dRoSQX66lxFej4U1cx',
    'J_vmmZOVUPQg9XUCgaOEO',
    2
  ), (
    '4ULka29Wbr7RxPltqFj60',
    '8zE9UnyhbxUGNkyEmzJOg',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    'G0iCB1DCOu0MHxPgqgEJV',
    '8zE9UnyhbxUGNkyEmzJOg',
    '6Uoav5K0twfZoJNY_pHxm',
    2
  ), (
    'q4SjQSZ6G16r7Vw3eHM9N',
    'ypJY0DXoT474VBa5-K3GB',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    '6WPmNAQfLFcORDwXX7OAc',
    'ypJY0DXoT474VBa5-K3GB',
    'Q9EufimEwmWPQNWbYLGi2',
    2
  ), (
    'bx1rEUagWYIzB-pQYFnEl',
    'owawhK5HkROq_BTGGYw6q',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    '47AkiuNLvCXcvH8T4eUSC',
    'owawhK5HkROq_BTGGYw6q',
    'CouJfJhTREuiC7G9L181F',
    2
  ), (
    'cbSxBDz6XvjxCZTNGkivB',
    'uOfBUNFxwPgiGntuq5k6L',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    'C6lQEqY6fRNUvowwvmF5o',
    'uOfBUNFxwPgiGntuq5k6L',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    'vJw0RvDCjJxsY3MZWbccT',
    'FfAGILhntsGkH2mprDjhc',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    'jVOMkyClq8PbJjNst8OzB',
    'FfAGILhntsGkH2mprDjhc',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    'UxUGyjmm8xs-Nk-Fyx6oX',
    'n-iuSvZ_UTEDzJGdspb5C',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    '2lWKKKpnC9LzKrgSpPtEv',
    'n-iuSvZ_UTEDzJGdspb5C',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    '5RMGLIFz-F8VhTEwoJjAV',
    'gzhR_eDS30Y9RoHdKBdPS',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    'jDH7HoESb9iCj3LBB6qXX',
    'gzhR_eDS30Y9RoHdKBdPS',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    '64BrE-G-W2e0C1aJDgxxG',
    'y1t3DW1MKOubK3KSH_4kb',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    '-Fk_7B8ODNGX0Z4x8fcsc',
    'y1t3DW1MKOubK3KSH_4kb',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'dSoIS7_oWwlU9KtOnWO_4',
    'JNCJqL_xcNWYyzlESwIqF',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    'u-kh_u4lxjZkfi76ys6If',
    'JNCJqL_xcNWYyzlESwIqF',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'GXzUE5OsIBAeBivZrnShy',
    'wNYtNVpQW5upGZqFEzl-G',
    'nF1h_c6L_QGPlFG-nlz9F',
    1
  ), (
    '9GgGIEGeVxuQZriZnoNA3',
    'wNYtNVpQW5upGZqFEzl-G',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'U0aeCdMyA2MtDjC1aBNbs',
    'jjbnFEPXLdQGo5KCAAIuI',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'sFGLyUZUOuDOAMsgkCiP2',
    'jjbnFEPXLdQGo5KCAAIuI',
    'EKDWeOQNU-NCqTkD-lzDI',
    2
  ), (
    'TNNIaymiyyJaMzrevzoLg',
    'StZCujal9K729-4Jf63T-',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'XH7EozyIWbz4Dchvigb4y',
    'StZCujal9K729-4Jf63T-',
    'WbTTXjntL3-GLFcRqbAkd',
    2
  ), (
    'vEob8TImTyP7DG6KgsXXB',
    '2lV4q-lm78uR2zRFMEK2p',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'JZz0_ySp7ycxDI4Pyetqc',
    '2lV4q-lm78uR2zRFMEK2p',
    'J_vmmZOVUPQg9XUCgaOEO',
    2
  ), (
    'qxM9BOsWpcrSIBSWcEdYv',
    'gMkMNTQ1C7-FNXS3Qg0pQ',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    '17FBr4vjYbkfzPsGL8bo8',
    'gMkMNTQ1C7-FNXS3Qg0pQ',
    '6Uoav5K0twfZoJNY_pHxm',
    2
  ), (
    'm3RoONZmax7nGOSvN3Otv',
    'ti6wzQz2ZHCWOEWEWQYbQ',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'piNeTY3oVYJ_DtAuC6Z2q',
    'ti6wzQz2ZHCWOEWEWQYbQ',
    'Q9EufimEwmWPQNWbYLGi2',
    2
  ), (
    'ZeITgVmOG5sGieS8GPfl4',
    'RohD_Yx7DreJmTO9kUYtG',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    '6U_BQaOxAUX4LozjiBjKY',
    'RohD_Yx7DreJmTO9kUYtG',
    'CouJfJhTREuiC7G9L181F',
    2
  ), (
    'JJzZjfGj2WggNZPcE8oD_',
    'uMSVfEiJXxprhzEYrFzT6',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'ysk1tJt5zEeV0xZSDv6yN',
    'uMSVfEiJXxprhzEYrFzT6',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    'LnsR__0bIq3gkWPaAF5uw',
    '-PgFCueTJevx5Y56jIDoS',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'nHrtEUQEmJZY_XEcOLo7D',
    '-PgFCueTJevx5Y56jIDoS',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    '7alBvqiIGu5JgX0Qwv5vE',
    '0F0CQK91dXZLS51r9hc9W',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'gClgYVquJ0Lj95vkGrl9d',
    '0F0CQK91dXZLS51r9hc9W',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    'uS8qR8OF9KwWYLSxMvP93',
    'kmVH0TINhBB0P0IrXEtRE',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'OpU1NLumsEa-1T3nFX0Ip',
    'kmVH0TINhBB0P0IrXEtRE',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'D_--xXZNn0LJHZAT9M79g',
    '9Bb1anIpWYtjaoLbJtpcW',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'TKNGGtEeu1-l0j1WzrcWs',
    '9Bb1anIpWYtjaoLbJtpcW',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'IS4kdnsWIT_K39C6v4vEt',
    'X1jmBuxIzW6Svrk5ewFL3',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'iiNeSgIvscw2_aAnVHpxy',
    'X1jmBuxIzW6Svrk5ewFL3',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'KBmDi8qVhWbyW8uRlS-vb',
    'un0Y62YSk8pSJ95Wbh_uN',
    'GbSDRDnaH7hM4xveJXATh',
    1
  ), (
    'kgIp4l3WesTjhTG4FxPkk',
    'un0Y62YSk8pSJ95Wbh_uN',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'QG_0BypIOTfSqMsOojFXT',
    'RBvwEDJBcXZQ2Z8hla0Jv',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'XizkmsTPM8IAxgd2SjBTy',
    'RBvwEDJBcXZQ2Z8hla0Jv',
    'WbTTXjntL3-GLFcRqbAkd',
    2
  ), (
    'GyqlkGtcBUqY2R-EFrKxs',
    'G2LslvLM1KvSV1NbZ319g',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'SP5xn9rSAStxFzWgjJTKp',
    'G2LslvLM1KvSV1NbZ319g',
    'J_vmmZOVUPQg9XUCgaOEO',
    2
  ), (
    'XK4Kmts16hY2BYpwsZkGs',
    '10U5aPmbCOTloLq2JojMh',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'n8-jgmUsO4vaZwwJuaJCz',
    '10U5aPmbCOTloLq2JojMh',
    '6Uoav5K0twfZoJNY_pHxm',
    2
  ), (
    'QBQo9SBV5fEOkrFq8nNci',
    'J67HXrtBrNRoWjb9XKndC',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'mMx2Paty2QDpTwhMQkgxg',
    'J67HXrtBrNRoWjb9XKndC',
    'Q9EufimEwmWPQNWbYLGi2',
    2
  ), (
    'Kbl21aD2iMZFvlBk9WO9F',
    'L_X704eq678xMGaNKQLOr',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    '9OjK82VsN6StGQn0QA32z',
    'L_X704eq678xMGaNKQLOr',
    'CouJfJhTREuiC7G9L181F',
    2
  ), (
    'pXGhRAWP1S0wajviriUvb',
    '6xA66gBwXsZSrG3qPmpiX',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'bkaI1qzVAHla3oAPrAJYR',
    '6xA66gBwXsZSrG3qPmpiX',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    'A-HSgdEAV3KwLsA4apnGV',
    'ZZq2Yv8lL84Z3QnZFOlJE',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'se9bcpzv3lxNdjytOQ4GJ',
    'ZZq2Yv8lL84Z3QnZFOlJE',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    'HCt21-vIo30IoI3eQT5PT',
    'ZViMc_fOYJySZpff_O1aM',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'lRJivUNjLKH92ONYKFnXF',
    'ZViMc_fOYJySZpff_O1aM',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    'OuvjplaYG82E3ulHjP7tE',
    '71dbhrmhHw13Foe9hAgS7',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'oyVyeYStjY1oCZmQ1QmUP',
    '71dbhrmhHw13Foe9hAgS7',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'Spk4MTStv9wAEYPWZMmwf',
    'm0NuhODVtjGjN_SmQKAzN',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'Gc3x6uP9NPcfZWqYSUohy',
    'm0NuhODVtjGjN_SmQKAzN',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    '0-H-maKeWoUut-91WmuIz',
    'R-eoidLTJLyTPl0mpb3-G',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'vQOULr4saxojJoeZmTMpJ',
    'R-eoidLTJLyTPl0mpb3-G',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    '3G4k8IUn2EYXx3I6-GzQU',
    'kshU_Qknld_QhA4-v2nMw',
    'EKDWeOQNU-NCqTkD-lzDI',
    1
  ), (
    'ACYeOioUCsrPb0I0K68z7',
    'kshU_Qknld_QhA4-v2nMw',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    '9-L7B2-zbo7G-lNKZoOSJ',
    'nNvfldF8YAY2KNxXZ655v',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    'jrPn84AKdjDr96yLuBXaR',
    'nNvfldF8YAY2KNxXZ655v',
    'J_vmmZOVUPQg9XUCgaOEO',
    2
  ), (
    '4Nr6cKWEWSy_6fXPrnvwl',
    'hSOa_y2xl5lPCqTMt3lwF',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    'ZX7Rr_bcOJkQxin1fVVWp',
    'hSOa_y2xl5lPCqTMt3lwF',
    '6Uoav5K0twfZoJNY_pHxm',
    2
  ), (
    'w_x26Z_pp_LrS2lYLBcDE',
    'LxSrmGy5AogpR05BNoR1u',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    'SXzGqX9d2Njzu5-yJM8sh',
    'LxSrmGy5AogpR05BNoR1u',
    'Q9EufimEwmWPQNWbYLGi2',
    2
  ), (
    'NjS06kaoDlm29TrkvjmQP',
    '5F5GpX0SXNWHWLIAGOwbT',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    'oPMBIXfx4FgRdX5gR-LTh',
    '5F5GpX0SXNWHWLIAGOwbT',
    'CouJfJhTREuiC7G9L181F',
    2
  ), (
    'cQODrzrye_4TxJKLi0Ku_',
    'YMatC9yI_2pP33C_zKYfv',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    '5Ae8ZLhgFWjx0Nnu3KpqX',
    'YMatC9yI_2pP33C_zKYfv',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    'Qy1cPhxmHmeRXyvhnjLNq',
    'QpRME1vx4gyfp5GwDZwBI',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    'JNcMKkykZBr73FMxZVHsU',
    'QpRME1vx4gyfp5GwDZwBI',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    '9XPVwzERkUgrFMjhp2Mqg',
    'PzfLJy5i4ENb_rzribuYt',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    'J0cyvBc6K9-3EYmoNau6N',
    'PzfLJy5i4ENb_rzribuYt',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    '3cacBKD7r9Gnuk5kmYiC5',
    'sJz3ZA4aO_dUyHnBOJo-V',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    'PLqqYoqfW63PCouzJedCs',
    'sJz3ZA4aO_dUyHnBOJo-V',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    '9iF9rCte4bpVG8wBL0lW9',
    'Gbo1ouUPQoX0u6O2lTAHd',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    'mAkjolkqbRQizuMzH8UAi',
    'Gbo1ouUPQoX0u6O2lTAHd',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'nls_yyAonWxjJn9ZsAAf6',
    'xJDLFiLDY-uOJYWtfabHz',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    'f6G0oma8JpInDTb2RYA7s',
    'xJDLFiLDY-uOJYWtfabHz',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    '8vZzdXebw4xfk8C2JThWZ',
    '-U-WlUxDhcOuc4Ag5-k0-',
    'WbTTXjntL3-GLFcRqbAkd',
    1
  ), (
    'emRBXeysUd-L18ZRxpOUD',
    '-U-WlUxDhcOuc4Ag5-k0-',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'SwLI63hyq3AhfSTXN9obA',
    'kUposskAAD77GozxmuAjt',
    'J_vmmZOVUPQg9XUCgaOEO',
    1
  ), (
    'C0y_bIF6hWfHEgy_4x-Du',
    'kUposskAAD77GozxmuAjt',
    '6Uoav5K0twfZoJNY_pHxm',
    2
  ), (
    '_XtxOjT_-_jJVoFEHkWWW',
    'Fm6LQe7wW0HVZa2fPzBAj',
    'J_vmmZOVUPQg9XUCgaOEO',
    1
  ), (
    '_SaF5Nyk6z7QOXNGuVMYd',
    'Fm6LQe7wW0HVZa2fPzBAj',
    'Q9EufimEwmWPQNWbYLGi2',
    2
  ), (
    'mX2urZNRHkjcK546LuvGg',
    'm-xOoOZKU6Rj5YNZ-Infm',
    'J_vmmZOVUPQg9XUCgaOEO',
    1
  ), (
    'fvh_LFvG_w1tDRYkshSs5',
    'm-xOoOZKU6Rj5YNZ-Infm',
    'CouJfJhTREuiC7G9L181F',
    2
  ), (
    'U62AsKFvd5tmHoXF0EVXb',
    'OTnF_AzFiis1aXpuUCwNc',
    'J_vmmZOVUPQg9XUCgaOEO',
    1
  ), (
    '5wz4qslWyWIUhfsSiS0zc',
    'OTnF_AzFiis1aXpuUCwNc',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    '34KNSnakDT7BTBxEqwA_m',
    'pqWVt6hiB55h58KEMnEnw',
    'J_vmmZOVUPQg9XUCgaOEO',
    1
  ), (
    '8DIzT-LBY5ztFLO-x57wE',
    'pqWVt6hiB55h58KEMnEnw',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    '5Di_QTu2zmyou1SK9eP47',
    'SeQn7JrOA12jMaaX7UZVw',
    'J_vmmZOVUPQg9XUCgaOEO',
    1
  ), (
    'ODHeiH4d5KhWfJrsddh_G',
    'SeQn7JrOA12jMaaX7UZVw',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    'BBTvMJZ673mNJZqAPoWvN',
    'NMZLjnvRhPm0bakKxg-lL',
    'J_vmmZOVUPQg9XUCgaOEO',
    1
  ), (
    'VcO2PXK8q5yxfSgp-x54N',
    'NMZLjnvRhPm0bakKxg-lL',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'PUL6aAwUudEZ_Fgx9TZW4',
    'MuZy1SpDMv4GNpvycYzDk',
    'J_vmmZOVUPQg9XUCgaOEO',
    1
  ), (
    'UFH1tcJ7rV3bX-WmshDWz',
    'MuZy1SpDMv4GNpvycYzDk',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'QjkhIB4Hy8-vqsrXfC3kJ',
    '54bJUE9YTBqM735rVv7DQ',
    'J_vmmZOVUPQg9XUCgaOEO',
    1
  ), (
    '66yLbJm98jIggxegrFT-c',
    '54bJUE9YTBqM735rVv7DQ',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'Szdvkm_-16aStr7-vXdTO',
    '0npcVnN7MCqrwzUp70EG_',
    'J_vmmZOVUPQg9XUCgaOEO',
    1
  ), (
    'ctCRkDFo2Xj2-8dKqCjzY',
    '0npcVnN7MCqrwzUp70EG_',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'iEvoNDA5gp6ydrUES5Pgv',
    'InMudWfKX5KM352DynHTD',
    '6Uoav5K0twfZoJNY_pHxm',
    1
  ), (
    '4ltdRd99n9UKNB-T6cRO8',
    'InMudWfKX5KM352DynHTD',
    'Q9EufimEwmWPQNWbYLGi2',
    2
  ), (
    'rd7Df3z6_1sV3o7VjxdXm',
    'jWdoxJvomz6_ThqR6LB6w',
    '6Uoav5K0twfZoJNY_pHxm',
    1
  ), (
    'OL_CQXFBCLLneiFi4hP0Q',
    'jWdoxJvomz6_ThqR6LB6w',
    'CouJfJhTREuiC7G9L181F',
    2
  ), (
    'lAxW3nHCPIxhwVClykULS',
    'ngCPNF2sWvvleBf9n0w1N',
    '6Uoav5K0twfZoJNY_pHxm',
    1
  ), (
    'kxx5gI8FbAykoviZi4r3a',
    'ngCPNF2sWvvleBf9n0w1N',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    'shJcI4QkBpOZHYMVTcPQP',
    'hG57QCmLD4d6XdSlVtIZL',
    '6Uoav5K0twfZoJNY_pHxm',
    1
  ), (
    'z4sdutnLN4520MZ77iI1_',
    'hG57QCmLD4d6XdSlVtIZL',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    'cIhLtR-00J-s9MCNp8pD5',
    'Bct0_XybhCxzxGUe2bN2V',
    '6Uoav5K0twfZoJNY_pHxm',
    1
  ), (
    'ixRsA0RZMCHMDI38rq9Ma',
    'Bct0_XybhCxzxGUe2bN2V',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    '_smvx43jU54-LLc_D0CRK',
    '_VOP3DXeu9AN39Vm4kIA9',
    '6Uoav5K0twfZoJNY_pHxm',
    1
  ), (
    'ZO8zDaRHYbIN84qzr-pjD',
    '_VOP3DXeu9AN39Vm4kIA9',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'RE6UYReUc6Ng6XcwRjkcn',
    'qYS8IuSA1ljEUNCWjpv8L',
    '6Uoav5K0twfZoJNY_pHxm',
    1
  ), (
    'zCI9YoW3pLSGIyIaAUaiu',
    'qYS8IuSA1ljEUNCWjpv8L',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'DgO8VUpTMTsvpbg-iK_Kd',
    'DAcgq47iU_Gn5V4uDtrMx',
    '6Uoav5K0twfZoJNY_pHxm',
    1
  ), (
    'xGYJi_a7OF8Hn9b2YJtf6',
    'DAcgq47iU_Gn5V4uDtrMx',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    '7OIJIhjjLdYG2g8GkgRUQ',
    'ZXq7nuDQlEFhR0bNXeT1W',
    '6Uoav5K0twfZoJNY_pHxm',
    1
  ), (
    'h4_8lXIKXREcmjG69KH1y',
    'ZXq7nuDQlEFhR0bNXeT1W',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'mvPo97GkIHi5F8ddhQAF1',
    '4LINmI-eZULjDdV4PjuEN',
    'Q9EufimEwmWPQNWbYLGi2',
    1
  ), (
    'lXjjI5WmL5zqJ-kM6Ye7V',
    '4LINmI-eZULjDdV4PjuEN',
    'CouJfJhTREuiC7G9L181F',
    2
  ), (
    'D_8p4GSsA2NIHBJ2hzcGA',
    'ABM286aUdRW8WHi7CZSh4',
    'Q9EufimEwmWPQNWbYLGi2',
    1
  ), (
    'KfbtFR0L-Q3oZjUsFbh8o',
    'ABM286aUdRW8WHi7CZSh4',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    'k8wMsBxX7ouYAQtgQ6cVp',
    '1aSpCQBJIX-ZDufOBbriJ',
    'Q9EufimEwmWPQNWbYLGi2',
    1
  ), (
    '73gtZTUKEhQgsN-v6tpZp',
    '1aSpCQBJIX-ZDufOBbriJ',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    'BU9RazXguJ3NHiYX6jJow',
    'ZvhB7QPDxNFWaEM8bRgZc',
    'Q9EufimEwmWPQNWbYLGi2',
    1
  ), (
    'IlHYvlbRs4ptzLEzs_UUu',
    'ZvhB7QPDxNFWaEM8bRgZc',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    'qFD48veCUBBx8OnoYpLsf',
    'wQmqlxJYS7FhT796BV_t5',
    'Q9EufimEwmWPQNWbYLGi2',
    1
  ), (
    '0--Q0wy6_zfftyZTZ-mjV',
    'wQmqlxJYS7FhT796BV_t5',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'B8j8MoyPSSS51LIGQbGNW',
    'K0x9B70Eca6knQje2ClKn',
    'Q9EufimEwmWPQNWbYLGi2',
    1
  ), (
    'sfmv9RI5k40m65RAh9Weh',
    'K0x9B70Eca6knQje2ClKn',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'bnTFVm6yYRrjaPO9iGGcv',
    '91ECekQEBvTnbM5mf2oNS',
    'Q9EufimEwmWPQNWbYLGi2',
    1
  ), (
    'wf_ET3i5enBEOPF3xMJrc',
    '91ECekQEBvTnbM5mf2oNS',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'luC2cnMOiUdIzFOa3V3f5',
    '42PTtt1RyTr-mw8EsNUve',
    'Q9EufimEwmWPQNWbYLGi2',
    1
  ), (
    'kRJchwqE70hPFMmWxvonS',
    '42PTtt1RyTr-mw8EsNUve',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'B9udqOnNQpduRNG-f0CJK',
    'I1A6Vu99VHG5D46Oq1FXl',
    'CouJfJhTREuiC7G9L181F',
    1
  ), (
    'lKqSSgecArP26ZM8cqrfe',
    'I1A6Vu99VHG5D46Oq1FXl',
    'dYCVOH4fFbJdBgj26Vkf7',
    2
  ), (
    'UgX3cqR-8MHJU_SP-bkLO',
    '9DXl2rLU4GA-Lvt0H1qQF',
    'CouJfJhTREuiC7G9L181F',
    1
  ), (
    'tssvUpf66m9lo1izcaaTb',
    '9DXl2rLU4GA-Lvt0H1qQF',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    'OxxCMc4IvfMuLKqpFT_AY',
    'LrQenDAKS7qJIcW2g986D',
    'CouJfJhTREuiC7G9L181F',
    1
  ), (
    '53j4C331j5J6Sx22VTvzW',
    'LrQenDAKS7qJIcW2g986D',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    'Xp8DsbZiIYksL6-6R0PTJ',
    'tLbPkwu0oxUsmhPYkA0Q1',
    'CouJfJhTREuiC7G9L181F',
    1
  ), (
    'hzWYumICHbqtcdL6kM087',
    'tLbPkwu0oxUsmhPYkA0Q1',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'Y8Zbzloe6Y6z5OJPi9M0R',
    'Urz1ejIUZ2VlBkgHTLg6c',
    'CouJfJhTREuiC7G9L181F',
    1
  ), (
    'SoCeGj87Ym4oenuptlKjv',
    'Urz1ejIUZ2VlBkgHTLg6c',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'zD2HS0oh3dTJiOvORoeYs',
    'U-d5ytShO8Q3SUwL65rr3',
    'CouJfJhTREuiC7G9L181F',
    1
  ), (
    'E5oNNGRzG5TDiFEf_lbC6',
    'U-d5ytShO8Q3SUwL65rr3',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'nMB1QhY7ujY0lkxAsSsXk',
    '5WbzZ5RelK-tmg4VKfy9r',
    'CouJfJhTREuiC7G9L181F',
    1
  ), (
    'OWqDjNJfRK9a7UfWHa3qI',
    '5WbzZ5RelK-tmg4VKfy9r',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'iC17h37FppJ5BfQrNk0mp',
    '1dFfbCLnLIQ7KCfalrADW',
    'dYCVOH4fFbJdBgj26Vkf7',
    1
  ), (
    's5ITZypHMzbdgafD4_xFF',
    '1dFfbCLnLIQ7KCfalrADW',
    'W8E_IWDiYhhr5RgR4P-4e',
    2
  ), (
    'tmJNUsnyHWLnn0xbPPxH9',
    '48uZfQChD_RM-vFzpSIFW',
    'dYCVOH4fFbJdBgj26Vkf7',
    1
  ), (
    'yXYS1ejsQNwozlZr62xgy',
    '48uZfQChD_RM-vFzpSIFW',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    'gch7BGQ4KRCz3GzhRoK2n',
    '80Rz78muMM8i4sGmZLLrc',
    'dYCVOH4fFbJdBgj26Vkf7',
    1
  ), (
    'Rn70hFQz_gQ6zt0YFzJ6G',
    '80Rz78muMM8i4sGmZLLrc',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'kLDgF0oJtCdwv-6oG-SYX',
    'M1tqEKjcIoHodTKuKzNF3',
    'dYCVOH4fFbJdBgj26Vkf7',
    1
  ), (
    'tKAgDFbFFXSwSj-jCv7bn',
    'M1tqEKjcIoHodTKuKzNF3',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'TVNTlV0o9qbZzFdQS9Ygb',
    'EQkR2Y2sNDsct-xndrXXq',
    'dYCVOH4fFbJdBgj26Vkf7',
    1
  ), (
    'byOZpaTfQjN5uVN5pwkWB',
    'EQkR2Y2sNDsct-xndrXXq',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'LJaeTMi-CBniD17pNrvYO',
    'ujuQ7Pgsc0jGDmTBjvkMX',
    'dYCVOH4fFbJdBgj26Vkf7',
    1
  ), (
    'e3Zhz33I_A9BFF0NYIu8G',
    'ujuQ7Pgsc0jGDmTBjvkMX',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'lbircMh2EFx4ZTRRSTBzo',
    'ql1u7bJoxaG9ldsjZtfKi',
    'W8E_IWDiYhhr5RgR4P-4e',
    1
  ), (
    'jraWtyAfgvDULcCuP0MiA',
    'ql1u7bJoxaG9ldsjZtfKi',
    '9WazkiuPE5ENVL92uK7Dm',
    2
  ), (
    'tdWXGmq916idOZeWXqgn2',
    'hg4CXkVxTukCKWjzKEK4u',
    'W8E_IWDiYhhr5RgR4P-4e',
    1
  ), (
    'RI36EjiE0-3FUD3b_7tsv',
    'hg4CXkVxTukCKWjzKEK4u',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'o501o1R7WXUdBbGHmjwmq',
    'NHaIFiiZQPVC7CRP2hyh_',
    'W8E_IWDiYhhr5RgR4P-4e',
    1
  ), (
    'HtPLsXjL6PSUQQkHGLWiz',
    'NHaIFiiZQPVC7CRP2hyh_',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'aesA7Om8229MI8vvGKWZs',
    'FhlUSODiszQSvYq7kbezA',
    'W8E_IWDiYhhr5RgR4P-4e',
    1
  ), (
    'tcJ1jEDocU76Akpodj2c-',
    'FhlUSODiszQSvYq7kbezA',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'C2tJmSugQz2Siq2cQAXhj',
    'ch73mFF3QnRVJek7MIxiJ',
    'W8E_IWDiYhhr5RgR4P-4e',
    1
  ), (
    'Z6MEZyGNcnyVgngCuSoLx',
    'ch73mFF3QnRVJek7MIxiJ',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    '92dCeqX40nc4HUeSChniS',
    'jwnevBGzLTO0NrlV01Lpk',
    '9WazkiuPE5ENVL92uK7Dm',
    1
  ), (
    'ZnY0z4nwpNYPhJa2bXWV-',
    'jwnevBGzLTO0NrlV01Lpk',
    'kSzv2orAITq3IKEECFItK',
    2
  ), (
    'SeIaqsjcbvnC96zJv9Zub',
    '_3SzXBc-_jaxTogFuD6SZ',
    '9WazkiuPE5ENVL92uK7Dm',
    1
  ), (
    'OFL29bSImAqeD8jtttha5',
    '_3SzXBc-_jaxTogFuD6SZ',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'isp9HI-3T-g5yxt0CyC0I',
    'gWcZXeRwjgf9BJJSq6UKR',
    '9WazkiuPE5ENVL92uK7Dm',
    1
  ), (
    '8Ay_2gKDU1VsaGamolB7I',
    'gWcZXeRwjgf9BJJSq6UKR',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'zzc_io4NzYmPI3NFqP_yA',
    '89mWfgJH03vbXlZyvxwff',
    '9WazkiuPE5ENVL92uK7Dm',
    1
  ), (
    'HaYWothBUKhdzoX9iv4Ft',
    '89mWfgJH03vbXlZyvxwff',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'eKpw_dg6uot8YOKsSMjPg',
    'y_LPjzTIatLMoYAIPiFOB',
    'kSzv2orAITq3IKEECFItK',
    1
  ), (
    'xICHWeMQCaARhvuuE_rfo',
    'y_LPjzTIatLMoYAIPiFOB',
    'Zt3DW6VLOhkdpQzcHeQoI',
    2
  ), (
    'liNdSVLD1vsJBpaywtqTG',
    '906FrQDxlIYwEuc0sXSaK',
    'kSzv2orAITq3IKEECFItK',
    1
  ), (
    '1YUqZP2mCcHL0LJg3NgJ1',
    '906FrQDxlIYwEuc0sXSaK',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'Fiwds_wfzJDac02Z48PBi',
    '3y7b5wHb3uNPK7pcr5YLD',
    'kSzv2orAITq3IKEECFItK',
    1
  ), (
    'YKpH011KV_No1wLEP6whg',
    '3y7b5wHb3uNPK7pcr5YLD',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'NQVJwPC1hc-STaqU_dFEz',
    'EQ_T019eRzug2VxsJ56ok',
    'Zt3DW6VLOhkdpQzcHeQoI',
    1
  ), (
    'FMBSIGaAaYQ_wL6uYs9o6',
    'EQ_T019eRzug2VxsJ56ok',
    '_tyhGhXcyC57GV1S6H0dl',
    2
  ), (
    'rCuweRZtagZqY1BkehdUE',
    'wUG5pHFHs66YQNOI475GP',
    'Zt3DW6VLOhkdpQzcHeQoI',
    1
  ), (
    'sHh2H998xnm72fKZdGVfh',
    'wUG5pHFHs66YQNOI475GP',
    'XloI9otPWM6armGSyaXHN',
    2
  ), (
    'RbrW2BY9Lc9rkTUg-fR-f',
    'cTdRjGB1Izgu5Wbz8bnx2',
    '_tyhGhXcyC57GV1S6H0dl',
    1
  ), (
    'lOYTGaipQgwWYshslUb10',
    'cTdRjGB1Izgu5Wbz8bnx2',
    'XloI9otPWM6armGSyaXHN',
    2
  );
