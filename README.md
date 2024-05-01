<p align="center"><img src="bobATC_logo.png" alt="drawing" width="300"/></p>

Jaehyun Lim
18-224 Spring 2024 Final Tapeout Project

## Overview

bobATC is a simplistic air traffic controller on a chip that clears planes for takeoff and landing on a 2 runway airport. 

## How it Works

bobATC controls a hypothetical airspace around a small-scale 2-runway airport. Planes request departure, landing, or emergency to bobATC. To be able to request anything, aircraft must first request an ID to be assigned to their aircraft for the purposes of communication.

bobATC communicates with aircraft via a messaging system structured with 8-bit packets shown below:

| Aircraft ID   | Message Type  | Action |
|:-------------:|:-------------:|:------:|
| 4 bits        | 3 bits        | 1 bit  |

The 8-bit packets are sent in and received through bobATC's UART pins. Because there are 4-bit aircraft IDs, bobATC can handle up to 16 aircraft at a time. The message type bits correspond to the type of request/reply of the packet, and the action bit further helps specify what the packet means. The message types are detailed below:

| Message Type    | Binary | Direction | Meaning |
|:-------------:  |:------:|:------  | :- |
| REQUEST         | 000    | Aircraft => bobATC | Aircraft requests landing or takeoff. |
| DECLARE         | 001    | Aircraft => bobATC | Aircraft declares that it has landed or departed from runway ID specified by action bit. Aircraft loses its 4-bit ID designation. |
| EMERGENCY       | 010    | Aircraft => bobATC | Aircraft declares or resolves ongoing emergency. Action bit 1 declares emergency, 0 resolves emergency. Only the aircraft that originally declared an emergency can resolve it. If multiple aircraft declare emergencies, only the latest one that declared it can resolve it. bobATC will close all runways, meaning no takeoffs will be cleared and all landings will be diverted until the emergency is resolved. Aircraft loses its 4-bit ID designation upon resolving emergency. |
| CLEAR           | 011    | bobATC => Aircraft | bobATC clears an aircraft's request to takeoff or land. Action bit specifies runway to use. |
| HOLD            | 100    | bobATC => Aircraft | bobATC tells an aircraft to wait until clearance. |
| SAY_AGAIN       | 101    | bobATC => Aircraft | bobATC tells an aircraft that the message type is invalid. |
| DIVERT          | 110    | bobATC => Aircraft | bobATC tells an aircraft to divert, either due to congestion or emergency. Aircraft loses its 4-bit ID designation |
| ID_PLEASE       | 111    | Bi-directional | Aircraft requests an unused ID from bobATC. bobATC sends out a valid ID on its Aircraft ID bits, or sends out this message type with action bit 1 to convey that the airspace is full and does not have unused IDs. |

## Inputs/Outputs

| IO Type | IO Pin | Name | Function |
|:--------|:-------|:-----|:---------|
| Input   | io_in[0] | rx | UART receiver |
| Input   | io_in[1] | runway_override[0] | Set high to make runway 0 unusable |
| Input   | io_in[2] | runway_override[1] | Set high to make runway 1 unusable |
| Input   | io_in[3] | emergency_override | Set high to force emergency |
| Output | io_out[0] | tx | UART transmitter |
| Output | io_out[1] | framing_error | Indicates if UART receiver detects a framing error |
| Output | io_out[3:2] | runway_active[1:0] | Indicates the status of runways 0 and 1, whether they are being used or not |
| Output | io_out[4] | emergency | Indicates whether an emergency is ongoing or not |
| Output | io_out[5] | receiving | Indicates that the UART receiver is receiving new data |
| Output | io_out[6] | sending | Indicates that the UART transmitter is sending new data |




## Hardware Peripherals

bobATC requires external hardware to interface with its UART pins.

## Design Testing / Bringup

(explain how to test your design; if relevant, give examples of inputs and expected outputs)

(if you would like your design to be tested after integration but before tapeout, provide a Python script that uses the Debug Interface posted on canvas and explain here how to run the testing script)

## Media

(optionally include any photos or videos of your design in action)
