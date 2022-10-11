pragma solidity ^0.8.0;

interface IERC1155 {
    function addAsset(string memory assetname, uint256 price)
        external
        returns (uint256);

    function mint(uint256 id, uint256 amount) external;

    function updatelock(uint256 assetid, uint256 amount) external;
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function subtract(address owner, uint256 amount) external;

    function mintnew(uint256 amount, address to) external;

    function burn(address to, uint256 amount) external;
}

/* is ERC165 */
interface ERC721 {
    function mint(address starter) external;

    function lock(uint256 minerid, uint256 townhallid) external;

    function unlock(uint256 minerid, uint256 townhallid) external;

    function updatelock(
        uint256 minerid,
        uint256 townhallid,
        uint256 amount
    ) external;

    function collect(uint256 id) external returns (uint256);
}

contract NomadMain {
    address public owner;
    uint256 public totalisland;
    address public maincurrency;
    struct Asset {
        string Name;
        uint256 id;
        address contractadd;
        uint256 price;
        bool tokentype;
    }
    struct User {
        bool gamestarted;
        uint256 position;
        uint256 health;
        uint256 sleep;
        uint256 food;
        uint256 lastmoved;
        uint256 lastcalled;
    }

    struct Markettype {
        string name;
        address owner;
        uint256 assettype;
        uint256 price;
        uint256 boost;
        uint256 position;
        uint256 marketprice;
        bool onsale;
    }

    mapping(address => bool) public letgame;

    mapping(address => User) public gameuser;
    mapping(uint256 => Asset) public assets;
    mapping(uint256 => Markettype) public markets;
    uint256 public currentcount = 0;
    uint256 public movedifference = 2;
    uint256 public totalmarket = 0;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = tx.origin;
    }

    function addAsset721(
        string memory name,
        address contractadd,
        uint256 price
    ) public onlyOwner {
        Asset memory asset = Asset(name, 0, contractadd, price, false);
        assets[currentcount] = asset;
    }


    function changemaincurrency(address name) public{
        require(tx.origin == owner);
        maincurrency = name;

    }

    function addAsset1155(
        string memory name,
        address contractadd,
        uint256 price
    ) public onlyOwner {
        uint256 id = IERC1155(contractadd).addAsset(name, price);
        Asset memory asset = Asset(name, id, contractadd, price, true);
        assets[currentcount] = asset;
    }

    function updatetotalisland(uint256 number) public onlyOwner {
        totalisland = number;
    }

    function assetdetails(uint256 id) public view returns (Asset memory) {
        return assets[id];
    }

    function userdetails(address addr) public view returns (User memory) {
        return gameuser[addr];
    }

    function getcoin(address addr) public view returns (uint256) {
        return IERC20(maincurrency).balanceOf(addr);
    }

    

    function startgame() public {
        require(letgame[tx.origin] == false );
        if (tx.origin == owner) {
            IERC20(maincurrency).mintnew(5000, tx.origin);
        }
        uint256 position = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        ) % totalisland;
        gameuser[tx.origin] = User(
            true,
            position,
            100,
            100,
            100,
            0,
            block.number
        );
        IERC20(maincurrency).mintnew(1000, tx.origin);
        letgame[tx.origin] == true;
    }

    function move() public {
        require(gameuser[tx.origin].lastmoved + movedifference < block.number);
        uint256 position = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        ) % totalisland;

        update();
        gameuser[tx.origin].lastmoved = block.number;
        gameuser[tx.origin].position = position;
    }

    function reward3() public returns (uint256) {
        uint256 position = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        ) % 100;
        if (position <= 33) {
            if (position == 33) {
                return 25;
            } else if (position % 3 == 0) {
                return 1;
            } else {
                return 0;
            }
        } else if (position <= 66) {
            if (position == 66) {
                return 2;
            } else if (position % 3 == 0) {
                return 1;
            } else {
                return 0;
            }
        } else {
            if (position == 99) {
                return 2;
            } else if (position % 3 == 0) {
                return 1;
            } else {
                return 0;
            }
        }
    }

    function update() public {
        uint256 effect = (block.number - gameuser[tx.origin].lastcalled) / 3800;
        uint256 select = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp))
        ) % 3;
        if (select == 0) {
            gameuser[tx.origin].health -= effect;
        } else if (select == 1) {
            gameuser[tx.origin].sleep -= effect;
        } else if (select == 2) {
            gameuser[tx.origin].food -= effect;
        }

        gameuser[tx.origin].lastcalled = block.number;
    }

    function addmarket(
        string memory name,
        uint256 assettype,
        uint256 effect,
        uint256 price,
        uint256 position,
        uint256 marketprice
    ) public onlyOwner {
        require(position <= totalisland);
        require(effect <= 100);
        require(assettype < 3);
       
        markets[totalmarket++] = Markettype(
            name,
            owner,
            assettype,
            price,
            effect,
            position,
            marketprice,
            true
        );
    }

    function marketdetails() public view returns (Markettype[] memory) {
        Markettype[] memory lmarkets = new Markettype[](totalmarket);
        for (uint256 i = 0; i < totalmarket; i++) {
            Markettype storage lBid = markets[i];
            lmarkets[i] = lBid;
        }
        return lmarkets;
    }

    function buymarket(uint256 id)  public{
        require(markets[id].owner != tx.origin);
     
        require(markets[id].onsale == true);
        require(
            markets[id].marketprice < IERC20(maincurrency).balanceOf(tx.origin)
        );

        IERC20(maincurrency).burn(tx.origin, markets[id].marketprice);
        markets[id].onsale = false;
        markets[id].owner = tx.origin;
        update();
    }

    function sellmarket(uint256 id, uint256 price) public {
        require(markets[id].owner == tx.origin);
        markets[id].onsale = true;
        markets[id].marketprice = price;
        update();
    }


    function executemarket(uint256 marketid) public {
        update();
        IERC20(maincurrency).subtract(tx.origin, markets[marketid].price);
        uint256 select = markets[marketid].assettype;
        uint256 effect = markets[marketid].boost;
        if (select == 0) {
            gameuser[tx.origin].health += effect;
            if (gameuser[tx.origin].health > 100) {
                gameuser[tx.origin].health = 100;
            }
        } else if (select == 1) {
            gameuser[tx.origin].sleep += effect;
            if (gameuser[tx.origin].sleep > 100) {
                gameuser[tx.origin].sleep = 100;
            }
        } else if (select == 2) {
            gameuser[tx.origin].food += effect;
            if (gameuser[tx.origin].food > 100) {
                gameuser[tx.origin].food = 100;
            }
        }
    }
}
