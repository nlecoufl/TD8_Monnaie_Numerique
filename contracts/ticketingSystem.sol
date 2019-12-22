pragma solidity ^0.5.0;

contract ticketingSystem {

    address private _owner;

    struct Concert {
        address creator;
        uint artistId;
        uint concertId;
        uint venueId;
        uint concertDate;
        uint price;
        uint totalSoldTicket;
        uint totalMoneyCollected;
        bool validatedByArtist;
        bool validatedByVenue;
        bool isOver;
    }

    struct Venue {
        address payable owner;
        bytes32 name;
        uint capacity;
        uint standardComission;
    }

    struct Artist {
        address owner;
        bytes32 name;
        uint artistCategory;
        uint totalTicketSold;
    }

    struct Ticket {
        address owner;
        uint artistId;
        uint concertId;
        uint venueId;
        uint concertDate;
        uint amountPaid;
        uint salePrice;
        bool isRefundable;
        bool isAvailable;
        bool isAvailableForSale;
    }

    constructor() public {
        _owner = msg.sender;
    }

    mapping (uint => Concert) public concertsRegister;
    mapping (uint => Venue)   public venuesRegister;
    mapping (uint => Artist)  public artistsRegister;
    mapping (uint => Ticket)  public ticketsRegister;

    uint private _numberOfConcerts;
    uint private _numberOfVenues;
    uint private _numberOfArtists;
    uint private _numberOfTickets;

    function createArtist(bytes32 _name, uint _category) public {
        _numberOfArtists++;
        artistsRegister[_numberOfArtists] = Artist(msg.sender, _name, _category, 0);
    }

    function modifyArtist(uint _id, bytes32 _name, uint _category, address newOwner) public {
        require(msg.sender == artistsRegister[_id].owner);
        artistsRegister[_id].owner = newOwner;
        artistsRegister[_id].name = _name;
        artistsRegister[_id].artistCategory = _category;
    }

    function createVenue(bytes32 _name, uint _capacity, uint _standardComission) public {
        _numberOfVenues++;
        venuesRegister[_numberOfVenues] = Venue(msg.sender, _name, _capacity, _standardComission);
    }

    function modifyVenue(uint _id, bytes32 _name, uint _capacity, uint _standardComission, address payable _newOwner) public {
        require(msg.sender == venuesRegister[_id].owner);
        venuesRegister[_id].owner = _newOwner;
        venuesRegister[_id].name = _name;
        venuesRegister[_id].capacity = _capacity;
        venuesRegister[_id].standardComission = _standardComission;
    }

    function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _price) public {
        _numberOfConcerts++;
        concertsRegister[_numberOfConcerts] = Concert(msg.sender, _artistId, _numberOfConcerts, _venueId, _concertDate, _price, 0, 0, false, false, true);
        validateConcert(_numberOfConcerts);
    }

    function validateConcert(uint _concertId) public {
        require(concertsRegister[_concertId].concertDate >= now);

        if (venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender) {
            concertsRegister[_concertId].validatedByVenue = true;
        }

        if (artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender) {
            concertsRegister[_concertId].validatedByArtist = true;
        }
    }

    // Emitted ticket are not sold
    function emitTicket(uint _concertId, address _receiver) public {
        require(msg.sender == concertsRegister[_concertId].creator);
        Concert storage concert = concertsRegister[_concertId];
        artistsRegister[concert.artistId].totalTicketSold++;
        concert.totalSoldTicket++;
        _numberOfTickets++;
        ticketsRegister[_numberOfTickets] = Ticket(_receiver, concert.artistId, _concertId, concert.venueId, concert.concertDate, concert.price, 0, false, true, false);
    }

    /**
     * @dev Get number of days since epoch regardless leap years
     * @param timestamp current timestamp
     * @return Number of days
     */
    function getNumberOfDaysSinceEpoch(uint timestamp) private pure returns (uint) {
        // 1 day == 86400 seconds
        return timestamp / 86400;
    }

    function useTicket(uint _ticketId) public {
        require(msg.sender == ticketsRegister[_ticketId].owner);

        // require(ticketsRegister[_ticketId].concertDate <= now);              does not take into account the actual day

        // require(getNumberOfDaysSinceEpoch(ticketsRegister[_ticketId].concertDate) == getNumberOfDaysSinceEpoch(now));   does not work either

        // can use the ticket at least 24 hours before the concert date
        require(ticketsRegister[_ticketId].concertDate <= now + 1 days);  // 1 day = 86400 seconds
        require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByVenue);
        Ticket storage ticket = ticketsRegister[_ticketId];
        ticket.owner = address(0);
        ticket.isAvailable = false;
        ticket.isRefundable = false;
        if (ticket.isAvailableForSale) {
            ticket.isAvailableForSale = false;
            ticket.salePrice = 0;
        }
    }

    function buyTicket(uint _concertId) public payable {
        Concert storage concert = concertsRegister[_concertId];
        artistsRegister[concert.artistId].totalTicketSold++;
        concert.totalSoldTicket++;
        concert.totalMoneyCollected += msg.value;
        _numberOfTickets++;
        ticketsRegister[_numberOfTickets] = Ticket(msg.sender, concert.artistId, _concertId, concert.venueId, concert.concertDate, msg.value, 0, true, true, false);
    }

    function transferTicket(uint _ticketId, address _receiver) public {
        require(msg.sender == ticketsRegister[_ticketId].owner);
        ticketsRegister[_ticketId].owner = _receiver;
    }

    function cashOutConcert(uint _concertId, address payable _cashOutAddress) public {
        require(now >= concertsRegister[_concertId].concertDate);
        require(msg.sender == concertsRegister[_concertId].creator);
        Concert storage concert = concertsRegister[_concertId];
        Venue storage venue = venuesRegister[concert.venueId];
        uint venueShare = concert.totalMoneyCollected * venue.standardComission / 10000;
        uint artistShare = concert.totalMoneyCollected - venueShare;
        venue.owner.transfer(venueShare);
        _cashOutAddress.transfer(artistShare);
        concert.totalMoneyCollected = 0;
    }

    function offerTicketForSale(uint _ticketId, uint _salePrice) public {
        require(msg.sender == ticketsRegister[_ticketId].owner);
        require(_salePrice <= ticketsRegister[_ticketId].amountPaid);
        ticketsRegister[_ticketId].isAvailableForSale = true;
        ticketsRegister[_ticketId].salePrice = _salePrice;
    }

    function buySecondHandTicket(uint _ticketId) public payable {
        require(ticketsRegister[_ticketId].isAvailableForSale);
        require(msg.value == ticketsRegister[_ticketId].salePrice);
        ticketsRegister[_ticketId].owner = msg.sender;
        ticketsRegister[_ticketId].amountPaid = msg.value;
        if (!ticketsRegister[_ticketId].isRefundable) {
            ticketsRegister[_ticketId].isRefundable = true;
        }
    }

    function redeemTicket(uint _ticketId) public {
        require(msg.sender == ticketsRegister[_ticketId].owner);
        require(!concertsRegister[ticketsRegister[_ticketId].concertId].isOver);
        require(ticketsRegister[_ticketId].isRefundable);
        Ticket memory ticket = ticketsRegister[_ticketId];
        Concert storage concert = concertsRegister[ticket.concertId];
        concert.totalSoldTicket--;
        concert.totalMoneyCollected -= ticket.amountPaid;
        msg.sender.transfer(ticket.amountPaid);
    }

    /**
    * get item data by id
    */
    function getArtist(uint256 id) public view returns (address, bytes32, uint256, uint256) {
        Artist memory artist = artistsRegister[id];
        return (artist.owner, artist.name, artist.artistCategory, artist.totalTicketSold);
    }
}