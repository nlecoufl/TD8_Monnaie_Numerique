# Concert
 Contract to create concert with artist, venue, and ticket objects.
# truffle-testing 

These tests were written with:
* Truffle v5.0.8 (core: 5.0.8)
* Solidity v0.5.0 (solc-js)
* Node v11.3.0
* Web3.js v1.0.0-beta.37

# Context
The objective was to write a simple smart contract to manage the ticketing process for concerts. A lot of tools exists today to facilitate the relationship between artists and their audience:
* Bandcamp/Society6 to sell mp3/merch
* Distrokid/CD Baby to distribute digitally their music
* Facebook/Instagram to promote content

However, there are still few tools to help artists sell tickets for concerts. This is true for smaller and bigger artists. 

Platforms like ticketmaster take a massive commission in issuance fee etc.

The goal was to design a ticketing system allowing an artist to sell their tickets directly to their audience.

# What is inside
* Ticketing contract 
* Function to create/modify an artist profile (Name, Artist type, Total tickets sold)
* Functions to create/modify a venue profile (Name, Space available, % of ticket price going to venue with 2 decimals)
* Ticket object (concert ID, artist ID, venue ID)
* Functions to create a concert, emit tickets and use tickets. Artists can emit tickets that they attribute to whoever they want.
* Ticket owner can use tickets on the day of the event
* Functions to buy and transfer tickets  
* Function for the artist to cash out after the concert. 
* Function to safely trade ticket for money.
