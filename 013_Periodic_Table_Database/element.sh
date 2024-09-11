#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
elif [[ $1 =~ ^[0-9]+$ ]]
then
  ELEMENT_RESULT=$($PSQL "select atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius from types full join properties using(type_id) full join elements using(atomic_number) where elements.atomic_number = $1")
else
  ELEMENT_RESULT=$($PSQL "select atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius from types full join properties USING(type_id) full join elements USING(atomic_number) where elements.name like '$1%' LIMIT 1 ")
fi

if [[ $1 ]]
then
  if [[ -z $ELEMENT_RESULT ]]
  then
    echo -e "I could not find that element in the database."
  else
    echo $ELEMENT_RESULT | while IFS=\| read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS
    do
      echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
    done
  fi
fi
