---
name: copy-test-practice
description: >
  Génère des questionnaires d'entraînement originaux en réseaux informatiques (Module 117) en français,
  inspirés de documents fournis (PDF ou Markdown de tests existants), sans copier les questions.
  Utilise ce skill dès que Thomas fournit un ou plusieurs documents de test en réseaux et demande
  à s'entraîner, à créer un nouveau questionnaire, à réviser, ou à générer des questions similaires.
  Déclencher aussi pour : "génère un test", "crée un questionnaire", "inspire-toi de ces docs",
  "je veux réviser", "fais-moi pratiquer", "questionnaire réseau", "crée des exercices similaires".
  Toujours utiliser ce skill quand des fichiers de tests réseau sont présents ET que Thomas veut pratiquer.
---

# copy-test-practice

Génère un questionnaire de réseau **original** en français, inspiré thématiquement des documents fournis.

---

## Étape 1 — Analyser les documents sources

Parcourir tous les documents fournis (PDF ou Markdown) et extraire :

- Les **thèmes couverts** (ex : classes IP, masques, couches OSI, topologies, câblage, commutateurs, WiFi, ARP…)
- Les **types de questions** utilisés (QCM, questions ouvertes, tableaux à compléter, calculs, schémas à légender)
- Le **niveau de difficulté** et le **style pédagogique** (cours EPSIC Module 117, niveau apprenti CFC IT)
- Le **nombre de points** par question si indiqué

Ne jamais réutiliser une question à l'identique. S'inspirer des thèmes, pas des formulations.

---

## Étape 2 — Choisir le contenu du nouveau questionnaire

Si l'utilisateur ne précise pas :
- Couvrir **3 à 5 thèmes distincts** tirés des documents sources
- Varier les types de questions : au moins 1 QCM, 1 question ouverte, 1 exercice de calcul ou tableau
- Viser **10 à 15 questions** pour un questionnaire complet, ou **5 à 8** pour un questionnaire court

Si l'utilisateur précise un thème ou un nombre de questions, respecter sa demande.

---

## Étape 3 — Générer le questionnaire en Typst

### Format de sortie : code Typst

Le questionnaire est généré sous forme de **code Typst** (`.typ`), prêt à compiler en PDF.
Utiliser le template ci-dessous comme base, en adaptant le numéro, le thème et les questions.

```typst
#set page(paper: "a4", margin: (x: 2.5cm, y: 2cm))
#set text(font: "Linux Libertine", size: 11pt, lang: "fr")
#set par(justify: true)

// En-tête
#grid(
  columns: (1fr, 1fr),
  align(left)[*Module 117*],
  align(right, text(fill: rgb("#4472C4"))[*Questionnaire No X*])
)
#line(length: 100%, stroke: 0.5pt)
#v(0.3cm)

// Question ouverte
#block[
  *1.* [Texte de la question]

  #v(0.2cm)
  #line(length: 100%, stroke: (dash: "dashed", thickness: 0.4pt))
  #line(length: 100%, stroke: (dash: "dashed", thickness: 0.4pt))
  #line(length: 100%, stroke: (dash: "dashed", thickness: 0.4pt))
  #v(0.3cm)
]

// QCM
#block[
  *2.* [Texte de la question QCM]

  #v(0.1cm)
  #list(
    marker: [☐],
    [Réponse A],
    [Réponse B],
    [Réponse C],
    [Réponse D],
  )
  #v(0.2cm)
]

// Tableau à compléter
#block[
  *3.* [Consigne du tableau]

  #v(0.2cm)
  #table(
    columns: (2fr, 1.5fr, 1.5fr, 1fr, 1fr),
    align: center,
    stroke: 0.5pt,
    table.header([*IP*], [*Masque*], [*NET\_ID*], [*Subnet\_ID*], [*Host\_ID*]),
    [10.x.x.x / xx], [], [], [], [],
  )
  #v(0.3cm)
]
```

### Règles de génération

