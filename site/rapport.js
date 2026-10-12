// Rapport d'activité : rend rapport-data.json (généré en CI depuis le .xls).
// Construction DOM uniquement via textContent : le tableur reste une donnée,
// jamais du balisage.
(function(){
  var conteneur=document.getElementById('heures-resultats');
  if(!conteneur){return;}
  var formatHeures=new Intl.NumberFormat('fr-CH',{maximumFractionDigits:3});
  function nombreEstValide(valeur){
    return typeof valeur==='number'&&Number.isFinite(valeur);
  }
  function texte(valeur){
    return valeur===null||valeur===undefined?'':String(valeur);
  }
  function creer(tag,contenu,classe){
    var noeud=document.createElement(tag);
    if(classe){noeud.className=classe;}
    if(contenu!==undefined){noeud.textContent=contenu;}
    return noeud;
  }
  function ajouterCellule(ligne,tag,contenu,classe){
    var cellule=creer(tag,contenu,classe);
    ligne.appendChild(cellule);
    return cellule;
  }
  function vider(){
    while(conteneur.firstChild){conteneur.removeChild(conteneur.firstChild);}
  }
  function remplir(id,valeur){
    var noeud=document.getElementById(id);
    if(noeud&&valeur){noeud.textContent=valeur;}
  }
  function afficherEtat(titre,message){
    vider();
    var encadre=creer('aside',undefined,'callout');
    encadre.appendChild(creer('p',titre,'callout-title'));
    encadre.appendChild(creer('p',message));
    conteneur.appendChild(encadre);
  }
  function afficherDonnees(donnees){
    if(!donnees||!Array.isArray(donnees.activities)){throw new Error('Structure JSON invalide');}
    remplir('rapport-etudiant',texte(donnees.student));
    remplir('rapport-periode',texte(donnees.period));
    remplir('rapport-module',texte(donnees.title_module).replace(/^MODULE\s+/i,''));
    if(nombreEstValide(donnees.total_heures)){
      remplir('rapport-total',formatHeures.format(donnees.total_heures)+' h');
    }
    var activites=donnees.activities.filter(function(activity){
      return activity&&nombreEstValide(activity.heures);
    });
    if(!activites.length){
      afficherEtat('Aucune heure validée','Aucune activité avec un nombre d’heures n’est présente dans le fichier source.');
      return;
    }

    var enveloppe=creer('div',undefined,'table-scroll');
    enveloppe.setAttribute('tabindex','0');
    enveloppe.setAttribute('role','region');
    enveloppe.setAttribute('aria-label','Activités avec heures validées');
    var tableau=creer('table');
    tableau.appendChild(creer('caption','Activités renseignées dans le fichier source'));

    var entete=creer('thead');
    var ligneEntete=creer('tr');
    ['Module','Catégorie','Activité','Heures'].forEach(function(titre){
      ajouterCellule(ligneEntete,'th',titre).setAttribute('scope','col');
    });
    entete.appendChild(ligneEntete);
    tableau.appendChild(entete);

    var corps=creer('tbody');
    activites.forEach(function(activity){
      var ligne=creer('tr');
      ajouterCellule(ligne,'td',texte(activity.module));
      ajouterCellule(ligne,'td',texte(activity.categorie));
      ajouterCellule(ligne,'td',texte(activity.description)||'Activité sans description');
      ajouterCellule(ligne,'td',formatHeures.format(activity.heures)+' h','heures');
      corps.appendChild(ligne);
    });
    tableau.appendChild(corps);

    if(nombreEstValide(donnees.total_heures)){
      var pied=creer('tfoot');
      var ligneTotal=creer('tr',undefined,'total-ligne');
      var titreTotal=ajouterCellule(ligneTotal,'th','Total indiqué dans le fichier');
      titreTotal.setAttribute('scope','row');
      titreTotal.setAttribute('colspan','3');
      ajouterCellule(ligneTotal,'td',formatHeures.format(donnees.total_heures)+' h','heures');
      pied.appendChild(ligneTotal);
      tableau.appendChild(pied);
    }

    enveloppe.appendChild(tableau);
    vider();
    conteneur.appendChild(enveloppe);
  }
  fetch('rapport-data.json').then(function(response){
    if(!response.ok){throw new Error('Chargement JSON impossible');}
    return response.json();
  }).then(afficherDonnees).catch(function(){
    afficherEtat('Erreur de chargement','Impossible de lire les heures d’activité. Vérifiez que rapport-data.json est disponible, puis rechargez la page.');
  }).then(function(){
    conteneur.setAttribute('aria-busy','false');
  });
})();
