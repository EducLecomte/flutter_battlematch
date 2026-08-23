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
<header class="w3-center w3-black w3-padding-32 w3-opacity">
    <h2>ACCUEIL</h2>
</header><br>
<div class="w3-center">
    <form action="index.php"  method="POST">
        <input type="text" required name="nomTo" placeholder="Nom du tournoi" maxlength="48">
        <input type="text" name="lienNR" placeholder="Liens NR"><br>
        <input type="submit" value="Ajouter le tournoi">
    </form><br>
    <?php
// AJOUT DE TOURNOI SI $_POST
if (isset($_POST["nomTo"]) && isset($_POST["lienNR"]) && !isset($_POST["edit"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);
        // AJOUT DU TOURNOI
        $stmt = $bdd->prepare("INSERT INTO MW_Tournoi (nomTo, lienNR) VALUES (:nomTo, :lienNR);");
        $stmt->bindParam(':nomTo', $_POST["nomTo"]);
        $stmt->bindParam(':lienNR', $_POST["lienNR"]);
        $stmt->execute();

    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
}

// EDITION DE TOURNOI SI EDIT
if (isset($_POST["edit"]) && isset($_POST["idTo"]) && isset($_POST["nomTo"]) && isset($_POST["lienNR"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);
        $stmt = $bdd->prepare("UPDATE MW_Tournoi SET nomTo=:nomTo, lienNR=:lienNR WHERE idTo=:idTo;");
        $stmt->bindParam(':nomTo', $_POST["nomTo"]);
        $stmt->bindParam(':lienNR', $_POST["lienNR"]);
        $stmt->bindParam(':idTo', $_POST["idTo"]);
        $stmt->execute();
    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
}
// SUPPRESSION DE TOURNOI SI DELETE
if (isset($_POST["delete"]) && isset($_POST["idTo"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);

        $stmt = $bdd->prepare("SELECT DISTINCT idTe FROM MW_Team WHERE idTo=:idTo;");
        $stmt->bindParam(':idTo', $_POST["idTo"]);
        $stmt->execute();
        while ($donnees = $stmt->fetch()) {
            $stmt2 = $bdd->prepare("DELETE FROM MW_Estim WHERE idTe=:idTe;");
            $stmt2->bindParam(':idTe', $donnees["idTe"]);
            $stmt2->execute();
            $stmt2 = $bdd->prepare("DELETE FROM MW_MetaAdv WHERE idTe=:idTe;");
            $stmt2->bindParam(':idTe', $donnees["idTe"]);
            $stmt2->execute();
            $stmt2 = $bdd->prepare("DELETE FROM MW_Team WHERE idTo=:idTo;");
            $stmt2->bindParam(':idTo', $_POST["idTo"]);
            $stmt2->execute();
        }

        $stmt = $bdd->prepare("DELETE FROM MW_Tournoi WHERE idTo=:idTo;");
        $stmt->bindParam(':idTo', $_POST["idTo"]);
        $stmt->execute();
    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
}

// AFFICHAGE DE LA LISTE DES TOURNOIS
try {
    $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);

    $stmt = $bdd->prepare("SELECT * FROM MW_Tournoi ORDER BY idTo DESC;");
    $stmt->execute();

    if ($stmt->rowCount() >= 1) {
        echo '<table class="w3-table-all">';
        echo '<tr><th>Nom Tournoi</th><th>Lien NR</th><th>Modif</th><th>Suppr</th></tr>';
        while ($donnees = $stmt->fetch()) {
            echo '<tr>';
            // colone nom + liens
            echo '<td><form action="tournoi.php"  method="POST">';
            echo '<input type="hidden" value="' . $donnees['idTo'] . '" name="idTo">';
            echo '<input type="hidden" value="' . $donnees['nomTo'] . '" name="nomTo">';
            echo '<button type="submit" >' . $donnees['nomTo'] . '</button></form></td>';
            // colonne lien NR + redirection
            if ( $donnees['lienNR']!="") {
                echo '<td><a target="_blank" href="' . $donnees['lienNR'] . '">';
                echo substr($donnees['lienNR'], 0, 16) . '...</a></td>';
            }else{
                echo '<td></td>';
            }
            // colonne editer tournoi
            echo '<td><form action="editTournoi.php"  method="POST">
                    <input type="hidden" value="' . $donnees['idTo'] . '" name="idTo">
                    <button type="submit" ><i class="fa fa-edit w3-text-green"></i></button>
                </form>
            </td>';
            // colonne supprimer tournoi
            echo '<td><form action="index.php"  method="POST">
             <input type="hidden" value="' . $donnees['idTo'] . '" name="idTo">
             <input type="hidden" value="" name="delete">
             <button type="submit" ><i class="fa fa-trash w3-text-red"></i></button>
         </form>
     </td>';
            echo '</tr>';
        }
        echo '</table>';
        $stmt->closeCursor();
    } else {
        echo '<label class="w3-text-deep-orange">Aucun tournoi n\'est inscrit.</label>';

    }
    $stmt->closeCursor();
} catch (Exception $except) {
    die('Erreur: ' . $except->getMessage());
}

?>

</div>

<!-- Footer -->
<br>
<footer class=" w3-center w3-black w3-padding-32 w3-opacity w3-hover-opacity-on">
</footer>

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
