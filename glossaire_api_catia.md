# Glossaire — Mots-clés de l'API CATIA V5

Les termes suivants sont extraits des macros développées dans le cadre du contrôle qualité.
Il s'agit exclusivement d'objets, méthodes et propriétés issus du modèle objet CATIA V5.

| Mot-clé CATIA               | Description                                                                                          |
| --------------------------- | ---------------------------------------------------------------------------------------------------- |
| `CATIA`                     | Objet racine de l'application CATIA V5 ; point d'entrée de toute macro.                              |
| `ActiveDocument`            | Document actuellement ouvert et actif dans la session CATIA.                                         |
| `Documents`                 | Collection de tous les documents ouverts dans la session CATIA.                                      |
| `PartDocument`              | Type de document correspondant à un fichier `.CATPart`.                                              |
| `ProductDocument`           | Type de document correspondant à un fichier `.CATProduct` (assemblage).                              |
| `Part`                      | Objet modèle d'une pièce ; donne accès aux corps solides, surfaces et autres entités.                |
| `Product`                   | Composant au sein d'un assemblage ; peut contenir d'autres sous-produits.                            |
| `Products`                  | Collection des sous-composants enfants d'un `Product`.                                               |
| `PartNumber`                | Numéro de référence d'un composant dans un assemblage (propriété de `Product`).                      |
| `ReferenceProduct`          | Référence vers le produit maître d'un composant d'assemblage.                                        |
| `Bodies`                    | Collection des corps solides d'une pièce (`Part`).                                                   |
| `Body`                      | Corps solide contenant des features de modélisation (Pad, Pocket, etc.).                             |
| `Shapes`                    | Collection des features solides contenus dans un `Body`.                                             |
| `HybridBodies`              | Collection des ensembles géométriques (corps de surfaces/courbes) d'une pièce.                       |
| `HybridBody`                | Ensemble géométrique regroupant des surfaces et courbes.                                             |
| `HybridShapes`              | Collection des formes hybrides (surfaces, courbes) contenues dans un `HybridBody`.                   |
| `HybridShape`               | Surface ou courbe individuelle dans un ensemble géométrique.                                         |
| `HybridShapeFactory`        | Fabrique de formes hybrides ; permet de créer des opérations surfaciques par macro.                  |
| `AddNewJoin`                | Crée une opération **Join** (assemblage/raccordement de surfaces) dans le modèle.                    |
| `AddNewHeal`                | Crée une opération **Healing** destinée à combler les micro-écarts entre surfaces.                   |
| `AddElement`                | Ajoute une surface à une opération Healing.                                                          |
| `MergingDistance`           | Paramètre de l'opération Healing définissant la distance de fusion entre surfaces (en mm).           |
| `AppendHybridShape`         | Insère une forme hybride dans un `HybridBody`.                                                       |
| `SPAWorkbench`              | Atelier _Space Analysis_ de CATIA, utilisé pour mesurer des entités géométriques.                    |
| `GetWorkbench`              | Méthode permettant d'accéder à un atelier CATIA depuis un document (ex. `SPAWorkbench`).             |
| `Reference`                 | Objet pointant vers une entité géométrique du modèle, requis par certaines opérations CATIA.         |
| `CreateReferenceFromObject` | Crée un objet `Reference` à partir d'une entité géométrique CATIA.                                   |
| `GetMeasurable`             | Retourne un objet `Measurable` permettant d'interroger les grandeurs géométriques d'une entité.      |
| `Measurable`                | Objet d'analyse géométrique exposant des propriétés de mesure (aire, volume, etc.).                  |
| `Area`                      | Aire d'une surface retournée par `Measurable` (exprimée en m² par défaut dans l'API).                |
| `Volume`                    | Volume d'un solide retourné par `Measurable` (exprimé en m³ par défaut dans l'API).                  |
| `Update`                    | Met à jour l'ensemble du modèle géométrique d'une pièce.                                             |
| `UpdateObject`              | Met à jour un objet spécifique du modèle sans recalculer toute la pièce.                             |
| `Selection`                 | Objet de gestion de la sélection active dans CATIA.                                                  |
| `Selection.Add`             | Ajoute un élément à la sélection courante.                                                           |
| `Selection.Clear`           | Vide la sélection courante.                                                                          |
| `Selection.Delete`          | Supprime du modèle les éléments actuellement sélectionnés.                                           |
| `Parent`                    | Propriété retournant l'objet parent dans la hiérarchie du modèle CATIA (ex. : document d'un `Part`). |
