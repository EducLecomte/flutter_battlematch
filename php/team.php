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
    <h2>TEAM - <?php
if (isset($_POST["idTe"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);
        $stmt = $bdd->prepare("SELECT nomTe FROM MW_Team WHERE idTe=:idTe;");
        $stmt->bindParam(':idTe', $_POST["idTe"]);
        $stmt->execute();
        $donnees = $stmt->fetch();
        echo $donnees["nomTe"];
    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
} else {
    header('Location: index.php');
}
?></h2>
    </header>
    <div class="w3-center"><br>
    <form action="addJoueurAdv.php"  method="POST">
        <input type="hidden" value="<?php echo $_POST["idTe"]; ?>" name="idTe">
        <input  type="submit" value="Ajouter un Adversaire">
    </form><br>

<?php
// AJOUT JOUEUR
if (isset($_POST["idTe"]) && isset($_POST["idAr"]) && isset($_POST["nomJoAdv"]) && isset($_POST["listeAdv"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);
        $stmt = $bdd->prepare("INSERT INTO MW_MetaAdv (idTe, idAr, nomJoAdv, listeAdv) VALUES (:idTe, :idAr, :nomJoAdv, :listeAdv);");
        $stmt->bindParam(':idTe', $_POST["idTe"]);
        $stmt->bindParam(':idAr', $_POST["idAr"]);
        $stmt->bindParam(':nomJoAdv', $_POST["nomJoAdv"]);
        $stmt->bindParam(':listeAdv', $_POST["listeAdv"]);
        $stmt->execute();
    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
}

// SUPPRESSION JOUEURADV
if (isset($_POST["delete"]) && isset($_POST["joAdv"]) && isset($_POST["idTe"]) && isset($_POST["idAr"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);
        $stmt = $bdd->prepare("DELETE FROM MW_Estim WHERE idTe=:idTe AND idAr=:idAr;");
        $stmt->bindParam(':idTe', $_POST["idTe"]);
        $stmt->bindParam(':idAr', $_POST["idAr"]);
        $stmt->execute();
        $stmt = $bdd->prepare("DELETE FROM MW_MetaAdv WHERE idTe=:idTe AND idAr=:idAr;");
        $stmt->bindParam(':idTe', $_POST["idTe"]);
        $stmt->bindParam(':idAr', $_POST["idAr"]);
        $stmt->execute();
    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
}

// AJOUT ESTIMATION
if (isset($_POST["estim"]) && isset($_POST["idTe"])) {

    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);

        $stmt = $bdd->prepare("SELECT count(*) AS nbAdv FROM MW_MetaAdv WHERE idTe=:idTe ;");
        $stmt->bindParam(':idTe', $_POST["idTe"]);
        $stmt->execute();
        $donnees = $stmt->fetch();
        $nbAdv = $donnees["nbAdv"];

        for ($i = 1; $i <= $nbAdv; $i++) {
            $stmt = $bdd->prepare("INSERT INTO MW_Estim (idJo, idTe, idAr, idCh) VALUES (:idJo, :idTe, :idAr, :idCh);");
            $stmt->bindParam(':idJo', $_POST["idJo"]);
            $stmt->bindParam(':idTe', $_POST["idTe"]);
            $stmt->bindParam(':idAr', $_POST["idAr" . $i . ""]);
            $stmt->bindParam(':idCh', $_POST["idCh" . $i . ""]);
            $stmt->execute();
        }
    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
}
// EDITION ESTIM
if (isset($_POST["edit"]) && isset($_POST["estim"]) && isset($_POST["idTe"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);

        $stmt = $bdd->prepare("SELECT count(*) AS nbAdv FROM MW_MetaAdv WHERE idTe=:idTe ;");
        $stmt->bindParam(':idTe', $_POST["idTe"]);
        $stmt->execute();
        $donnees = $stmt->fetch();
        $nbAdv = $donnees["nbAdv"];

        for ($i = 1; $i <= $nbAdv; $i++) {
            $stmt = $bdd->prepare("UPDATE MW_Estim SET idCh=:idCh WHERE idTe=:idTe AND idJo=:idJo AND idAr=:idAr ;");
            $stmt->bindParam(':idJo', $_POST["idJo"]);
            $stmt->bindParam(':idTe', $_POST["idTe"]);
            $stmt->bindParam(':idAr', $_POST["idAr" . $i . ""]);
            $stmt->bindParam(':idCh', $_POST["idCh" . $i . ""]);
            $stmt->execute();
        }
    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
}

// SUPPRESSION ESTIM
if (isset($_POST["delete"]) && isset($_POST["estim"]) && isset($_POST["idTe"]) && isset($_POST["idJo"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);
        $stmt = $bdd->prepare("DELETE FROM MW_Estim WHERE idTe=:idTe AND idJo=:idJo;");
        $stmt->bindParam(':idTe', $_POST["idTe"]);
        $stmt->bindParam(':idJo', $_POST["idJo"]);
        $stmt->execute();
    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
}

// MATCHED
if (isset($_POST["matched"]) && isset($_POST["idTe"]) && isset($_POST["idAr"]) && isset($_POST["idJo"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);

        $stmt = $bdd->prepare("INSERT INTO MW_Matched (idTe, idJo, idAr) VALUES (:idTe, :idJo, :idAr);");
        $stmt->bindParam(':idTe', $_POST["idTe"]);
        $stmt->bindParam(':idJo', $_POST["idJo"]);
        $stmt->bindParam(':idAr', $_POST["idAr"]);
        $stmt->execute();

    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
}
// UNMATCHED
if (isset($_POST["unmatched"]) && isset($_POST["idTe"]) && isset($_POST["idAr"]) && isset($_POST["idJo"])) {
    try {
        $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);

        $stmt = $bdd->prepare("DELETE FROM MW_Matched WHERE idTe=:idTe AND idJo=:idJo AND idAr=:idAr;");
        $stmt->bindParam(':idTe', $_POST["idTe"]);
        $stmt->bindParam(':idJo', $_POST["idJo"]);
        $stmt->bindParam(':idAr', $_POST["idAr"]);
        $stmt->execute();
    } catch (Exception $except) {
        die('Erreur: ' . $except->getMessage());
    }
}

// AFFICHAGE TEAM

try {
    $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);

    echo '<center><table>';
    // AFFICHAGE ENTETE
    $stmt = $bdd->prepare("SELECT * FROM MW_MetaAdv AS meta, MW_Armee as armee WHERE idTe=:idTe AND meta.idAr=armee.idAr;");
    $stmt->bindParam(':idTe', $_POST["idTe"]);
    $stmt->execute();
    if ($stmt->rowCount() >= 1) {
        echo '<tr><th>Nom Joueur </th>';
        while ($donnees = $stmt->fetch()) {
            // colonne armée
            echo '<th><form action="adversaire.php"  method="POST">';
            echo '<input type="hidden" value="' . $donnees['idTe'] . '" name="idTe">';
            echo '<input type="hidden" value="' . $donnees['idAr'] . '" name="idAr">';
            echo '<button type="submit" >' . $donnees['short'] . '</button></form></th>';

        }
        echo '</tr>';
        $stmt->closeCursor();
    } else {
        echo '<label class="w3-text-deep-orange">Aucun adversaire n\'est inscrit.</label>';
    }

    // AFFICHE LIGNE ESTIM
    $stmt = $bdd->prepare("SELECT DISTINCT joueur.idJo as joidJo, joueur.short as joShort, nomJo FROM MW_Estim AS estim, MW_Joueur AS joueur WHERE idTe=:idTe AND estim.idJo=joueur.idJo ;");
    $stmt->bindParam(':idTe', $_POST["idTe"]);
    $stmt->execute();
    if ($stmt->rowCount() >= 1) {
        while ($donnees = $stmt->fetch()) {
            echo '<tr>';

            // colonne nom joueur
            echo '<td><form action="editEstim.php"  method="POST">';
            echo '<input type="hidden" value="' . $_POST["idTe"] . '" name="idTe">
            <input type="hidden" value="' . $donnees['joidJo'] . '" name="idJo">';
            echo '<button class="w3-hide-small" type="submit">' . $donnees['nomJo'] . '</button>';
            echo '<button class="w3-hide-large w3-hide-medium" type="submit">' . $donnees['joShort'] . '</button>';
            echo '</form></td>';

            // ligne joueur estim
            // // valeur des estimation
            $stmt2 = $bdd->prepare("SELECT choix.idCh as chidCh, choix.short as chShort, idAr FROM MW_Estim AS estim, MW_Choix AS choix WHERE idTe=:idTe AND idJo=:idJo AND estim.idCh=choix.idCh ORDER BY idAr;");
            $stmt2->bindParam(':idTe', $_POST["idTe"]);
            $stmt2->bindParam(':idJo', $donnees["joidJo"]);
            $stmt2->execute();
            //  // savoir si le joueur est matched
            $stmt3 = $bdd->prepare("SELECT * FROM MW_Matched WHERE idTe=:idTe AND idJo=:idJo ;");
            $stmt3->bindParam(':idTe', $_POST["idTe"]);
            $stmt3->bindParam(':idJo', $donnees["joidJo"]);
            $stmt3->execute();

            while ($donnees2 = $stmt2->fetch()) {
                //  // savoir si l'adversaire est matched
                $stmt4 = $bdd->prepare("SELECT * FROM MW_Matched WHERE idTe=:idTe AND idAr=:idAr ;");
                $stmt4->bindParam(':idTe', $_POST["idTe"]);
                $stmt4->bindParam(':idAr', $donnees2["idAr"]);
                $stmt4->execute();

                if ($stmt3->rowCount() < 1) {
                    if ($stmt4->rowCount() < 1) {
                        if ($donnees2['chidCh'] == "1") {
                            $color = "w3-grey";
                        } elseif ($donnees2['chidCh'] == "2") {
                            $color = "w3-brown";
                        } elseif ($donnees2['chidCh'] == "3") {
                            $color = "w3-red";
                        } elseif ($donnees2['chidCh'] == "4") {
                            $color = "w3-yellow";
                        } elseif ($donnees2['chidCh'] == "5") {
                            $color = "w3-green";
                        } elseif ($donnees2['chidCh'] == "6") {
                            $color = "w3-blue";
                        }
                        //echo '<td class="w3-center ' . $color . '">' . $donnees2['chShort'] . '</td>';
                        echo '<td class="w3-center ' . $color . '">';
                        echo '<form action="team.php"  method="POST">
                        <input type="hidden" value="" name="matched">
                        <input type="hidden" value="' . $_POST['idTe'] . '" name="idTe">
                        <input type="hidden" value="' . $donnees['joidJo'] . '" name="idJo">
                        <input type="hidden" value="' . $donnees2['idAr'] . '" name="idAr">';
                        echo '<input class="w3-btn w3-padding-small ' . $color . '" type="submit" value="' . $donnees2['chShort'] . '">';
                        echo '</form>';
                        echo '</td>';
                    } else {
                        //echo '<td class="w3-center ">' . $donnees2['chShort'] . '</td>';
                        echo '<td class="w3-center">' . $donnees2['chShort'] . '</td>';

                    }
                } else {
                    //  // savoir si l'adversaire et joueur sont matched
                    $stmt5 = $bdd->prepare("SELECT * FROM MW_Matched WHERE idTe=:idTe AND idJo=:idJo AND idAr=:idAr ;");
                    $stmt5->bindParam(':idTe', $_POST["idTe"]);
                    $stmt5->bindParam(':idJo', $donnees["joidJo"]);
                    $stmt5->bindParam(':idAr', $donnees2["idAr"]);
                    $stmt5->execute();
                    if ($stmt5->rowCount() < 1) {
                        echo '<td class="w3-center">' . $donnees2['chShort'] . '</td>';
                    } else {
                        echo '<td class="w3-center w3-black">';
                        echo '<form action="team.php"  method="POST">
                        <input type="hidden" value="" name="unmatched">
                            <input type="hidden" value="' . $_POST['idTe'] . '" name="idTe">
                            <input type="hidden" value="' . $donnees['joidJo'] . '" name="idJo">
                            <input type="hidden" value="' . $donnees2['idAr'] . '" name="idAr">';
                        echo '<input class="w3-button w3-padding-small w3-black" type="submit" value="' . $donnees2['chShort'] . '">';
                        echo '</form>';
                        echo '</td>';

                    }

                }
            }
            echo '</tr>';
        }
        $stmt->closeCursor();
    } else {
        echo '<br><label class="w3-text-deep-orange">Aucune estimation n\'est inscrit.</label>';
    }

    echo '</table><center>';
    $stmt->closeCursor();
} catch (Exception $except) {
    die('Erreur: ' . $except->getMessage());
}

?>

<br>
<form action="addEstim.php"  method="POST">
        <input type="hidden" value="<?php echo $_POST["idTe"]; ?>" name="idTe">
        <input type="submit" value="Ajouter une estimation">
    </form><br>


<?php
// supprimer estim
echo '<form action="team.php"  method="POST">';
echo ' <select name="idJo" required>
    <option value="" selected> -- Choisir une estimation -- </option>';
try {
    $bdd = new PDO('mysql:host=' . $dbhost . ';dbname=' . $dbname . ';charset=utf8', $dbuser, $dbpasswd);
    $stmt = $bdd->prepare("SELECT * FROM MW_Joueur WHERE idJo IN (SELECT DISTINCT idJo FROM MW_Estim WHERE idTe=:idTe);");
    $stmt->bindParam(':idTe', $_POST["idTe"]);
    $stmt->execute();
    while ($donnees = $stmt->fetch()) {
        echo '<option value="' . $donnees["idJo"] . '"> ' . $donnees["nomJo"] . ' </option>';
    }
    $stmt->closeCursor();
} catch (Exception $except) {
    die('Erreur: ' . $except->getMessage());
}
echo '</select>';
echo '<input type="hidden" value="' . $_POST["idTe"] . '" name="idTe">
<input type="hidden" value="" name="delete">
<input type="hidden" value="" name="estim">
<button type="submit" ><i class="fa fa-trash w3-text-red"></i></button>
</form>';

?>
</div>

<!-- Footer -->
<br>
<footer class=" w3-center w3-black w3-padding-32 w3-opacity w3-hover-opacity-on">
<form action="tournoi.php"  method="POST">
    <input type="hidden" value="<?php echo $_POST["idTe"]; ?>" name="idTe">
    <input type="submit" value="Retour arrière">
</form>
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
