# Glossaire — Mots-clés CATIA VBS / CATScript

> Référence des objets et méthodes utilisés dans les macros CATIA V5.

---

## Objets principaux

| Mot-clé | Description |
|---|---|
| `CATIA` | Objet racine de l'application CATIA. Point d'entrée de toute macro — donne accès aux documents, paramètres et sessions. |
| `ActiveDocument` | Retourne le document actuellement ouvert et actif dans CATIA (Part, Product, Drawing, etc.). |
| `PartDocument` | Type de document représentant un fichier `.CATPart`. Permet l'accès à la géométrie solide et aux features. |
| `Part` | Objet principal d'un PartDocument. Contient le PartBody, les paramètres, les relations et la géométrie. |
| `MainBody` | Corps solide principal d'un Part (`PartBody`). C'est là où sont stockées toutes les features solides. |
| `Body` | Objet représentant un corps solide (PartBody ou corps secondaire). Contient une collection de shapes/features. |
| `Shapes` | Collection de toutes les features solides (Pad, Shaft, Pocket…) contenues dans un Body. |
| `HybridBodies` | Collection des corps hybrides (contenant surfaces + wireframe) dans un Part ou un Body. |
| `HybridShapes` | Collection des éléments surfaciques et filaires (splines, extrusions, fills…) dans un HybridBody. |

---

## Mesure & Analyse (SPA)

| Mot-clé | Description |
|---|---|
| `SPAWorkbench` | Workbench "Space Analysis" de CATIA. Fournit les outils de mesure géométrique (volume, aire, centre de masse). |
| `GetWorkbench()` | Méthode du document pour accéder à un workbench spécifique. Ex : `oDoc.GetWorkbench("SPAWorkbench")`. |
| `GetMeasurable()` | Méthode du SPAWorkbench qui crée un objet `Measurable` à partir d'un Body ou d'une surface. |
| `Measurable` | Objet retourné par `GetMeasurable()`. Expose les propriétés de mesure : volume, aire, centre de masse. |
| `.Volume` | Propriété de `Measurable`. Retourne le volume du solide **en m³** (à convertir en mm³ via ×10⁹). |
| `.Area` | Propriété de `Measurable`. Retourne l'aire totale de la surface du solide **en m²** (×10⁶ pour mm²). |
| `GetCOG()` | Méthode de `Measurable`. Retourne les coordonnées du centre de gravité (Center Of Gravity) du solide. |

---

## Surfaces & Géométrie (GSD)

| Mot-clé | Description |
|---|---|
| `GSMWorkbench` | Workbench "Generative Shape Design". Donne accès aux outils de création et d'analyse surfacique. |
| `HybridShapeFactory` | Fabrique d'objets surfaciques dans GSD. Permet de créer des surfaces, courbes et points par macro. |
| `Reference` | Objet qui encapsule une entité géométrique (face, arête, surface) pour l'utiliser dans les méthodes CATIA. |
| `CreateReferenceFromObject()` | Crée un objet `Reference` à partir d'un objet géométrique, nécessaire pour beaucoup d'opérations GSD. |
| `SurfaceType` | Propriété indiquant le type d'une surface (plane, cylindrique, NURBS…). Utile pour classer les géométries. |
| `Face` | Représente une face individuelle d'un solide ou d'une surface. Peut être analysée séparément. |

---

## Contrôle de flux VBS

| Mot-clé | Description |
|---|---|
| `TypeName()` | Fonction VBS qui retourne le type d'un objet sous forme de chaîne. Utilisé pour vérifier si un document est un `PartDocument`. |
| `On Error GoTo` | Directive de gestion d'erreurs. Redirige l'exécution vers un label défini si une erreur survient. |
| `MsgBox` | Affiche une boîte de dialogue à l'utilisateur avec un message, une icône et un titre personnalisables. |
| `Set` | Mot-clé VBS pour affecter un objet à une variable. Obligatoire pour tous les objets CATIA (pas les types simples). |
| `Nothing` | Valeur nulle pour les objets VBS. Utilisé en fin de macro pour libérer les références mémoire (`Set obj = Nothing`). |
| `Format()` | Formate un nombre en chaîne de caractères avec un masque. Ex : `Format(val, "#,##0.000")` pour l'affichage. |
| `Chr(13)` | Caractère retour à la ligne dans une chaîne VBS. Utilisé pour structurer les messages `MsgBox`. |

---

## Sélection & Interaction

| Mot-clé | Description |
|---|---|
| `Selection` | Objet CATIA représentant la sélection active dans l'interface. Permet de récupérer ou définir des éléments sélectionnés. |
| `SelectElement2()` | Méthode de `Selection` qui invite l'utilisateur à sélectionner un élément dans l'interface CATIA via un filtre. |
| `Item(i)` | Méthode générique pour accéder au i-ème élément d'une collection (Shapes, Bodies, HybridBodies…). |
| `.Count` | Propriété de toute collection CATIA. Retourne le nombre d'éléments qu'elle contient. |
| `.Name` | Propriété universelle. Retourne ou définit le nom d'un objet CATIA (Part, Body, feature, etc.). |

---

*Macro CATIA V5 — Rapport PFE*