- **Toujours en français**
- Les valeurs numériques (IPs, masques, préfixes) doivent être **différentes** des documents sources
- Les scénarios doivent être **nouveaux** (ne pas reprendre "172.16.25.18" si c'est dans la source)
- Varier les contextes : PME, école, hôpital, domicile, datacenter…
- Pour les calculs IP : utiliser des adresses valides et des sous-réseaux cohérents (vérifier les calculs avant de les inclure)
- Pour les QCM : prévoir **4 choix**, un seul correct sauf mention contraire, les distracteurs doivent être plausibles
- Échapper les underscores dans les textes Typst : `NET\_ID` et non `NET_ID`

### Thèmes disponibles (basés sur Module 117)

| Thème | Types de questions typiques |
|---|---|
| Classes d'adresses IPv4 (A–E) | Tableau binaire, plages décimales, QCM |
| Masques de réseau et sous-réseau | Intersection logique AND, tableau NET_ID/Subnet/Host |
| Modèle OSI | Nommer les couches, classer des composants, schéma |
| Topologies et étendues réseau | Nommer des schémas, définir PAN/LAN/WAN/MAN… |
| Composants réseau (hub, switch, routeur) | Différences, rôles, couches OSI, domaines de collision/diffusion |
| Câblage (paires torsadées, fibre optique) | Catégories, couleurs, structure S-FTP, multimode vs monomode |
| Couche 2 : trame 802.3, ARP, adresse MAC | Structure de trame, résolution ARP, cache, ipconfig |
| Commutateurs administrables | VLAN, port mirroring, spanning tree, stacking/cascading |
| WiFi (802.11) | Standards, CSMA/CA, sécurité, RADIUS |
| Adressage privé (RFC 1918) & VLSM | Dimensionnement, découpage VLSM, passerelles |

---

## Étape 4 — Vérification syntaxique Typst (OBLIGATOIRE)

Avant de livrer le code, relire le Typst généré et vérifier **chaque point** :

- [ ] Toutes les accolades `{` `}` et crochets `[` `]` sont bien fermés et appariés
- [ ] Les underscores dans les textes sont échappés : `NET\_ID`, `Host\_ID`, `Subnet\_ID`
- [ ] Les `#table(...)` ont autant de cellules par ligne que de colonnes déclarées
- [ ] Les `#grid(...)` ont autant de `columns` que de blocs enfants
- [ ] Pas de caractères spéciaux non échappés dans les chaînes (`#`, `@`, `\` hors contextes prévus)
- [ ] Chaque `#block[...]` est bien fermé
- [ ] Les `#list(marker: [...], [...])` utilisent la syntaxe correcte (virgules entre éléments)
- [ ] Les couleurs hex sont au format `rgb("#XXXXXX")`

Si une erreur est détectée lors de la relecture, la corriger avant de livrer.

---

## Étape 5 — Générer le corrigé (optionnel)

Si l'utilisateur demande aussi le corrigé (ou une version "solution") :

- Générer un **second fichier `.typ`** avec les réponses intégrées sous chaque question
- Pour les calculs, montrer **la démarche** (pas seulement le résultat)
- Pour les QCM, marquer la bonne réponse avec `[☑]` et justifier brièvement
- Utiliser `text(fill: rgb("#C00000"))[réponse]` pour distinguer visuellement les réponses du corrigé
- Appliquer la même vérification syntaxique (Étape 4) sur le corrigé aussi

---

## Étape 6 — Livraison

- Livrer le questionnaire comme fichier `.typ` (artifact ou fichier téléchargeable)
- Proposer systématiquement de générer le corrigé séparément si non demandé
- Rappeler que le fichier se compile avec `typst compile questionnaire.typ`

---

## Exemples de consignes utilisateur et comportement attendu

| Consigne | Action |
|---|---|
| "Génère un questionnaire sur les masques de sous-réseau" | Questionnaire `.typ` focalisé sur ce thème, ~8 questions |
| "Inspire-toi de ces PDFs pour faire un test de révision" | Analyser les PDFs, couvrir leurs thèmes, ~12 questions |
| "Fais un questionnaire court sur OSI et WiFi" | 5–6 questions, 2–3 par thème |
| "Même chose mais avec le corrigé" | Questionnaire `.typ` + corrigé `.typ` séparé |
| "Crée un test de niveau difficile" | Questions de calcul VLSM, scénarios multi-sites, justifications poussées |

---

## Contrôle qualité avant livraison

Vérifier avant de livrer :
- [ ] Aucune question copiée mot pour mot depuis les sources
- [ ] Toutes les adresses IP et masques sont valides et les calculs corrects
- [ ] Au moins 2 types de questions différents
- [ ] Entièrement en français
- [ ] Les distracteurs des QCM sont plausibles
- [ ] **Vérification syntaxique Typst complète (Étape 4) effectuée**
