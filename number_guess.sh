#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"
UPPER=1000

echo "Enter your username:"
read INPUT_USERNAME

USER_DETAILS="$($PSQL "SELECT user_id, username, games_played, best_game FROM users WHERE username = '$INPUT_USERNAME'")"
IFS='|' read USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< $USER_DETAILS
if [[ -n $USER_ID ]]; then
  GAMES_PLAYED=$(echo $GAMES_PLAYED | sed 's/ //g')
  BEST_GAME=$(echo $BEST_GAME | sed 's/ //g')
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $INPUT_USERNAME! It looks like this is your first time here."
fi

NUMBER=$((1 + $RANDOM % $UPPER))
GUESS=0
PROMPT="Guess the secret number between 1 and 1000:"
TRIES=0
while [[ $GUESS -ne $NUMBER ]]; do
  echo $PROMPT
  read GUESS

  TRIES=$((TRIES+1))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    PROMPT="That is not an integer, guess again:"
  elif [[ $GUESS -gt $NUMBER ]]; then
    PROMPT="It's lower than that, guess again:"
  elif [[ $GUESS -lt $NUMBER ]]; then
    PROMPT="It's higher than that, guess again:"
  else
    echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
  fi
done
if [[ -z $USER_ID ]]; then
  USER_INSERT="$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$INPUT_USERNAME', 1, $TRIES)")"
else
  GAMES_PLAYED=$((GAMES_PLAYED+1))
  if [[ $TRIES -lt $BEST_GAME ]]; then
    BEST_GAME=$TRIES
  fi
  USER_UPDATE="$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id = $USER_ID")"
fi
