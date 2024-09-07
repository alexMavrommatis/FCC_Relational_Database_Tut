#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

#echo $($PSQL "TRUNCATE customers, appointments")
#echo $($PSQL "ALTER SEQUENCE appointments_appointment_id_seq RESTART WITH 1")
#echo $($PSQL "ALTER SEQUENCE customers_customer_id_seq RESTART WITH 1")

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"
echo "How may I help you?" 


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  echo -e "\nHere are the services we offer:"
  SALON_SERVICES=$($PSQL "select service_id, name from services order by service_id")
  echo "$SALON_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # ask for a service 
  echo -e "\nFor which one would you like an appointment?"
  read SERVICE_ID_SELECTED
  
  # if unput not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a valid service number."
  else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]] 
    then
      # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

    
    fi
    
    echo -e "\nEnter an appointment time:"
    read SERVICE_TIME
    
    # get customer id
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
    INSERT_SCHEDULE_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME' )")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    
  fi

}

MAIN_MENU

