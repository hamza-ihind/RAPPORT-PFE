# Sliver Faces (Faces en Éclat) — CATIA V5

---

## 1. Définition et Contexte

### 1.1 Qu'est-ce qu'une Sliver Face ?

Une **Sliver Face** est une face géométrique extrêmement fine, étroite,
ou en forme d'aiguille, qui apparaît lors de la modélisation, de l'import
ou de l'export de fichiers CAO.

**En termes simples :**
- Imagine deux surfaces qui sont *presque* au même endroit — mais pas exactement
- L'écart entre elles est infime (quelques microns ou fractions de mm)
- CATIA essaie de construire une face pour combler cet espace → résultat :
  une face ultra-fine, quasiment invisible à l'œil, mais géométriquement présente
- Cette face est la **sliver face** — elle n'a quasiment pas de largeur,
  mais elle existe dans le modèle et perturbe toutes les opérations suivantes

### 1.2 Caractéristiques typiques

- Ratio longueur/largeur extrêmement élevé (ex: 100mm de long pour 0.001mm de large)
- Aire quasi nulle mais non nulle (≠ face dégénérée à aire = 0)
- Souvent **invisible** dans la vue 3D normale — détectable uniquement par analyse
- Apparaît fréquemment sur des **fichiers importés** (IGES, STEP, Parasolid)

---

## 2. Pourquoi ça arrive ? — Causes géométriques

### 2.1 La quasi-coïncidence (Near-Coincidence)

La cause principale des sliver faces est la **quasi-coïncidence** :
deux entités géométriques (arêtes, faces, surfaces) qui sont censées
être identiques, mais qui présentent un écart infime dû à :

- Des **tolérances de modélisation différentes** entre logiciels (CATIA vs SolidWorks vs STEP)
- Des **conversions de format** qui arrondissent les coordonnées (IGES → CATIA)
- Des **imprécisions numériques** dans les calculs flottants (virgule flottante)
- Des **opérations booléennes imparfaites** (Join, Trim, Split) qui laissent
  un micro-écart là où deux surfaces devraient se toucher exactement

### 2.2 Illustration schématique

```
SITUATION NORMALE :
Surface A ────────────────────
Surface B ────────────────────  ← identiques, parfaitement coïncidentes
→ Résultat : une seule arête partagée ✓

SITUATION SLIVER :
Surface A ────────────────────
                              ← écart de 0.001 mm
Surface B ─────────────────────
→ CATIA construit une face pour combler l'espace
→ Cette face = SLIVER FACE ✗ (ultra-fine, problématique)
```

### 2.3 Cas concrets dans CATIA

| Situation | Comment la sliver face apparaît |
|---|---|
| Import IGES / STEP | Les coordonnées sont arrondies → deux surfaces qui devaient coïncider ne le font plus |
| Join de deux surfaces | Un micro-écart entre les bords crée une face de jonction ultra-fine |
| Offset d'une surface complexe | Des zones à forte courbure créent des faces dégénérées très étroites |
| Trim / Split imprécis | Le plan de coupe crée une face résiduelle quasi-nulle |
| Copie-miroir | Un arrondi numérique crée un infime décalage entre l'original et le miroir |

---

## 3. Justification Métier — Pourquoi c'est critique

| Opération impactée | Problème causé par la sliver face |
|---|---|
| **Boolean (Join, Coupure)** | Échec de l'opération ou résultat géométriquement incohérent |
| **Maillage FEA** | Les éléments maillés sur la sliver face sont dégénérés → simulation invalide |
| **Impression 3D / STL** | Le fichier STL contient des triangles dégénérés → pièce non imprimable |
| **Offset / Thick Surface** | CATIA ne sait pas comment épaissir une face de largeur ≈ 0 |
| **FAO (trajectoires outil)** | L'outil tente d'usiner une face quasi-inexistante → trajectoire erronée |
| **Contrôle qualité Q-Checker** | La face passe sous le seuil minimal d'aire → flaggée comme défaut critique |

---

## 4. Détection dans CATIA V5

### 4.1 Manuellement — Check Geometry

```
Analyze → Check Geometry → cocher "Small Faces" / "Degenerate Faces"
```

