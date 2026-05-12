# Explication détaillée — `silver_faces.vbs`

---

## Contexte : Qu'est-ce que CATIA ?

**CATIA** est un logiciel de conception 3D professionnel utilisé dans l'aéronautique, l'automobile et l'industrie. On y construit des **modèles 3D** composés de :

- **Parts** (`.CATPart`) — un seul objet 3D (ex. : un panneau de portière de voiture)
- **Products** (`.CATProduct`) — un assemblage de plusieurs Parts (ex. : la voiture entière)

À l'intérieur d'un Part, la géométrie est organisée dans des conteneurs appelés **HybridBodies** (comme des dossiers), et à l'intérieur de chaque dossier se trouvent des **HybridShapes** — les surfaces ou courbes qui constituent la forme.

Une **macro** (`.vbs` = Visual Basic Script) est un petit programme qui automatise des actions dans CATIA, comme si un humain cliquait très rapidement sur des boutons.

---

## Qu'est-ce qu'une « Silver Face » ?

Une **silver face** (ou « sliver face ») est une **surface minuscule, quasi invisible**, qui s'est retrouvée sur le modèle 3D par accident. Imaginez découper une feuille de papier et laisser une bandelette microscopique — cette bandelette, c'est la silver face.

Elles apparaissent généralement lorsque :

- On importe un fichier depuis un autre logiciel (formats IGES, STEP) et la conversion est imparfaite
- On découpe/taille des surfaces et un fragment résiduel minuscule reste en place
- Deux surfaces ne se rejoignent pas parfaitement et laissent un espace infime comblé par une surface fantôme

Ce sont des **défauts qualité** qui peuvent causer des erreurs de simulation, des problèmes de fabrication et des échecs en aval.

---

## Les trois constantes (valeurs de configuration)

```vbs
Const SEUIL_MM2    = 0.01    ' Seuil de détection (mm²)
Const SEUIL_DELETE = 0.0001  ' En dessous : suppression directe
Const HEALING_DIST = 0.1     ' Distance de fusion pour le Healing (mm)
```

| Constante      | Valeur     | Signification                                                                            |
| -------------- | ---------- | ---------------------------------------------------------------------------------------- |
| `SEUIL_MM2`    | 0.01 mm²   | Toute surface plus petite que cette aire est considérée comme une silver face            |
| `SEUIL_DELETE` | 0.0001 mm² | Surface quasi-nulle → suppression directe                                                |
| `HEALING_DIST` | 0.1 mm     | Lors du Healing, les surfaces situées à moins de 0.1 mm l'une de l'autre sont fusionnées |

---

## Déroulement global — Ce que fait la macro, étape par étape

### Étape 1 — `CATMain()` : Le point d'entrée

C'est la fonction que CATIA appelle quand on lance la macro. Elle :

1. **Récupère le document actif** — le fichier actuellement ouvert dans CATIA.
2. **Vérifie son type :**
   - Si c'est un Part seul → scanner uniquement ce Part.
   - Si c'est un Product (assemblage) → parcourir **tous les Parts ouverts** et scanner chacun.
   - Si c'est autre chose → afficher un message d'erreur et s'arrêter.
3. **Appelle `ScanPart`** pour détecter les silver faces.
4. **Affiche un rapport** indiquant :
   - Le nombre total de surfaces vérifiées
   - Le nombre de silver faces trouvées
   - Leurs noms, emplacements, aires et la stratégie de réparation applicable
5. **Demande confirmation** : « Voulez-vous appliquer les corrections automatiques ? » (dialogue Oui/Non).
6. Si **Oui** → appelle `CorrigerPart` pour les corriger.

---

### Étape 2 — `ScanPart()` : Le détective

Cette fonction inspecte toutes les surfaces du Part et mesure leur aire.

```
Pour chaque HybridBody (dossier) dans le Part :
    Pour chaque HybridShape (surface) dans ce dossier :
        Mesurer l'aire de la surface
        Si 0 < aire < 0.01 mm² → c'est une silver face → l'enregistrer
```

**Comment l'aire est mesurée :**

