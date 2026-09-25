#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "~~~~~ MY SALON ~~~~~"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU () {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "select service_id, name from services order by service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_AVAILABILITY=$($PSQL "SELECT service_id, name FROM services where service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_AVAILABILITY ]]
  then 
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    APP
  fi
}

APP() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  HAVE_CUST=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  if [[ -z $HAVE_CUST ]]
  then 
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    SAVE_NAME=$($PSQL "Insert into customers(name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE_NAME=$($PSQL "SELECT name from services where service_id=$SERVICE_ID_SELECTED")
  FORM_SERVICE=$(echo $SERVICE_NAME | sed -E 's/ //g')
  FORM_CUST=$(echo $CUSTOMER_NAME | sed -E 's/ //g')

  echo -e "\nWhat time would you like your $FORM_SERVICE, $FORM_CUST?"
  read SERVICE_TIME
  SAVE_APP=$($PSQL "insert into appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $SAVE_APP == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $FORM_SERVICE at $SERVICE_TIME, $FORM_CUST."
  fi
}

MAIN_MENU
