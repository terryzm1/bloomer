#include <ArduinoBLE.h>
#include <Adafruit_NeoPixel.h>
#include <DHT.h>

// Constants
#define DHTPIN 2           // Pin connected to the DHT11 data pin
#define DHTTYPE DHT11      // DHT11 sensor
#define LED_PIN 6          // Pin connected to DIN on the strip
#define NUM_LEDS 60        // Number of LEDs in your strip
#define SOIL_MOISTURE_PIN A0 // Pin for soil moisture sensor
#define PUMP_PIN 9         // Pin for water pump

// Objects
Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);
DHT dht(DHTPIN, DHTTYPE);

// BLE UUIDs
#define SERVICE_UUID        "12345678-1234-5678-1234-56789abcdef0"
#define CHARACTERISTIC_UUID "abcdef01-1234-5678-1234-56789abcdef0"

// BLE variables
BLEService plantService(SERVICE_UUID);
BLECharacteristic commandCharacteristic(CHARACTERISTIC_UUID, BLEWrite | BLENotify, 512);

// State variables
bool lightOn = false;
bool pumpRunning = false;
unsigned long pumpStartTime = 0;
unsigned long pumpDuration = 0;
int lightStatus = 0;
const int lightSensorPin = 4;

// Setup function
void setup() {
  Serial.begin(9600);
  while (!Serial);

  // Initialize components
  dht.begin();
  strip.begin();
  strip.show(); // Turn off all LEDs initially
  pinMode(SOIL_MOISTURE_PIN, INPUT);
  pinMode(PUMP_PIN, OUTPUT);
  digitalWrite(PUMP_PIN, LOW); // Pump off initially

  // Initialize BLE
  if (!BLE.begin()) {
    Serial.println("BLE initialization failed!");
    while (1);
  }
  BLE.setLocalName("PlantCare");
  BLE.setAdvertisedService(plantService);
  plantService.addCharacteristic(commandCharacteristic);
  BLE.addService(plantService);

  // Start advertising
  BLE.advertise();
  Serial.println("BLE device is now advertising...");
}

void loop() {
  BLEDevice central = BLE.central();

  // Check if central device is connected
  if (central) {
    Serial.println("Connected to central device");
    while (central.connected()) {
      handleBLECommands();
      handlePumpState();
      sendSensorData();
      delay(1000); // Update every second
    }
    Serial.println("Disconnected from central device");
  }
}

// Handle incoming BLE commands
void handleBLECommands() {
  if (commandCharacteristic.written()) {
    const uint8_t* byteArray = commandCharacteristic.value();
    String command = String((const char*) byteArray);
    Serial.println("Received command: " + command);

    if (command.startsWith("LIGHT_ON")) {
      lightOn = true;
      strip.fill(strip.Color(84, 64, 205)); 
      strip.show();
      Serial.println("Light turned on");
    } else if (command.startsWith("LIGHT_OFF")) {
      lightOn = false;
      strip.clear(); // Turn off all LEDs
      strip.show();
      Serial.println("Light turned off");
    } else if (command.startsWith("PUMP_START_")) {
      pumpDuration = command.substring(11).toInt() * 1000; // Extract duration in seconds and convert to ms
      pumpStartTime = millis();
      pumpRunning = true;
      digitalWrite(PUMP_PIN, HIGH); // Turn pump on
      Serial.println("Pump started for " + String(pumpDuration / 1000) + " seconds");

    } else if (command.startsWith("PUMP_STOP")) {
      digitalWrite(PUMP_PIN, LOW);
      Serial.println("Pump stopped");
    }
  }
}

// Manage pump state
void handlePumpState() {
  if (pumpRunning && millis() - pumpStartTime >= pumpDuration) {
    pumpRunning = false;
    digitalWrite(PUMP_PIN, LOW); // Turn pump off
    Serial.println("Pump turned off");
  }
}

// Read sensors and send data
void sendSensorData() {
  float temperature = dht.readTemperature() + 70;
  float humidity = dht.readHumidity();
  int soilMoisture = analogRead(SOIL_MOISTURE_PIN);
  //int lightStatus = lightOn ? 1 : 0;
  lightStatus = digitalRead(lightSensorPin);
  if (lightStatus == LOW) {
    lightStatus = 1;
  } else {
    lightStatus = 0;
  }
 

  // Create JSON string
  String jsonData = "{";
  jsonData += "\"temperature\":" + String(temperature, 1) + ",";
  jsonData += "\"humidity\":" + String(humidity, 1) + ",";
  jsonData += "\"soil_moisture\":" + String(soilMoisture) + ",";
  jsonData += "\"light\":" + String(lightStatus);
  jsonData += "}";

  // Update the characteristic value
  commandCharacteristic.setValue(jsonData.c_str());
  Serial.println("Sent data: " + jsonData);
}
