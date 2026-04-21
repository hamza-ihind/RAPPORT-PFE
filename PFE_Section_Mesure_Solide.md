# Partie : Vérification qu'un Part est Solide et Plein

---

## 1. Définition et contexte

Dans l'environnement CATIA V5, un **Part** est un fichier de conception (`.CATPart`)
qui peut contenir deux types de géométrie :

- **La géométrie solide** — créée dans le workbench *Part Design*, stockée dans le `PartBody`.
  Elle représente un volume fermé, avec une masse et des propriétés mécaniques calculables.
- **La géométrie surfacique** — créée dans le workbench *Generative Shape Design* (GSD),
  stockée dans des `HybridBody`. Elle ne définit pas de volume à elle seule.

Un Part est dit **solide et plein** lorsque son corps principal (`MainBody`) contient
des features opérationnelles dont le résultat cumulé produit un **volume strictement positif**.
Un volume nul signifie que les opérations booléennes (ajouts, soustractions) se sont
intégralement annulées, ou qu'aucune feature solide n'a été créée.

---

## 2. Pourquoi mesurer le volume ? — Justification métier

La vérification du volume n'est pas une simple formalité géométrique.
Elle répond à des exigences concrètes dans un contexte industriel :

### 2.1 Fiabilité des analyses aval

Toute simulation numérique (analyse par éléments finis, calcul thermique, simulation
de mise en forme) requiert un solide fermé avec un volume défini.
Un Part au volume nul ou mal formé génère des erreurs dans les solveurs CAE,
compromettant l'intégrité des résultats d'analyse.

### 2.2 Cohérence de la nomenclature et des calculs de masse

Dans un assemblage CATIA (`CATProduct`), CATIA calcule automatiquement la masse
de chaque composant à partir de son volume et de la densité du matériau assigné.
Un Part sans volume valide fausse les calculs de masse totale, ce qui a un impact
direct sur les études d'équilibre, de centrage et de résistance structurelle.

### 2.3 Faisabilité fabrication

Un modèle destiné à la fabrication (usinage, fonderie, impression 3D) doit obligatoirement
représenter un volume solide continu. Un volume nul ou une géométrie invalide
empêche la génération correcte des trajectoires d'outil (FAO) et rend la pièce
non-usinable numériquement.

### 2.4 Automatisation et contrôle qualité

Dans le cadre d'une chaîne numérique automatisée, la vérification systématique
du volume par macro permet de **filtrer les modèles invalides avant leur intégration**
dans un assemblage ou leur transmission à un bureau de fabrication,
évitant ainsi des erreurs coûteuses en phase tardive du projet.

---

## 3. Comment CATIA mesure-t-il le volume ?

### 3.1 Le workbench SPAWorkbench (Space Analysis)

CATIA V5 expose un workbench dédié aux mesures géométriques avancées :
le **Space Analysis Workbench** (`SPAWorkbench`).
Il est accessible par macro via la méthode `GetWorkbench("SPAWorkbench")`
appliquée au document actif.

Ce workbench met à disposition la méthode `GetMeasurable()`, qui accepte
un objet géométrique (Body, Face, Surface) et retourne un objet `Measurable`
exposant les propriétés physiques calculées :

| Propriété | Signification | Unité retournée |
|---|---|---|
| `.Volume` | Volume total du solide | m³ |
| `.Area` | Aire totale de la surface extérieure | m² |
| `GetCOG()` | Coordonnées du centre de gravité | m |

> **Note sur les unités :** CATIA travaille en système SI interne (mètres).
> Les valeurs retournées par `SPAWorkbench` doivent être converties :
> - Volume : multiplier par 10⁹ pour obtenir des mm³
> - Aire : multiplier par 10⁶ pour obtenir des mm²

### 3.2 Mécanisme de calcul interne

Le moteur géométrique de CATIA (basé sur le noyau **CGM — Convergent Geometry**)
calcule le volume par intégration numérique sur la représentation B-Rep
(Boundary Representation) du solide.

La représentation B-Rep décrit un solide par l'ensemble de ses **faces, arêtes et sommets**.
Pour qu'un volume soit calculable :
- La géométrie doit être **fermée** (pas de face manquante)
- Les normales de toutes les faces doivent pointer vers l'**extérieur** du solide
- Aucune **auto-intersection** ne doit exister sur les faces ou les arêtes

Si l'une de ces conditions est violée, CATIA retourne un volume nul ou lève une erreur.

---

## 4. Stratégies de correction

Lorsque la macro détecte un volume nul ou une anomalie, plusieurs causes
sont possibles. Le tableau suivant présente les cas fréquents et les actions correctives.

| Cas détecté | Cause probable | Action corrective |
|---|---|---|
| `PartBody` vide (`Shapes.Count = 0`) | Aucune feature solide créée | Créer un Pad, Shaft ou autre feature de base dans Part Design |
| Volume = 0 avec features présentes | Pocket/Pocket de même dimension qu'un Pad (annulation totale) | Vérifier l'arbre de construction — réduire la profondeur du Pocket |
| Erreur lors de `GetMeasurable()` | Géométrie invalide (auto-intersection, face ouverte) | Utiliser *Analyze → Check Geometry* dans CATIA pour localiser les défauts |
| Document n'est pas un PartDocument | Mauvais type de fichier ouvert (Product, Drawing) | Ouvrir le fichier `.CATPart` correspondant avant de lancer la macro |
| Volume anormalement faible | Feature mal dimensionnée ou unités incorrectes | Vérifier les unités du document (`Tools → Options → Parameters & Measure`) |

### 4.1 Utiliser Check Geometry

L'outil **Analyze → Check Geometry** (disponible dans Part Design et GSD) permet
d'inspecter automatiquement un solide et d'identifier :
- Les faces en auto-intersection
- Les arêtes non-manifold (partagées par plus de deux faces)
- Les faces de surface nulle

Il est recommandé d'exécuter cet outil systématiquement avant toute analyse volumique
par macro, afin de garantir la validité topologique du modèle.

### 4.2 Reconstruire l'arbre de features

Lorsqu'une annulation de volume est constatée, il est utile de **désactiver les features**
une par une (clic droit → *Deactivate*) pour identifier celle qui neutralise le volume.
Cette approche par isolation permet un diagnostic rapide sans modifier définitivement
la géométrie.

---

## 5. Limites de la méthode

- La macro analyse uniquement le **`MainBody`** (PartBody principal).
  Les corps secondaires (*Bodies*) et les géométries surfaciques (*HybridBodies*)
  ne sont pas pris en compte dans cette vérification.
- Le **`SPAWorkbench`** doit être disponible dans la licence CATIA active.
  En l'absence de ce module, la macro lèvera une erreur à l'appel de `GetWorkbench()`.
- La précision du calcul volumique dépend de la **tolérance de modélisation** définie
  dans les options CATIA (`Tools → Options → Shape → General`).

---

*Document produit dans le cadre du Projet de Fin d'Études — ENSA Agadir*
