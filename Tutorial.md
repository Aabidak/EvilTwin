

# Arduino IDE Installation and Configuration


## Step 1: Download Arduino IDE


Download the Arduino IDE from the official website: [https://www.arduino.cc/en/software]

![st1](https://github.com/user-attachments/assets/94560921-7cdd-4f45-8ad2-d0063cc5f41a)


## Step 2: Add Additional Board Manager URLs

Open the Arduino IDE

Go to File > Preferences

In the Additional Boards Manager URLs field, paste the following two links:

[https://arduino.esp8266.com/stable/package_esp8266com_index.json]

[https://dl.espressif.com/dl/package_esp32_index.json]

Click OK to save the changes

![st2](https://github.com/user-attachments/assets/4f1e2bc7-96a1-400f-a773-c2b57e2a9ca8)

![st2()](https://github.com/user-attachments/assets/08636b5a-6908-418c-b05b-1051c36da2f0)

## Step 3: Install ESP8266 Board

Go to Tools > Board > Board Manager

Search for "ESP8266" and select the latest version

![st3](https://github.com/user-attachments/assets/ad636112-6e9b-44c1-95a2-26cc8bcbaed9)


Click Install to download and install the board


## Step 4: Install ESP8266WiFi Library

Go to Tools > Manage Libraries

Search for "ESP8266WiFi" and select the latest version named  ** senses_wifi ** 

![st4](https://github.com/user-attachments/assets/dcc8143c-c25c-42a6-8fc2-79e2ffde63c9)


Click Install to download and install the library

## step 5:

Upload the Code

Open the source code file (e.g., sourcecode.md) located near the README.md file

![new](https://github.com/user-attachments/assets/2b9b43fb-0c6d-401c-9153-1ead1275297a)


Copy the code and paste it into the Arduino IDE

Click Upload to upload the code to the ESP8266 board


## Step 6: Select the ESP8266 Board

Go to Tools > Board > ESP8266 > NodeMCU 1.0 (ESP-12E Module)

![Screenshot 2024-10-12 224515](https://github.com/user-attachments/assets/c2b4878c-6393-4545-8955-20a87e9bbe0b)


Select the board and click OK to save the changes


## Step 7: Connect and Upload the Code

Connect the ESP8266 board to your computer

Click Upload to upload the code to the board

![Screenshot 2024-10-12 224846](https://github.com/user-attachments/assets/fe9e936b-3bba-45d3-8aa1-948a7ac90cdd)


Wait for the upload process to complete


## Step 8: Verify the Evil Twin AP

Open your Windows Wi-Fi settings and look for a network named "TPlinksecure"

![Screenshot 2024-10-12 225004](https://github.com/user-attachments/assets/2203bfab-61e2-4175-a5eb-9b979668e775)

The password for this network is "mafia007"



# Starting the Evil Twin Attack


## Step 1: Access the Evil Twin Interface

Open a web browser and type "192.168.4.1" in the address bar

![1](https://github.com/user-attachments/assets/efdca968-7002-41d6-aa2d-747abf894d44)



You will see an interface similar to the one shown above:


## Step 2: Select the Target and Start the Evil Twin

Select your target and start the evil twin attack

![1](https://github.com/user-attachments/assets/3514c45f-80aa-4cf0-87ec-cec60fd6e343)


You will be disconnected from the webpages and see the mimicked legitimate AP on your Wi-Fi list


![hiii](https://github.com/user-attachments/assets/ea856f36-2be8-431c-b459-a2ad72c22891)


## Step 3: Redirect to the Fake AP

When the victim tries to access the fake AP, they will be redirected to the password entering page that we  created earlier

![hi](https://github.com/user-attachments/assets/85cb67aa-a67b-40ac-9412-2029fcd7346d)

After submitting correct password the fake ap will be fade away and the password be shown in the gui interface where we selected the targetb


## Step 4: Capture the Password

After the victim enters the correct password, the fake AP will fade, and you can access the password by typing "192.168.4.1" in the address bar

![hrll](https://github.com/user-attachments/assets/b4a0b95c-c442-488d-a8e9-ce7aebf7e496)

### BOOM💥💥 password is captured 

# Disclaimer


This guide is for educational purposes only and should not be used for malicious activities.

Using this guide for illegal activities is strictly prohibited and may result in serious legal consequences.

I hope this rewritten version is more accurate and easier to follow. Let me know if you have any further questions or need any additional clarification!