- Le code utilise le `SPAWorkbench` — l'**atelier d'analyse spatiale** de CATIA, une boîte à outils intégrée pour mesurer la géométrie (aire, volume, longueur, etc.).
- Il crée une **référence** (un pointeur vers la surface), obtient un objet **Measurable**, lit `.Area` (retourné en m²), puis multiplie par 1 000 000 pour convertir en mm².

**Ce qui est enregistré pour chaque silver face :**

- Son nom
- Le Part et le dossier qui la contiennent
- Son aire exacte en mm²
- La stratégie de réparation qui sera appliquée :
  - `[A] Suppression` — si aire < 0.0001 mm² (quasi-nulle, à supprimer directement)
  - `[B] Healing` — si aire entre 0.0001 et 0.01 mm² (petite mais non nulle, à fusionner)

---

### Étape 3 — `CorrigerPart()` : Le réparateur

Cette fonction applique les deux stratégies de correction automatiques.

---

#### Stratégie [A] — Suppression directe (surfaces quasi-nulles)

> Utilisée quand : aire < 0.0001 mm² — la surface est si petite qu'elle est pratiquement inexistante.

```vbs
oPart.Parent.Selection.Clear
oPart.Parent.Selection.Add oShape
oPart.Parent.Selection.Delete
```

- Cela simule un humain qui clique sur la surface dans CATIA et appuie sur Supprimer.
- La boucle s'exécute **en sens inverse** (du dernier au premier) — c'est une astuce classique : si on supprime l'élément n°3 dans une liste de 5, l'élément n°4 devient le n°3 et serait sauté à l'itération suivante. Parcourir en sens inverse évite ce problème.

---

#### Stratégie [B] — Healing (surfaces petites mais non nulles)

> Utilisée quand : 0.0001 mm² ≤ aire < 0.01 mm²

Le **Healing** dans CATIA est un outil de réparation qui :

- Prend un groupe de surfaces
- Trouve les micro-écarts ou chevauchements entre elles
- Comble/ferme ces écarts dans une tolérance donnée (ici : 0.1 mm)
- Produit un groupe de surfaces « guéri » sans silver faces

La macro :

1. Crée un nouveau feature `HybridShapeHealing` (l'opération de Heal).
2. Ajoute **toutes les surfaces du dossier** (pas seulement la silver face — le Healing travaille sur l'ensemble).
3. Fixe la distance de fusion à `HEALING_DIST = 0.1 mm`.
4. Ajoute le feature au dossier.
5. Appelle `oPart.Update` — cette commande demande à CATIA de **recalculer/reconstruire** le modèle avec le nouveau Heal appliqué (comme appuyer sur F5 pour actualiser).

---

### Étape 4 — Rapport final

Après les corrections, une boîte de dialogue affiche :

- Le nombre de surfaces **supprimées** (Stratégie A)
- Le nombre d'**opérations de Healing** créées (Stratégie B)
- Un journal détaillé de chaque action effectuée

Elle rappelle également les **cas manuels** que la macro ne peut pas corriger automatiquement :

- Une face résiduelle après une opération Trim → doit être supprimée et comblée manuellement
- Une surface créée par Offset avec forte courbure → doit être corrigée dans la conception source

---

## Résumé en une phrase

Cette macro **scanne toutes les surfaces du modèle CATIA, détecte celles qui sont anormalement petites (< 0.01 mm²), les signale à l'utilisateur et — avec son accord — supprime directement les quasi-nulles ou applique une opération de Healing pour fusionner les autres avec leurs surfaces voisines.**

---

## Tableau récapitulatif des stratégies

| Stratégie           | Condition                | Méthode CATIA                 | Cas d'origine                                |
| ------------------- | ------------------------ | ----------------------------- | -------------------------------------------- |
| **[A] Suppression** | aire < 0.0001 mm²        | `Selection.Delete`            | Surface quasi-dégénérée (aire ≈ 0)           |
| **[B] Healing**     | 0.0001 ≤ aire < 0.01 mm² | `HybridShapeHealing`          | Import IGES/STEP, micro-écart entre surfaces |
| _(Manuel)_          | Face après Trim          | Delete Face + Fill            | Résidu d'opération de découpe                |
| _(Manuel)_          | Offset forte courbure    | Réduire offset / segmenter    | Paramètre de conception inadapté             |
| _(Manuel)_          | Import répété            | Nettoyer dans logiciel source | Problème en amont du fichier source          |