CATIA liste les faces dont l'aire est inférieure à un seuil défini.
Ajuster le seuil dans les options pour attraper les faces ultra-fines.

### 4.2 Manuellement — Mesure directe

Sélectionner une face suspecte → `Measure Item` → lire l'aire.
Si aire < 0.01 mm² pour une feature censée être grande → sliver face.

### 4.3 Par macro VBS — Logique de détection

```
ÉTAPE 1 — Vérifier PartDocument
          → CATIA.ActiveDocument / TypeName check

ÉTAPE 2 — Accéder aux HybridBodies (corps surfaciques)
          → Part.HybridBodies → HybridShapes

ÉTAPE 3 — Pour chaque surface dans chaque HybridBody
          → Boucle : For i = 1 To oHybridShapes.Count

ÉTAPE 4 — Créer une référence et mesurer l'aire
          → oRef = Part.CreateReferenceFromObject(oShape)
          → oMeasure = oSPA.GetMeasurable(oRef)
          → dAire = oMeasure.Area × 10^6  [m² → mm²]

ÉTAPE 5 — Comparer à un seuil minimal (ex: 0.01 mm²)
          → dAire < SEUIL_MIN → Sliver Face détectée

ÉTAPE 6 — Stocker le nom et l'aire de la face suspecte
          → sListeDefauts = sListeDefauts & oShape.Name & " | " & dAire & " mm²"

ÉTAPE 7 — Afficher le rapport complet
          → MsgBox : nb de sliver faces + liste + seuil utilisé
```

### 4.4 Seuil de détection

Le seuil est à définir selon le contexte du projet :

| Contexte | Seuil recommandé |
|---|---|
| Pièces aéronautiques (haute précision) | < 0.001 mm² |
| Pièces automobiles standard | < 0.01 mm² |
| Pièces à imprimer en 3D | < 0.1 mm² |
| Modèles d'import IGES/STEP | < 1.0 mm² (seuil large pour attraper plus) |

---

## 5. Stratégies de Correction

| Cas | Action corrective dans CATIA |
|---|---|
| Sliver sur import IGES/STEP | Utiliser **Healing** : `Insert → Operations → Healing` pour combler les micro-écarts |
| Micro-écart entre deux surfaces | `Join` avec option **"Check tangency"** désactivée + tolérance augmentée |
| Face résiduelle après Trim | Supprimer la face manuellement + reconstruire avec **Fill** |
| Offset qui crée des slivers | Réduire la valeur d'offset ou segmenter la surface avant offset |
| Import répété avec slivers | Nettoyer le fichier source dans le logiciel d'origine avant export |
| Sliver quasi-dégénérée (aire ≈ 0) | Utiliser **Delete Face** puis **Fill** pour reconstruire proprement |

---

## 6. Limites de la Méthode Macro

- **Le seuil est subjectif** — Une face de 0.005 mm² peut être une sliver
  dans un contexte, et une feature intentionnelle dans un autre.
  La macro doit permettre à l'utilisateur de paramétrer ce seuil.
- **Accès face par face limité** — VBS ne peut pas toujours descendre
  au niveau de chaque face individuelle d'une surface composite.
  La macro analyse les surfaces (HybridShapes) et non leurs faces internes.
- **Faux positifs** — Certaines features intentionnellement petites
  (congés minuscules, points de contact) peuvent être détectées à tort.

---

## 7. Ressources

- **Fusion 360 Tutorial** → "How to Avoid Near Coincidence and Sliver Faces"
  (https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/How-to-Avoid-Near-Coincidence-and-Sliver-Faces-in-Fusion-360.html)
- **COMSOL Blog** → "Working with Imported CAD Designs" — section sliver faces
  (https://www.comsol.com/blogs/working-with-imported-cad-designs/)
- **CATIA Help** → `Analyze → Check Geometry → Small Faces / Degenerate Faces`
- **CATIA V5 Automation** → CreateReferenceFromObject + GetMeasurable
  (https://v5vb.wordpress.com/2010/01/11/check-geometry-types/)

---

*Document produit dans le cadre du Projet de Fin d'Études — ENSA Agadir*
