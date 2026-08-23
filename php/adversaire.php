
<?php
require "config.php";
?>
<!DOCTYPE html>
<html>
<head>
<title>MetaWar</title>
<meta name="description" content=""/>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta charset="UTF-8">
<link rel="icon" type="image/x-icon" href="img/sunfav.jpg">
<link rel="stylesheet" href="css/w3.css">
<link rel="stylesheet" href="css/css2.css">
<link rel="stylesheet" href="css/font-awesome.min.css">
<style>
body,h1,h2,h3,h4,h5,h6 {font-family: "Lato", sans-serif;}
body, html {
    height: 100%;
    color: #777;
    line-height: 1.8;
}
.footer {
  position: fixed;
  left: 0;
  bottom: 0;
  width: 100%;
}
/* Create a Parallax Effect */
.bgimg-1 {
    background-attachment: fixed;
    background-position: center;
    background-repeat: no-repeat;
    background-size: cover;
}

/* First image (Logo. Full height) */
.bgimg-1 {
    background-image: url("img/geoGP.jpg");
    min-height: 42px;
}

.w3-wide {letter-spacing: 10px;}
.w3-hover-opacity {cursor: pointer;}

/* Turn off parallax scrolling for tablets and phones */
@media only screen and (max-device-width: 1024px) {
    .bgimg-1 {
        background-attachment: scroll;
    }
}

pre {
    white-space: pre-wrap;
}
</style>
</head>

<body>

<!-- Navbar (sit on top) -->
<div class="w3-top">
  <div class="w3-bar" id="myNavbar">
    <a class="w3-bar-item w3-button w3-hover-black w3-hide-medium w3-hide-large w3-right" href="javascript:void(0);" onclick="toggleFunction()" title="Toggle Navigation Menu">
      <i class="fa fa-bars"></i>
    </a>
    <a href="index.php" class="w3-bar-item w3-button w3-text-black">ACCUEIL</a>
    <a href="#" class="w3-bar-item w3-button w3-hide-small w3-right w3-hover-green">
      <i class="fa fa-angle-up"></i>
    </a>
  </div>
   <!-- Navbar on small screens -->
   <div id="navDemo" class="w3-bar-block w3-white w3-hide w3-hide-large w3-hide-medium">
    <a href="index.php" class="w3-bar-item w3-button" onclick="toggleFunction()">ACCUEIL</a>

  </div>
</div>

<!-- First Parallax Image with Logo Text -->
<div class="bgimg-1 w3-display-container w3-opacity-min" id="home">
  <div class="w3-display-middle" style="white-space:nowrap;">
  </div>
</div>

<?php
if (isset($_POST["idTe"]) && isset($_POST["idAr"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);
        $stmt = $bdd->prepare("SELECT * FROM MW_MetaAdv WHERE idTe=:idTe AND idAr=:idAr;");
        $stmt->bindParam(':idTe', $_POST["idTe"]);
        $stmt->bindParam(':idAr', $_POST["idAr"]);
        $stmt->execute();
        $donnees = $stmt->fetch();
        
            echo '<header class="w3-center w3-black w3-padding-32 w3-opacity"><h2>ADVERSAIRE : '.$donnees["nomJoAdv"].'</h2></header><div class="w3-margin-left">';
            echo '<pre>'.$donnees["listeAdv"].'</pre>';
            echo '<form action="team.php"  method="POST">
            <input type="hidden" value="' . $_POST["idTe"]. '" name="idTe">
            <input type="hidden" value="' . $_POST["idAr"] . '" name="idAr">
            <input type="hidden" value="" name="delete">
            <input type="hidden" value="" name="joAdv">
            <button type="submit" ><i class="fa fa-trash w3-text-red"></i></button>
            </form>';
    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
} else {
    header('Location: index.php');
}

?>




</div>

<!-- Footer -->
<br>
<footer class=" w3-center w3-black w3-padding-32 w3-opacity w3-hover-opacity-on">
<form action="team.php"  method="POST">
    <input type="hidden" value="<?php echo $_POST["idTe"]; ?>" name="idTe">
    <input type="submit" value="Retour arrière">
</form></footer>

<script>

// Change style of navbar on scroll
window.onscroll = function() {myFunction()};
function myFunction() {
    var navbar = document.getElementById("myNavbar");
    if (document.body.scrollTop > 50 || document.documentElement.scrollTop > 50) {
        navbar.className = "w3-bar" + " w3-card" + " w3-animate-top" + " w3-white";
    } else {
        navbar.className = navbar.className.replace(" w3-card w3-animate-top w3-white", "");
    }
}

// Used to toggle the menu on small screens when clicking on the menu button
function toggleFunction() {
    var x = document.getElementById("navDemo");
    if (x.className.indexOf("w3-show") == -1) {
        x.className += " w3-show";
    } else {
        x.className = x.className.replace(" w3-show", "");
    }
}
</script>

</body>
</html>
