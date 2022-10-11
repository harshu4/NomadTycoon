const Migrations = artifacts.require("Migrations");
const Nomadmain = artifacts.require("NomadMain")
const Dollarino = artifacts.require("Dollarino")
module.exports = async function (deployer) {
  mig = await deployer.deploy(Migrations);
  nom = await deployer.deploy(Nomadmain);
  dom = await deployer.deploy(Dollarino);
  let change = await nom.changemaincurrency(dom.address);
 change = await  dom.changeowner(nom.address);
  change = await nom.updatetotalisland(4);
  change = await nom.addmarket(
      "Hotel",
     1,
     15,
     200,
     0,
     100,
)
change = await nom.addmarket(
  "Medical",
 0,
 15,
 300,
 0,
 150,
)
change = await nom.addmarket(
  "Restaurant",
 2,
 20,
 100,
 0,
 70,
)
change = await nom.addmarket(
  "Hotel",
 1,
 15,
 200,
 1,
 100,
)
change = await nom.addmarket(
"Medical",
0,
15,
300,
1,
150,
)
change = await nom.addmarket(
"Restaurant",
2,
20,
100,
1,
70,
)
change = await nom.addmarket(
  "Hotel",
 1,
 15,
 200,
 2,
 100,
)
change = await nom.addmarket(
"Medical",
0,
15,
300,
2,
150,
)
change = await nom.addmarket(
"Restaurant",
2,
20,
100,
2,
70,
)
change = await nom.addmarket(
  "Hotel",
 1,
 15,
 200,
 3,
 100,
)
change = await nom.addmarket(
"Medical",
0,
15,
300,
3,
150,
)
change = await nom.addmarket(
"Restaurant",
2,
20,
100,
3,
70,
)
}

