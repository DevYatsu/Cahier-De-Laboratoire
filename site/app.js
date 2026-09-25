(function(){
  var doc=document.getElementById('vue-doc'),
      pdf=document.getElementById('vue-pdf'),
      bDoc=document.getElementById('btn-doc'),
      bPdf=document.getElementById('btn-pdf'),
      bRapport=document.getElementById('btn-rapport'),
      bTheme=document.getElementById('btn-theme'),
      navSeances=document.getElementById('nav-seances'),
      lienPrec=document.getElementById('seance-prec'),
      lienSuiv=document.getElementById('seance-suiv'),
      selectSeance=document.getElementById('seance-select'),
      erreur=document.getElementById('seance-erreur'),
      erreurTexte=document.getElementById('seance-erreur-texte'),
      btnToutes=document.getElementById('btn-toutes');
  var etat={demandee:null,courante:null,index:-1,dernierHref:null},
      modeCourante='doc',
      actif=null,
      planifie=false;

  function libelleSeance(h){
    var copie=h.cloneNode(true),
        ancre=copie.querySelector('.ancre');
    if(ancre){ancre.remove();}
    return copie.textContent.replace(/\s+/g,' ').trim();
  }
  var seances=Array.prototype.slice.call(
    document.querySelectorAll('#contenu h1[data-seance]')).filter(function(h){
      return /^seance-\d{2}$/.test(h.getAttribute('data-seance')||'');
    }).map(function(h){
      var activite=h.parentElement&&h.parentElement.querySelector('h2');
      return {
        cle:h.getAttribute('data-seance'),
        titre:libelleSeance(h),
        ancre:h.id,
        activiteAncre:activite?activite.id:h.id
      };
    });
  var blocsParCle={};
  Array.prototype.slice.call(
    document.querySelectorAll('#contenu > .bloc-seance[data-seance]')
  ).forEach(function(el){
    var cle=el.getAttribute('data-seance');
    if(blocsParCle[cle]){throw new Error('Duplicate session wrapper: '+cle);}
    blocsParCle[cle]=el;
  });

  function blocDe(element){
    var noeud=element;
    while(noeud&&noeud.id!=='contenu'){
      if(noeud.classList&&noeud.classList.contains('bloc-seance')){return noeud;}
      noeud=noeud.parentElement;
    }
    return null;
  }
  function sourceSeanceKey(element){
    var bloc=blocDe(element);
    return bloc?bloc.getAttribute('data-seance')||'':'';
  }
  function ancreDepuisHash(hash){
    var brut=hash.slice(1);
    if(/%(?![0-9A-Fa-f]{2})/.test(brut)){return null;}
    var id;
    try{id=decodeURIComponent(brut);}catch(e){return null;}
    return document.getElementById(id);
  }
  function urlPourSeance(cle,ancre){
    var u=new URL(window.location.href);
    if(cle){
      u.searchParams.set('view','doc');
      u.searchParams.set('seance',cle);
    }else{
      u.searchParams.delete('seance');
    }
    if(ancre){u.hash=ancre;}
    return (u.search?'?'+u.searchParams.toString():'')+(u.hash||'');
  }
  function modePourUrl(u){
    var q=u.searchParams.get('view');
    if(q==='pdf'||q==='doc'){return q;}
    if(u.searchParams.has('seance')){return 'doc';}
    try{
      var stocke=localStorage.getItem('cahier-vue');
      if(stocke==='pdf'||stocke==='doc'){return stocke;}
    }catch(e){}
    return 'doc';
  }
  function modeInitial(){
    return modePourUrl(new URL(window.location.href));
  }
  function afficherMode(mode){
    var isPdf=mode==='pdf';
    modeCourante=mode;
    pdf.hidden=!isPdf;
    doc.hidden=isPdf;
    bPdf.setAttribute('aria-pressed',isPdf?'true':'false');
    bDoc.setAttribute('aria-pressed',isPdf?'false':'true');
  }
  function ecrireMode(mode,save){
    afficherMode(mode);
    try{
      if(save!==false){try{localStorage.setItem('cahier-vue',mode);}catch(e){}}
      var u=new URL(window.location.href);
      u.searchParams.set('view',mode);
      if(mode==='pdf'){u.searchParams.delete('seance');}
      window.history.replaceState(null,'',u.toString());
    }catch(e){}
  }
  function changerMode(mode){
    ecrireMode(mode,true);
    actualiserEtat({force:true,focusAncre:null});
  }

  var liens=Array.prototype.slice.call(
    document.querySelectorAll('.col-sommaire nav.toc a[href^="#"]'));
  var entrees=Array.prototype.slice.call(
    document.querySelectorAll('.col-sommaire nav.toc li'));
  var sommaire=document.querySelector('.col-sommaire');
  function ancreDirecte(li){
    for(var i=0;i<li.children.length;i++){
      var child=li.children[i];
      if(child.tagName==='A'&&child.getAttribute('href')&&
         child.getAttribute('href').charAt(0)==='#'){return child;}
    }
    return null;
  }
  function normaliser(value){
    value=(value||'').toLowerCase();
    if(value.normalize){value=value.normalize('NFD').replace(/[\u0300-\u036f]/g,'');}
    return value;
  }
  function appliquerFiltre(){
    var champ=document.getElementById('recherche'),
        compte=document.getElementById('recherche-compte'),
        q=champ?normaliser(champ.value.trim()):'',
        visibles=[];
    entrees.forEach(function(li){
      var lien=ancreDirecte(li),
          dansSeance=!etat.courante||li.getAttribute('data-seance')===etat.courante;
      li._m=dansSeance&&!!q&&!!lien&&normaliser(lien.textContent).indexOf(q)!==-1;
    });
    function descendant(li){
      var found=li.querySelectorAll('li');
      for(var i=0;i<found.length;i++){if(found[i]._m){return true;}}
      return false;
    }
    function ascendant(li){
      var parent=li.parentElement;
      while(parent){
        if(parent.tagName==='LI'&&parent._m){return true;}
        parent=parent.parentElement;
      }
      return false;
    }
    entrees.forEach(function(li){
      var lien=ancreDirecte(li),
          dansSeance=!etat.courante||li.getAttribute('data-seance')===etat.courante,
          montrer=dansSeance&&(!q||li._m||descendant(li)||ascendant(li));
      li.hidden=!montrer;
      if(montrer&&lien){visibles.push(lien);}
    });
    var nav=document.querySelector('.col-sommaire nav.toc');
    if(nav){
      Array.prototype.slice.call(nav.querySelectorAll('ul')).forEach(function(ul){
        var enfants=Array.prototype.slice.call(ul.children);
        ul.hidden=enfants.length>0&&enfants.every(function(child){return child.hidden;});
      });
    }
    if(compte){
      compte.textContent=!q?'':visibles.length===0?'Aucun résultat':
        visibles.length===1?'1 résultat':visibles.length+' résultats';
    }
    return visibles;
  }
  function majNavigation(){
    if(!navSeances||seances.length<2){return;}
    var idx=etat.index;
    var indexPrec=idx<0?0:Math.max(0,idx-1);
    var indexSuiv=idx<0?0:Math.min(seances.length-1,idx+1);
    var precedent=seances[indexPrec],
        suivant=seances[indexSuiv],
        ancrePrecedente=idx<0?precedent.ancre:precedent.activiteAncre,
        ancreSuivante=idx<0?suivant.ancre:suivant.activiteAncre;
    if(lienPrec){
      lienPrec.href=urlPourSeance(etat.courante?precedent.cle:null,ancrePrecedente);
      if(idx<=0){lienPrec.setAttribute('aria-disabled','true');}
      else{lienPrec.removeAttribute('aria-disabled');}
      var textePrec=lienPrec.querySelector('span');
      if(textePrec){textePrec.textContent=precedent.titre;}
    }
    if(lienSuiv){
      lienSuiv.href=urlPourSeance(etat.courante?suivant.cle:null,ancreSuivante);
      if(idx===seances.length-1){lienSuiv.setAttribute('aria-disabled','true');}
      else{lienSuiv.removeAttribute('aria-disabled');}
      var texteSuiv=lienSuiv.querySelector('span');
      if(texteSuiv){texteSuiv.textContent=suivant.titre;}
    }
    if(selectSeance){selectSeance.value=etat.courante||'';}
    navSeances.hidden=modeCourante==='pdf';
  }
  function offsetBandeau(){
    var h=document.querySelector('header.site');
    return (h?h.getBoundingClientRect().height:0)+16;
  }
  function entreesVisibles(){
    var paires=[];
    liens.forEach(function(lien){
      var item=lien.parentElement,
          li=ancreDirecte(item),
          cible=ancreDepuisHash(lien.getAttribute('href'));
      if(li&&!item.hidden&&cible&&(!blocDe(cible)||!blocDe(cible).hidden)){
        paires.push({lien:li,cible:cible});
      }
    });
    return paires;
  }
  function reinitialiserScrollSpy(){
    if(actif){
      actif.classList.remove('active');
      actif.removeAttribute('aria-current');
    }
    actif=null;
  }
  function mettreAJour(){
    planifie=false;
    if(modeCourante==='pdf'){return;}
    var paires=entreesVisibles();
    if(!paires.length){
      reinitialiserScrollSpy();
      return;
    }
    var seuil=offsetBandeau()+8,
        courant=0;
    for(var i=0;i<paires.length;i++){
      if(paires[i].cible.getBoundingClientRect().top<=seuil){courant=i;}
    }
    if(window.innerHeight+window.scrollY>=document.body.scrollHeight-2){
      courant=paires.length-1;
    }
    if(paires[courant].lien===actif){return;}
    reinitialiserScrollSpy();
    actif=paires[courant].lien;
    actif.classList.add('active');
    actif.setAttribute('aria-current','location');
    if(sommaire&&sommaire.scrollHeight>sommaire.clientHeight){
      var haut=actif.offsetTop,
          bas=haut+actif.offsetHeight;
      if(haut<sommaire.scrollTop){sommaire.scrollTop=haut-8;}
      else if(bas>sommaire.scrollTop+sommaire.clientHeight){
        sommaire.scrollTop=bas-sommaire.clientHeight+8;
      }
    }
  }
  function planifier(){
    if(planifie){return;}
    planifie=true;
    window.requestAnimationFrame(mettreAJour);
  }
  function appliquerModeDepuisUrl(u){
    var mode=modePourUrl(u);
    if(mode==='pdf'&&u.searchParams.has('seance')){
      u.searchParams.delete('seance');
      try{window.history.replaceState(null,'',u.toString());}catch(e){}
    }
    afficherMode(mode);
  }
  function actualiserEtat(options){
    options=options||{};
    var u=new URL(window.location.href);
    appliquerModeDepuisUrl(u);
    var href=u.toString();
    if(!options.force&&href===etat.dernierHref){return;}
    etat.dernierHref=href;
    etat.demandee=u.searchParams.get('seance');
    if(etat.demandee===''){
      u.searchParams.delete('seance');
      try{window.history.replaceState(null,'',u.toString());}catch(e){}
      etat.dernierHref=u.toString();
    }
    etat.courante=null;
    etat.index=-1;
    for(var i=0;i<seances.length;i++){
      if(seances[i].cle===etat.demandee){
        etat.courante=seances[i].cle;
        etat.index=i;
        break;
      }
    }
    if(!etat.demandee&&etat.index<0&&u.hash){
      var cleDuHash=sourceSeanceKey(ancreDepuisHash(u.hash));
      for(var j=0;j<seances.length;j++){
        if(seances[j].cle===cleDuHash){etat.index=j;break;}
      }
    }
    var inconnue=!!etat.demandee&&!etat.courante;
    erreurTexte.textContent=inconnue?'Séance introuvable : '+etat.demandee+'.':'';
    if(inconnue){
      u.searchParams.delete('seance');
      try{window.history.replaceState(null,'',u.toString());}catch(e){}
      etat.dernierHref=u.toString();
    }
    var ancre=u.hash?ancreDepuisHash(u.hash):null;
    if(etat.courante&&ancre&&sourceSeanceKey(ancre)!==etat.courante){
      u.hash='';
      try{window.history.replaceState(null,'',u.toString());}catch(e){}
      etat.dernierHref=u.toString();
    }
    Object.keys(blocsParCle).forEach(function(cle){
      blocsParCle[cle].hidden=!!etat.courante&&cle!==etat.courante;
    });
    erreur.hidden=!inconnue;
    appliquerFiltre();
    majNavigation();
    mettreAJour();
    if(options.focusAncre){
      var cible=ancreDepuisHash(options.focusAncre);
      if(cible&&(!blocDe(cible)||!blocDe(cible).hidden)){
        cible.setAttribute('tabindex','-1');
        cible.focus({preventScroll:true});
        cible.scrollIntoView();
      }
    }
  }
  function choisirSeance(cle,ancre,focusUtilisateur){
    var u=new URL(window.location.href);
    if(cle){
      u.searchParams.set('view','doc');
      u.searchParams.set('seance',cle);
    }else{
      u.searchParams.delete('seance');
    }
    if(ancre){u.hash=ancre;}
    try{window.history.pushState(null,'',u.toString());}catch(e){}
    actualiserEtat({force:true,focusAncre:focusUtilisateur&&ancre?'#'+ancre:null});
  }
  function seanceDepuisClic(lien,direction){
    if(lien.getAttribute('aria-disabled')==='true'){return;}
    var base=etat.index<0?(direction>0?-1:0):etat.index;
    var cible=seances[Math.max(0,Math.min(seances.length-1,base+direction))];
    choisirSeance(etat.courante?cible.cle:null,cible.activiteAncre,true);
  }

  if(selectSeance&&seances.length){
    seances.forEach(function(seance){
      var option=document.createElement('option');
      option.value=seance.cle;
      option.textContent=seance.titre;
      selectSeance.appendChild(option);
    });
    selectSeance.addEventListener('change',function(){
      var value=selectSeance.value,
          trouve=null;
      seances.forEach(function(seance){if(seance.cle===value){trouve=seance;}});
      if(trouve){choisirSeance(trouve.cle,trouve.ancre,true);}
      else{choisirSeance('', '', false);}
    });
  }
  if(btnToutes){
    btnToutes.addEventListener('click',function(){
      choisirSeance('', '', false);
      selectSeance.focus({preventScroll:true});
    });
  }
  if(lienPrec){
    lienPrec.addEventListener('click',function(ev){
      ev.preventDefault();
      seanceDepuisClic(lienPrec,-1);
    });
  }
  if(lienSuiv){
    lienSuiv.addEventListener('click',function(ev){
      ev.preventDefault();
      seanceDepuisClic(lienSuiv,1);
    });
  }
  bDoc.addEventListener('click',function(){changerMode('doc');});
  bPdf.addEventListener('click',function(){changerMode('pdf');});
  if(bRapport){bRapport.addEventListener('click',function(){window.location.href='rapport.html';});}
  window.addEventListener('popstate',function(){actualiserEtat();});
  window.addEventListener('hashchange',function(){actualiserEtat();});

  var bToc=document.getElementById('btn-toc'),
      colonne=document.getElementById('sommaire'),
      pointRupture=window.matchMedia&&window.matchMedia('(min-width: 1000px)');
  function replierToc(){return pointRupture&&pointRupture.matches;}
  function appliquerToc(ouvert){
    if(!colonne||!bToc){return;}
    colonne.hidden=!ouvert;
    bToc.setAttribute('aria-expanded',ouvert?'true':'false');
  }
  if(bToc&&colonne){
    bToc.addEventListener('click',function(){appliquerToc(colonne.hidden);});
    appliquerToc(replierToc());
    if(pointRupture&&pointRupture.addEventListener){
      pointRupture.addEventListener('change',function(){appliquerToc(replierToc());});
    }else if(pointRupture&&pointRupture.addListener){
      pointRupture.addListener(function(){appliquerToc(replierToc());});
    }
    colonne.addEventListener('click',function(ev){
      var lien=ev.target&&ev.target.closest?ev.target.closest('a[href^="#"]'):null;
      if(lien&&!replierToc()){appliquerToc(false);bToc.focus();}
    });
  }

  var reduction=window.matchMedia&&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  document.querySelectorAll('.doc .ancre').forEach(function(ancre){
    ancre.addEventListener('click',function(){
      var url=null;
      try{url=new URL(ancre.getAttribute('href'),window.location.href).toString();}catch(e){}
      if(!url){return;}
      try{
        if(navigator.clipboard&&navigator.clipboard.writeText){
          navigator.clipboard.writeText(url).catch(function(){});
        }
      }catch(e){}
      var retour=document.createElement('span');
      retour.textContent=reduction?'Lien copié.':'Lien copié !';
      retour.setAttribute('role','status');
      retour.classList.add('ancre-retour');
      ancre.parentElement.appendChild(retour);
      window.setTimeout(function(){retour.remove();},1600);
    });
  });
  var champ=document.getElementById('recherche');
  if(champ){
    champ.addEventListener('input',function(){
      appliquerFiltre();
      reinitialiserScrollSpy();
      mettreAJour();
    });
    champ.addEventListener('keydown',function(ev){
      if(ev.key==='Enter'){
        var premiers=appliquerFiltre();
        reinitialiserScrollSpy();
        mettreAJour();
        if(premiers.length){ev.preventDefault();premiers[0].click();}
      }else if(ev.key==='Escape'||ev.key==='Esc'){
        if(champ.value){champ.value='';appliquerFiltre();}
        reinitialiserScrollSpy();
        mettreAJour();
      }
    });
  }

  function appliquerTheme(theme,save){
    var dark=theme==='dark';
    if(dark){document.documentElement.dataset.theme='dark';}
    else{delete document.documentElement.dataset.theme;}
    if(bTheme){
      bTheme.setAttribute('aria-pressed',dark?'true':'false');
      bTheme.setAttribute('aria-label',dark?'Activer le thème clair':'Activer le thème sombre');
    }
    if(save!==false){
      try{localStorage.setItem('cahier-theme',dark?'dark':'light');}catch(e){}
    }
  }
  function themeInitial(){
    try{
      var stocke=localStorage.getItem('cahier-theme');
      if(stocke==='dark'||stocke==='light'){return stocke;}
      if(window.matchMedia&&window.matchMedia('(prefers-color-scheme: dark)').matches){return 'dark';}
    }catch(e){}
    return 'light';
  }
  if(bTheme){
    bTheme.addEventListener('click',function(){
      appliquerTheme(document.documentElement.dataset.theme==='dark'?'light':'dark',true);
    });
  }
  appliquerTheme(themeInitial(),false);

  window.addEventListener('scroll',planifier,{passive:true});
  window.addEventListener('resize',planifier,{passive:true});
  ecrireMode(modeInitial(),false);
  actualiserEtat({force:true,focusAncre:null});
})();
