// Cahier de laboratoire — comportements du site statique.
// Chaque page est complète sans JavaScript ; ce script ajoute la recherche
// plein texte, le suivi de lecture, le thème, le tiroir mobile et la
// redirection des anciennes adresses (site mono-page).
(function(racine){
  'use strict';

  // ------------------------------------------------------------ logique pure
  // Exportée pour tests/test_app_runtime.js : aucune dépendance au DOM.

  function normaliser(texte){
    texte=String(texte||'').toLowerCase();
    if(texte.normalize){texte=texte.normalize('NFD').replace(/[̀-ͯ]/g,'');}
    return texte.replace(/[’']/g,' ');
  }

  function termes(requete){
    return normaliser(requete).split(/\s+/).filter(function(t){return t.length>0;});
  }

  // Score d'un enregistrement de search-index.json ; 0 = au moins un terme absent.
  function score(enregistrement,mots){
    if(!mots.length){return 0;}
    var titre=normaliser(enregistrement.t),
        contexte=normaliser(enregistrement.c),
        corps=normaliser(enregistrement.x),
        total=0;
    for(var i=0;i<mots.length;i++){
      var m=mots[i],s=0;
      if(titre.indexOf(m)!==-1){s+=titre.indexOf(m)===0||titre.indexOf(' '+m)!==-1?12:8;}
      if(contexte.indexOf(m)!==-1){s+=3;}
      if(corps.indexOf(m)!==-1){s+=2+Math.min(3,corps.split(m).length-2);}
      if(!s){return 0;}
      total+=s;
    }
    return total;
  }

  function rechercher(index,requete,limite){
    var mots=termes(requete);
    if(!mots.length){return [];}
    return index.map(function(e,i){return {e:e,s:score(e,mots),i:i};})
      .filter(function(r){return r.s>0;})
      .sort(function(a,b){return b.s-a.s||a.i-b.i;})
      .slice(0,limite||20)
      .map(function(r){return r.e;});
  }

  // Extrait centré sur le premier terme trouvé, découpé en segments
  // [{t:texte, m:bool}] pour être rendu sans innerHTML.
  function extrait(texte,mots,largeur){
    texte=String(texte||'');
    largeur=largeur||160;
    var norm=normaliser(texte),debut=-1;
    // normaliser() préserve la longueur (NFD puis retrait des diacritiques)
    // pour le français courant ; les positions restent alignées.
    for(var i=0;i<mots.length&&debut===-1;i++){debut=norm.indexOf(mots[i]);}
    var from=Math.max(0,(debut===-1?0:debut)-Math.round(largeur/3)),
        to=Math.min(texte.length,from+largeur),
        morceau=texte.slice(from,to),
        normMorceau=norm.slice(from,to),
        segments=[],pos=0;
    while(pos<morceau.length){
      var prochain=-1,long=0;
      mots.forEach(function(m){
        var k=normMorceau.indexOf(m,pos);
        if(k!==-1&&(prochain===-1||k<prochain)){prochain=k;long=m.length;}
      });
      if(prochain===-1){segments.push({t:morceau.slice(pos),m:false});break;}
      if(prochain>pos){segments.push({t:morceau.slice(pos,prochain),m:false});}
      segments.push({t:morceau.slice(prochain,prochain+long),m:true});
      pos=prochain+long;
    }
    if(from>0){segments.unshift({t:'… ',m:false});}
    if(to<texte.length){segments.push({t:' …',m:false});}
    return segments;
  }

  // Ancienne adresse mono-page -> page actuelle, ou null.
  //   ?view=pdf                    -> cahier.pdf
  //   ?seance=seance-02#ancre      -> seance-02.html#ancre
  //   #ancre-d-une-seance          -> seance-NN.html#ancre (table d'ancres)
  function cibleHeritee(search,hash,ancres){
    var params=new URLSearchParams(search||'');
    if(params.get('view')==='pdf'){return 'cahier.pdf';}
    var seance=params.get('seance');
    if(seance&&/^seance-\d{2}$/.test(seance)){return seance+'.html'+(hash||'');}
    if(hash&&hash.length>1&&ancres){
      var id;
      try{id=decodeURIComponent(hash.slice(1));}catch(e){return null;}
      if(Object.prototype.hasOwnProperty.call(ancres,id)){return ancres[id]+'#'+encodeURIComponent(id);}
    }
    return null;
  }

  var api={normaliser:normaliser,termes:termes,score:score,rechercher:rechercher,
           extrait:extrait,cibleHeritee:cibleHeritee};
  if(typeof module!=='undefined'&&module.exports){module.exports=api;return;}

  // ------------------------------------------------------------ navigateur
  var doc=racine.document,html=doc.documentElement;

  // Redirection des liens partagés vers l'ancien site mono-page.
  (function(){
    var bloc=doc.getElementById('ancres'),ancres=null;
    if(!bloc){return;}
    try{ancres=JSON.parse(bloc.textContent);}catch(e){return;}
    var id=location.hash.slice(1);
    if(id&&doc.getElementById(id)){return;}
    var cible=cibleHeritee(location.search,location.hash,ancres);
    if(cible){location.replace(cible);}
  })();

  // Thème
  var bTheme=doc.getElementById('btn-theme');
  function majTheme(){
    var sombre=html.dataset.theme==='dark';
    if(bTheme){
      bTheme.setAttribute('aria-pressed',sombre?'true':'false');
      bTheme.setAttribute('aria-label',sombre?'Activer le thème clair':'Activer le thème sombre');
    }
  }
  if(bTheme){
    bTheme.addEventListener('click',function(){
      html.dataset.theme=html.dataset.theme==='dark'?'light':'dark';
      try{localStorage.setItem('cahier-theme',html.dataset.theme);}catch(e){}
      majTheme();
    });
  }
  majTheme();

  // Tiroir de navigation (mobile)
  var bMenu=doc.getElementById('btn-menu'),voile=doc.getElementById('voile'),
      sidebar=doc.getElementById('sidebar');
  function tiroir(ouvert){
    doc.body.classList.toggle('nav-ouverte',ouvert);
    if(voile){voile.hidden=!ouvert;}
    if(bMenu){
      bMenu.setAttribute('aria-expanded',ouvert?'true':'false');
      bMenu.setAttribute('aria-label',ouvert?'Fermer la navigation':'Ouvrir la navigation');
    }
    if(ouvert&&sidebar){var a=sidebar.querySelector('a');if(a){a.focus();}}
  }
  if(bMenu){bMenu.addEventListener('click',function(){tiroir(!doc.body.classList.contains('nav-ouverte'));});}
  if(voile){voile.addEventListener('click',function(){tiroir(false);});}
  if(sidebar){
    sidebar.addEventListener('click',function(ev){
      if(ev.target.closest&&ev.target.closest('a')){tiroir(false);}
    });
    var courant=sidebar.querySelector('[aria-current="page"]');
    if(courant&&courant.scrollIntoView&&sidebar.scrollHeight>sidebar.clientHeight){
      sidebar.scrollTop=Math.max(0,courant.offsetTop-80);
    }
  }

  // Recherche plein texte
  var dialogue=doc.getElementById('recherche'),
      champ=doc.getElementById('recherche-input'),
      liste=doc.getElementById('recherche-resultats'),
      etatRecherche=doc.getElementById('recherche-etat'),
      index=null,chargement=null,selection=-1;
  function chargerIndex(){
    if(!chargement){
      chargement=fetch('search-index.json').then(function(r){
        if(!r.ok){throw new Error('index');}
        return r.json();
      }).then(function(data){index=data;return data;});
    }
    return chargement;
  }
  function selectionner(i){
    var items=liste.children;
    if(!items.length){selection=-1;return;}
    selection=(i+items.length)%items.length;
    for(var k=0;k<items.length;k++){
      items[k].setAttribute('aria-selected',k===selection?'true':'false');
    }
    items[selection].scrollIntoView({block:'nearest'});
  }
  function afficherResultats(){
    var q=champ.value;
    while(liste.firstChild){liste.removeChild(liste.firstChild);}
    selection=-1;
    if(!index){etatRecherche.textContent='Chargement de l’index…';return;}
    var mots=termes(q);
    if(!mots.length){etatRecherche.textContent=index.length+' sections indexées. Tapez un mot-clé.';return;}
    var resultats=rechercher(index,q,25);
    etatRecherche.textContent=resultats.length?
      (resultats.length===25?'25 meilleurs résultats':resultats.length+' résultat'+(resultats.length>1?'s':'')):
      'Aucun résultat pour « '+q+' ».';
    resultats.forEach(function(r,i){
      var li=doc.createElement('li'),a=doc.createElement('a');
      li.setAttribute('role','option');
      li.id='resultat-'+i;
      a.href=r.u;
      var ctx=doc.createElement('span');ctx.className='r-contexte';ctx.textContent=r.c;
      var titre=doc.createElement('span');titre.className='r-titre';titre.textContent=r.t;
      var ex=doc.createElement('span');ex.className='r-extrait';
      extrait(r.x,mots).forEach(function(seg){
        var n=seg.m?doc.createElement('mark'):doc.createTextNode(seg.t);
        if(seg.m){n.textContent=seg.t;}
        ex.appendChild(n);
      });
      a.appendChild(ctx);a.appendChild(titre);a.appendChild(ex);
      a.addEventListener('click',function(){dialogue.close();});
      li.appendChild(a);
      liste.appendChild(li);
    });
    if(resultats.length){selectionner(0);}
  }
  function ouvrirRecherche(){
    if(!dialogue||dialogue.open){return;}
    tiroir(false);
    dialogue.showModal();
    champ.select();
    chargerIndex().then(afficherResultats,function(){
      etatRecherche.textContent='Index de recherche indisponible.';
    });
    afficherResultats();
  }
  if(dialogue){
    doc.querySelectorAll('[data-search-open]').forEach(function(b){
      b.addEventListener('click',ouvrirRecherche);
    });
    champ.addEventListener('input',afficherResultats);
    champ.addEventListener('keydown',function(ev){
      if(ev.key==='ArrowDown'){ev.preventDefault();selectionner(selection+1);}
      else if(ev.key==='ArrowUp'){ev.preventDefault();selectionner(selection-1);}
      else if(ev.key==='Enter'){
        ev.preventDefault();
        var item=liste.children[selection];
        if(item){dialogue.close();location.href=item.querySelector('a').href;}
      }
    });
    dialogue.addEventListener('click',function(ev){if(ev.target===dialogue){dialogue.close();}});
  }
  doc.addEventListener('keydown',function(ev){
    var cible=ev.target,saisie=cible&&(cible.tagName==='INPUT'||cible.tagName==='TEXTAREA'||cible.isContentEditable);
    if((ev.key==='k'||ev.key==='K')&&(ev.metaKey||ev.ctrlKey)){ev.preventDefault();ouvrirRecherche();}
    else if(ev.key==='/'&&!saisie){ev.preventDefault();ouvrirRecherche();}
    else if(ev.key==='Escape'&&doc.body.classList.contains('nav-ouverte')){tiroir(false);if(bMenu){bMenu.focus();}}
  });
  if(/Mac|iPhone|iPad/.test(navigator.platform||'')){
    doc.querySelectorAll('.recherche-bouton kbd').forEach(function(k){k.textContent='⌘ K';});
  }

  // Suivi de lecture : met en évidence l'entrée et la section visibles.
  var liensSpy=Array.prototype.slice.call(doc.querySelectorAll('[data-spy]')),
      cibles=[],vues={};
  liensSpy.forEach(function(a){
    var id=a.getAttribute('data-spy');
    if(!vues[id]){vues[id]=true;var c=doc.getElementById(id);if(c){cibles.push(c);}}
  });
  var planifie=false;
  function suivre(){
    planifie=false;
    var seuil=100,actif=null;
    for(var i=0;i<cibles.length;i++){
      if(cibles[i].getBoundingClientRect().top<=seuil){actif=cibles[i];}else{break;}
    }
    if(!actif&&cibles.length){actif=null;}
    var entree=actif&&actif.closest?actif.closest('.entree'):null,
        idEntree=entree?entree.querySelector('h2').id:null,
        idActif=actif?actif.id:null;
    liensSpy.forEach(function(a){
      var id=a.getAttribute('data-spy'),
          dansRail=!!(a.closest&&a.closest('.rail')),
          on=dansRail?id===idActif:id===idEntree;
      a.classList.toggle('actif',on);
      if(dansRail){
        var li=a.parentElement;
        if(li&&li.querySelector('ol')){li.classList.toggle('ouvert',id===idEntree);}
      }
    });
    if(!idActif){return;}
    // Ouvre aussi le parent dans le rail quand une sous-section est active.
    var lienRail=doc.querySelector('.rail [data-spy="'+idActif+'"]');
    if(lienRail){
      var parentLi=lienRail.parentElement&&lienRail.parentElement.parentElement&&lienRail.parentElement.parentElement.parentElement;
      if(parentLi&&parentLi.tagName==='LI'){parentLi.classList.add('ouvert');}
    }
  }
  if(cibles.length){
    racine.addEventListener('scroll',function(){
      if(!planifie){planifie=true;racine.requestAnimationFrame(suivre);}
    },{passive:true});
    suivre();
  }

  // Copier le lien d'un titre
  doc.querySelectorAll('.ancre').forEach(function(ancre){
    ancre.addEventListener('click',function(){
      var url=new URL(ancre.getAttribute('href'),location.href).toString();
      try{if(navigator.clipboard){navigator.clipboard.writeText(url).catch(function(){});}}catch(e){}
      var retour=doc.createElement('span');
      retour.className='ancre-retour';
      retour.setAttribute('role','status');
      retour.textContent='lien copié';
      ancre.after(retour);
      setTimeout(function(){retour.remove();},1600);
    });
  });

  // Loupe sur les figures
  var loupe=doc.getElementById('loupe'),loupeImg=doc.getElementById('loupe-image'),
      loupeLegende=doc.getElementById('loupe-legende');
  if(loupe&&loupe.showModal){
    doc.querySelectorAll('main figure img').forEach(function(img){
      img.setAttribute('tabindex','0');
      img.setAttribute('role','button');
      img.setAttribute('aria-label','Agrandir : '+(img.alt||'figure'));
      function ouvrir(){
        loupeImg.src=img.currentSrc||img.src;
        loupeImg.alt=img.alt;
        var cap=img.closest('figure').querySelector('figcaption');
        loupeLegende.textContent=cap?cap.textContent:img.alt;
        loupe.showModal();
      }
      img.addEventListener('click',ouvrir);
      img.addEventListener('keydown',function(ev){
        if(ev.key==='Enter'||ev.key===' '){ev.preventDefault();ouvrir();}
      });
    });
    loupe.addEventListener('click',function(ev){if(ev.target===loupe){loupe.close();}});
  }

})(typeof window!=='undefined'?window:this);
