pragma solidity ^0.4.24;

contract DrugOn {


    /**
     * Medic
     *
     * Struct holding the profile deatils of the Medic.
     */
    struct Medic {
        uint creationDate;      // date user was created
        string medicname;        // username of the user
        address medic;           // associated medic
        address owner;          // address of the account who created the user
        address[] patients;
    }

    /**
     * Patient
     *
     * Struct holding the profile deatils of the Patient.
     */
    struct Patient {
        uint creationDate;      // date user was created
        string patientID;        // username of the user
        address medic;           // associated medic
        string[] prescription;   // array that holds the user's tweets
    }

    /**
     * patients
     *
     * Maps the keccak256 hash of a username to the details of the user
     *
     * {bytes32} [KEY] the keccak256 hash of the username
     * {User} the User struct containing the deatils of the user
     */
    mapping (bytes32 => Patient) public patients;

    
    /**
     * medics
     *
     * Maps the address of the owner account to the username hash of the 
     * owned user. This is needed so we can retrieve an account from the
     * current address
     *
     * {address} [KEY] the address of the owner who owns the user
     * {bytes32} the keccak256 hash of the username
     */
    mapping (address => bytes32) public medics;

    /**
     * owners
     *
     * Maps the address of the owner account to the username hash of the
     * owned user. This is needed so we can retrieve an account from the
     * current address
     *
     * {address} [KEY] the address of the owner who owns the user
     * {bytes32} the keccak256 hash of the username
     */
    mapping (address => bytes32) public owners;

    /**
     * NewPrescription
     *
     * Event to be emitted once a tweet is stored in the contract
     * {bytes32} _from - keccak256-hashed username of user who posted the tweet.
     * This field is indexed so it can be filtered.
     * {string} tweet - the tweet contents
     */
    event NewPrescription(
        bytes32 indexed _from,
        string prescription,
        uint expiringtime,
        uint time
    );


    /**
     * createMedic
     *
     * Creates a user account, storing the user (and user details) in the contract.
     * Additionally, a mapping is created between the owner who created the user
     * (msg.sender) and the keccak256-hash of the username
     * {string} username - the username of the user
     * {string} description - the user profile description
     */
    function createMedic(string medicName) public {
        // ensure a null or empty string wasn't passed in
        require(bytes(medicName).length > 0);

        // generate the username hash using keccak
        bytes32 medicNamehash = keccak256(abi.encodePacked(medicName));

        // reject if username already registered
        require(medics[medicNamehash].creationDate == 0);

        // reject if sending adddress already created a user
        require(owners[msg.sender] == 0);

        // add a user to the users mapping and populate details
        users[usernameHash].creationDate = now;
        users[usernameHash].owner = msg.sender;
        users[usernameHash].medicname = medicName;

        // add entry to our owners mapping so we can retrieve
        // user by their address
        owners[msg.sender] = medicNamehash;
    }

    /**
     * createPatient
     *
     * Creates a user account, storing the user (and user details) in the contract.
     * Additionally, a mapping is created between the owner who created the user
     * (msg.sender) and the keccak256-hash of the username
     * {string} username - the username of the user
     * {string} description - the user profile description
     */
    function createPatient(string patientID) public {
        // ensure a null or empty string wasn't passed in
        require(bytes(patientID).length > 0);

        // generate the username hash using keccak
        bytes32 patientHash = keccak256(abi.encodePacked(username));

        // reject if username already registered
        require(patients[patientHash].creationDate == 0);

        // reject if sending adddress already created a user
        require(medics[msg.sender] != 0);

        // add a user to the users mapping and populate details

        users[usernameHash].creationDate = now;
        users[usernameHash].medic = msg.sender;
        users[usernameHash].username = username;

        medics[msg.sender].patients[patientID] = patientHash;

        // add entry to our owners mapping so we can retrieve
        // user by their address
        patients[patientHash] = patientID;
    }

    /**
     * patientExists
     *
     * Validates whether or not a user has an account in the user mapping
     * {bytes32} usernameHash - the keccak256-hashed username of the user to validate
     * {bool} - returns true if the hashed username exists in the user mapping, false otherwise
     */
    function patientExists(bytes32 patientHash) public view returns (bool) {
        // must check a property... bc solidity!
        return patients[patientHash].creationDate != 0;
    }

    /**
     * medicExists
     *
     * Validates whether or not a user has an account in the user mapping
     * {bytes32} usernameHash - the keccak256-hashed username of the user to validate
     * {bool} - returns true if the hashed username exists in the user mapping, false otherwise
     */
    function medicExists(bytes32 medicNameHash) public view returns (bool) {
        // must check a property... bc solidity!
        return medics[medicNameHash].creationDate != 0;
    }

    /**
     * createPrescription
     *
     * Adds a tweet to the user's tweets and emits an event notifying listeners
     * that a tweet happened. Assumes the user sending the transaction is the tweeter.
     * {string} content - the tweet content
     */
    function createPrescription(string content, string patientID) public {
        // ensure the sender has an account
        require(medics[msg.sender].length > 0);

        require(medics[msg.sender].patients[patientID].length > 0);

        // get the username hash of the sender's account
        bytes32 medicHash = owners[msg.sender];

        // get our user
        Patient storage patient = patients[medics[msg.sender].patients[patientID]];

        // get our new tweet index
        uint prescriptionIndex = patient.prescription.length++;

        // update the user's tweets
        patient.prescription[prescriptionIndex] = content;

        // emit the tweet event and notify the listeners
        emit NewPrescription(medicHash, content, now);
    }

}