(function(){
  var doc=document.getElementById('vue-doc'),
      pdf=document.getElementById('vue-pdf'),
      bDoc=document.getElementById('btn-doc'),
      bPdf=document.getElementById('btn-pdf');
  function show(mode,save){
    var isPdf=(mode==='pdf');
    pdf.hidden=!isPdf; doc.style.display=isPdf?'none':'';
    bPdf.setAttribute('aria-pressed',isPdf?'true':'false');
    bDoc.setAttribute('aria-pressed',isPdf?'false':'true');
    try{
      if(save!==false){try{localStorage.setItem('cahier-vue',mode);}catch(e){}}
      var u=new URL(window.location.href);
      u.searchParams.set('view',mode==='pdf'?'pdf':'doc');
      window.history.replaceState(null,'',u.toString());
    }catch(e){}
  }
  function initial(){
    try{
      var q=new URL(window.location.href).searchParams.get('view');
      if(q==='pdf'||q==='doc'){return q;}
      var s=null;try{s=localStorage.getItem('cahier-vue');}catch(e){}
      if(s==='pdf'||s==='doc'){return s;}
    }catch(e){}
    return 'doc';
  }
  bDoc.addEventListener('click',function(){show('doc');});
  bPdf.addEventListener('click',function(){show('pdf');});
  show(initial(),false);

  // Theme sombre / clair : meme motif que show()/initial() ci-dessus.
  var bTheme=document.getElementById('btn-theme');
  function applyTheme(theme,save){
    var dark=(theme==='dark');
    if(dark){document.documentElement.dataset.theme='dark';}
    else{delete document.documentElement.dataset.theme;}
    if(bTheme){
      bTheme.setAttribute('aria-pressed',dark?'true':'false');
      bTheme.textContent=dark?'Thème clair':'Thème sombre';
    }
    if(save!==false){try{localStorage.setItem('cahier-theme',dark?'dark':'light');}catch(e){}}
  }
  function initialTheme(){
    try{
      var s=null;try{s=localStorage.getItem('cahier-theme');}catch(e){}
      if(s==='dark'||s==='light'){return s;}
      if(window.matchMedia&&matchMedia('(prefers-color-scheme: dark)').matches){return 'dark';}
    }catch(e){}
    return 'light';
  }
  if(bTheme){bTheme.addEventListener('click',function(){
    applyTheme(document.documentElement.dataset.theme==='dark'?'light':'dark');
  });}
  applyTheme(initialTheme(),false);

  // Sommaire lateral : surligne la section en cours de lecture.
  var liens=Array.prototype.slice.call(
            document.querySelectorAll('.col-sommaire nav.toc a[href^="#"]'));
  var cibles=liens.map(function(a){
    var id=decodeURIComponent(a.getAttribute('href').slice(1));
    return document.getElementById(id);
  });
  var sommaire=document.querySelector('.col-sommaire');
  var actif=null, planifie=false;
  function offsetBandeau(){
    var h=document.querySelector('header.site');
    return (h?h.getBoundingClientRect().height:0)+16;
  }
  function mettreAJour(){
    planifie=false;
    if(!liens.length||document.getElementById('vue-doc').hidden){return;}
    var seuil=offsetBandeau()+8, courant=-1;
    for(var i=0;i<cibles.length;i++){
      var el=cibles[i];
      if(el&&el.getBoundingClientRect().top<=seuil){courant=i;}else{break;}
    }
    // En bas de page, force la derniere section (petites sections finales).
    if(window.innerHeight+window.scrollY>=document.body.scrollHeight-2){
      courant=cibles.length-1;
    }
    if(courant<0){courant=0;}
    if(courant===actif){return;}
    if(actif!==null&&liens[actif]){liens[actif].classList.remove('active');
      liens[actif].removeAttribute('aria-current');}
    actif=courant;
    var lien=liens[actif];
    if(lien){
      lien.classList.add('active');
      lien.setAttribute('aria-current','true');
      if(sommaire&&sommaire.scrollHeight>sommaire.clientHeight){
        var lh=lien.offsetTop, lb=lh+lien.offsetHeight;
        if(lh<sommaire.scrollTop){sommaire.scrollTop=lh-8;}
        else if(lb>sommaire.scrollTop+sommaire.clientHeight){
          sommaire.scrollTop=lb-sommaire.clientHeight+8;
        }
      }
    }
  }
  function planifier(){
    if(planifie){return;}
    planifie=true;
    window.requestAnimationFrame(mettreAJour);
  }
    // Tiroir du sommaire (<1000px) : le bouton deplie la colonne laterale.
    // A >=1000px la CSS force l'affichage quel que soit l'etat replie.
    var bToc=document.getElementById('btn-toc'),
        colonne=document.getElementById('sommaire');
    var pointRupture=(window.matchMedia&&window.matchMedia('(min-width: 1000px)'));
    function replierToc(){
      return pointRupture&&pointRupture.matches;
    }
    function appliquerToc(ouvert){
      if(!colonne||!bToc){return;}
      colonne.hidden=!ouvert;
      bToc.setAttribute('aria-expanded',ouvert?'true':'false');
    }
    if(bToc&&colonne){
      bToc.addEventListener('click',function(){
        appliquerToc(colonne.hidden);
      });
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

    // Ancres de titre : copie le lien au clic (navigation natif preservee).
    // Le mouvement reduit ne change rien ici : aucune animation imposee.
    var reduction=(window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)').matches);
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
        var d=document.createElement('span');
        d.textContent=reduction?'Lien copié.':'Lien copié !';
        d.setAttribute('role','status');
        d.className='ancre-retour';
        ancre.insertAdjacentElement('afterend',d);
        window.setTimeout(function(){d.remove();},1600);
      });
    });
    // Recherche : filtre les entrees du sommaire par sous-chaine du libelle.
    // Sans accent ni casse, sans index : le DOM est la seule source.
    var champ=document.getElementById('recherche'),
        compte=document.getElementById('recherche-compte');
    function normaliser(s){
      s=(s||'').toLowerCase();
      if(s.normalize){s=s.normalize('NFD').replace(/[\u0300-\u036f]/g,'');}
      return s;
    }
    var entrees=Array.prototype.slice.call(
      document.querySelectorAll('.col-sommaire nav.toc li'));
    function ancreDirecte(li){
      for(var i=0;i<li.children.length;i++){
        var c=li.children[i];
        if(c.tagName==='A'&&c.getAttribute('href')&&c.getAttribute('href').charAt(0)==='#'){return c;}
      }
      return null;
    }
    function filtrer(){
      if(!champ){return [];}
      var q=normaliser(champ.value.trim());
      entrees.forEach(function(li){
        var a=ancreDirecte(li);
        li._m=!!q&&!!a&&normaliser(a.textContent).indexOf(q)!==-1;
      });
      function descendantCorrespond(li){
        var trouves=li.querySelectorAll('li');
        for(var i=0;i<trouves.length;i++){if(trouves[i]._m){return true;}}
        return false;
      }
      function ascendantCorrespond(li){
        var p=li.parentElement;
        while(p){
          if(p.tagName==='LI'&&p._m){return true;}
          p=p.parentElement;
        }
        return false;
      }
      var visibles=[];
      entrees.forEach(function(li){
        var montrer=!q||li._m||descendantCorrespond(li)||ascendantCorrespond(li);
        li.hidden=!montrer;
        var a=ancreDirecte(li);
        if(montrer&&a){visibles.push(a);}
      });
      var nav=document.querySelector('.col-sommaire nav.toc');
      if(nav){
        Array.prototype.slice.call(nav.querySelectorAll('ul')).forEach(function(ul){
          var enfants=Array.prototype.slice.call(ul.children);
          ul.hidden=!!q&&enfants.length>0&&enfants.every(function(c){return c.hidden;});
        });
      }
      if(compte){
        if(!q){compte.textContent='';}
        else if(!visibles.length){compte.textContent='Aucun résultat';}
        else if(visibles.length===1){compte.textContent='1 résultat';}
        else{compte.textContent=visibles.length+' résultats';}
      }
      return visibles;
    }
    if(champ){
      champ.addEventListener('input',filtrer);
      champ.addEventListener('keydown',function(ev){
        if(ev.key==='Enter'){
          var premiers=filtrer();
          if(premiers.length){ev.preventDefault();premiers[0].click();}
        }else if(ev.key==='Escape'||ev.key==='Esc'){
          if(champ.value){champ.value='';filtrer();}
        }
      });
      filtrer();
    }

    // Seances : precedent/suivant + saut direct, derives des h1 du fragment.
    // Fonctionne pour N seances sans retouche : le DOM est la seule source.
    var seances=Array.prototype.slice.call(
      document.querySelectorAll('#contenu h1[id]'));
    var navSeances=document.getElementById('nav-seances'),
        lienPrec=document.getElementById('seance-prec'),
        lienSuiv=document.getElementById('seance-suiv'),
        selectSeance=document.getElementById('seance-select');
    function libelleSeance(h){
      var copie=h.cloneNode(true);
      var ancre=copie.querySelector('.ancre');
      if(ancre){ancre.remove();}
      return copie.textContent.replace(/\s+/g,' ').trim();
    }
    function seanceCourante(){
      var cible=null;
      try{
        var brut=window.location.hash.slice(1);
        if(brut){cible=document.getElementById(decodeURIComponent(brut));}
      }catch(e){cible=null;}
      var idx=0;
      for(var i=0;i<seances.length;i++){
        if(!cible){break;}
        if(seances[i]===cible){idx=i;break;}
        // FOLLOWING (4) : la cible est apres ce h1, la seance continue.
        if(seances[i].compareDocumentPosition(cible)&4){idx=i;}
        else{break;}
      }
      return idx;
    }
    function majSeances(){
      if(!navSeances||seances.length<2){return;}
      var idx=seanceCourante();
      if(lienPrec){
        var prec=lienPrec.querySelector('span');
        if(idx>0){
          lienPrec.href='#'+seances[idx-1].id;
          lienPrec.removeAttribute('aria-disabled');
          if(prec){prec.textContent=libelleSeance(seances[idx-1]);}
        }else{
          lienPrec.href='#'+seances[0].id;
          lienPrec.setAttribute('aria-disabled','true');
          if(prec){prec.textContent=libelleSeance(seances[0]);}
        }
      }
      if(lienSuiv){
        var suiv=lienSuiv.querySelector('span');
        if(idx<seances.length-1){
          lienSuiv.href='#'+seances[idx+1].id;
          lienSuiv.removeAttribute('aria-disabled');
          if(suiv){suiv.textContent=libelleSeance(seances[idx+1]);}
        }else{
          lienSuiv.href='#'+seances[seances.length-1].id;
          lienSuiv.setAttribute('aria-disabled','true');
          if(suiv){suiv.textContent=libelleSeance(seances[seances.length-1]);}
        }
      }
      if(selectSeance){selectSeance.value=seances[idx].id;}
    }
    if(navSeances&&seances.length>1&&lienPrec&&lienSuiv&&selectSeance){
      seances.forEach(function(h){
        var opt=document.createElement('option');
        opt.value=h.id;
        opt.textContent=libelleSeance(h);
        selectSeance.appendChild(opt);
      });
      selectSeance.addEventListener('change',function(){
        if(selectSeance.value){window.location.hash='#'+selectSeance.value;}
      });
      navSeances.hidden=false;
      window.addEventListener('hashchange',majSeances);
      majSeances();
    }
    window.addEventListener('scroll',planifier,{passive:true});
    window.addEventListener('resize',planifier,{passive:true});
    window.addEventListener('hashchange',planifier);
    mettreAJour();
})();
