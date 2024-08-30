#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    #get team id from winner
    WINNER_ID=$($PSQL "SELECT team_id FROM TEAMS WHERE name='$WINNER'")
    #if not found
    if [[ -z $WINNER_ID ]]
    then
      #insert into teams
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted $WINNER into teams
        #get new winner_id
        WINNER_ID=$($PSQL "SELECT team_id FROM TEAMS WHERE name='$WINNER'")
      fi
    fi
    #do the same for opponent
    OPPONENT_ID=$($PSQL "SELECT team_id FROM TEAMS WHERE name='$OPPONENT'")
    #if not found
    if [[ -z $OPPONENT_ID ]]
    then
      #insert into teams
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted $OPPONENT into teams
        #get new opponent_id
        OPPONENT_ID=$($PSQL "SELECT team_id FROM TEAMS WHERE name='$OPPONENT'")
      fi
    fi

    #insert all values into games
    GAMES_INSERT_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $GAMES_INSERT_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS into games.
    fi
  fi
done
