#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#echo $($PSQL "TRUNCATE users, games")
#echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")
#echo $($PSQL "ALTER SEQUENCE users_user_id_seq RESTART WITH 1")


random_number_generator(){
  
  random_number=$((1 + $RANDOM % 1000))
  echo $random_number
}

echo -e "\nEnter your username:"
read USERNAME

USERNAME_RESULT=$($PSQL "select name from users where name='$USERNAME'")

if [[ -z $USERNAME_RESULT ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USERNAME_RESULT=$($PSQL "insert into users(name) values('$USERNAME')") 
else
  USER_ID=$($PSQL "select user_id from users where name='$USERNAME'")
  GAMES_PLAYED=$($PSQL "select count(user_id) from games inner join users using(user_id) where name='$USERNAME'")
  BEST_GAME=$($PSQL "select min(guesses) from games inner join users using(user_id) where name='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

USER_ID=$($PSQL "select user_id from users where name='$USERNAME'")

echo -e "\nGuess the secret number between 1 and 1000:"
RANDOM_NUMBER=$(random_number_generator)

#echo "Randome number is $RANDOM_NUMBER"

BREAK=true
NUMBER_OF_GUESSES=0
while $BREAK;
do
  let NUMBER_OF_GUESSES++ 
  while
    read INPUT_NUMBER
    [[ -z $INPUT_NUMBER || $INPUT_NUMBER == *[^0-9]* ]]
  do echo -e "\nThat is not an integer, guess again:"; 
  done
  
  if [[ $INPUT_NUMBER == $RANDOM_NUMBER ]]
  then
    echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    NUMBER_OF_GUESSES_RESULT=$($PSQL "insert into games(guesses, user_id) values('$NUMBER_OF_GUESSES', '$USER_ID')")
    BREAK=false
  elif [[ $INPUT_NUMBER < $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
  else
    echo -e "\nIt's lower than that, guess again:"
  fi
done


#random_number=$(random_number_generator)
#echo -e "This is the random number $random_number"

