#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>

#include "DHT.h"

#define DHTPIN 2     // Digital pin connected to the DHT sensor
#define DHTTYPE DHT11   // DHT 11

//Pins
int reflectSens = A0;
int reflectSens2 = D7;
int pinA = D1; // Connected to CLK on KY-040
int pinB = D2; // Connected to DT on KY-040

//variables
float wheelDiam = 3; //value in ft will need to be changed
float stopDist = 100; //value in ft
float time1=0.0, time2=0.0;
int pinALast, aVal;

//internet stuff
const char* ssid = "Avi_iPhone";
const char* password = "aviisawesome";

//int ledPin = 13; // GPIO13
// Use WiFiClient class to create TCP connections
const char* host = "raspberrypi.local";
const uint16_t port = 80;
WiFiClient client;

void setup() {

  Serial.begin(9600);
  delay(10);
  Serial.println("at the beginning");

  // Connect to WiFi network
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);



  while (WiFi.status() != WL_CONNECTED) {
    delay(10000);
    WiFi.begin(ssid, password);
    Serial.println(WiFi.status());
    WiFi.printDiag(Serial);
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop()
{
  float recVeloc = recSpeed();
  float actVeloc = actSpeed();
  
  Serial.println("Rec Velocity (mph):" + String(recVeloc,3));
  Serial.println("Actual Velocity (mph): " + String(actVeloc,3));


  //sending data to websit
 
    if (!client.connect(host, port)) {
    delay(5000);
    return;
    }

    /*
    String content = namePerson;
    String contentlength = String(sizeof(content));
    client.println("POST / HTTP/1.1\r\nHost: 192.168.1.190 \r\nContent-Type: text/plain\r\nContent-Length: 1\r\n\r\nA");
  */

  String data = "recVeloc=" + String(recVeloc,3)+"&actVeloc=" + String(actVeloc,3);
  Serial.println("Data sent" + data);

  Serial.println(data);
  client.println("POST /hack2021/genPost.py HTTP/1.1");
  client.println("Host: raspberrypi.local");
  client.println("Content-Type: application/x-www-form-urlencoded");
  client.print("Content-Length: ");
  client.println(String(data.length()));
  client.println();
  client.print(data);//possibly printline
  //Serial.println(data);
  Serial.println("We have connection");


  if (client.connected()) {
    Serial.println("We have data");
    client.stop();
  }

  delay(500);
}

float recSpeed()
{
  int sensReading = analogRead(reflectSens);
  float friction = mapf(sensReading, 0, 1023, 0, .8);
  
  Serial.println("Sensor Reading: " + sensReading);
  Serial.println("Friction: " + String(friction));

  //reccomendation speed
  float velocity = sqrt(2*friction*stopDist*32.2)*3600.0/5280.0;//velocity calculations
  
  return velocity;
}

float actSpeed()
{
  //reset
  time1=0.0;
  time2=0.0;
  
  float aVelocity;
  while(time2-time1<.3) //keep looping until get valid velocity
  {
  int counter = 0;
  time1 = millis()/1000.0;//in sec
  while (counter < 3)
  {
    aVal = digitalRead(pinA);
    if (aVal != pinALast) // moving
    {
      counter++;
      //Serial.println(counter);

    }
    pinALast = aVal;
    delay(5);
    yield();
  }
  time2 = millis()/1000.0;//in sec
  aVelocity = (3.14 * wheelDiam)*.05 / ((time2 - time1))*3600.0/5280.0*100.0;
  }
   return aVelocity;
}

float mapf(float x, float fromLow, float fromHigh, float toLow, float toHigh)
{
  float result = x / (fromHigh - fromLow) * (toHigh - toLow) + toLow;
  return result;
}
